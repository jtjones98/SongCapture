//
//  ListenViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/6/26.
//

import Combine
import UIKit

class ListenViewController: UIViewController {
    
    private var viewModel: ListenViewModel
    private weak var coordinator: AddSongsCoordinating?
    
    private var cancellables: Set<AnyCancellable> = []

    private var recordButton: UIButton!
    
    init(with viewModel: ListenViewModel, coordinator: AddSongsCoordinating) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Storyboard not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recordButton.layer.cornerRadius = recordButton.bounds.width / 2
        recordButton.layer.masksToBounds = true
    }
    
    private func setupViewModel() {
        viewModel.$state
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .idle:
                    self.stopPulsingRecordButton()
                    self.recordButton.isEnabled = true
                case .listening:
                    self.startPulsingRecordButton()
                    self.recordButton.isEnabled = false
                case .listened(let track):
                    self.stopPulsingRecordButton()
                    self.recordButton.isEnabled = true
                    print(track)
                case .failed(let error):
                    self.stopPulsingRecordButton()
                    self.recordButton.isEnabled = true
                    switch error {
                    case .noMatchFound(let message):
                        self.setupUnsuccessfulUI(message)
                    case .permissionNotGranted(let title, let message, let settingsAction, let cancelAction):
                        self.showPermissionsNeededAlert(title, message, settingsAction, cancelAction)
                    case .engineError(let message):
                        self.setupUnsuccessfulUI(message)
                        break
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        recordButton = UIButton(type: .system)

        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemRed
        configuration.baseForegroundColor = .white
        configuration.image = UIImage(systemName: "waveform.circle.fill")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        configuration.cornerStyle = .capsule
        recordButton.configuration = configuration
        
        recordButton.accessibilityLabel = "Record"
        recordButton.accessibilityHint = "Tap to start or stop recording"

        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 120),
            recordButton.heightAnchor.constraint(equalTo: recordButton.widthAnchor)
        ])

        // Set up shadow
        recordButton.layer.shadowColor = UIColor.black.cgColor
        recordButton.layer.shadowOpacity = 0.2
        recordButton.layer.shadowRadius = 8
        recordButton.layer.shadowOffset = CGSize(width: 0, height: 4)

        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
    }
    
    
    @objc private func didTapRecordButton() {
        viewModel.listen()
    }

    private func startPulsingRecordButton() {
        stopPulsingRecordButton()

        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.08
        pulse.duration = 0.8
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulse.autoreverses = true
        pulse.repeatCount = .greatestFiniteMagnitude
        recordButton.layer.add(pulse, forKey: "pulse")
    }
    
    private func stopPulsingRecordButton() {
        recordButton.layer.removeAnimation(forKey: "pulse")
        recordButton.layer.removeAllAnimations()
        recordButton.transform = .identity
    }
    
    private func setupUnsuccessfulUI(_ message: String) {
        // TODO: Set up unsucessful UI
        print(message)
    }
    
    // Presents an alert guiding the user to Settings to grant microphone permission
    private func showPermissionsNeededAlert(_ title: String, _ message: String, _ settingsAction: String, _ cancelAction: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let openSettings = UIAlertAction(title: settingsAction, style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        let cancel = UIAlertAction(title: cancelAction, style: .cancel, handler: nil)

        alert.addAction(cancel)
        alert.addAction(openSettings)
        
        present(alert, animated: true)
    }
}

