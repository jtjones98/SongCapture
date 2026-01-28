import UIKit

final class UploadViewController: UIViewController {
    
    private let viewModel: UploadViewModel
    private weak var coordinator: AddSongsCoordinating?
    
    private var uploadButton: UIButton!

    init(with viewModel: UploadViewModel, coordinator: AddSongsCoordinating) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("From coder has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        uploadButton.layer.cornerRadius = uploadButton.bounds.width / 2
        uploadButton.layer.masksToBounds = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        uploadButton = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.image = UIImage(systemName: "square.and.arrow.up.circle.fill")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        configuration.cornerStyle = .capsule
        uploadButton.configuration = configuration
        
        uploadButton.accessibilityLabel = "Upload"
        uploadButton.accessibilityHint = "Tap to select audio for upload"
        
        view.addSubview(uploadButton)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            uploadButton.widthAnchor.constraint(equalToConstant: 120),
            uploadButton.heightAnchor.constraint(equalTo: uploadButton.widthAnchor)
        ])
        
        // Set up shadow
        uploadButton.layer.shadowColor = UIColor.black.cgColor
        uploadButton.layer.shadowOpacity = 0.2
        uploadButton.layer.shadowRadius = 8
        uploadButton.layer.shadowOffset = CGSize(width: 0, height: 4)

        uploadButton.addTarget(self, action: #selector(uploadTapped), for: .touchUpInside)

        uploadButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            UIView.animate(withDuration: 0.15) {
                button.transform = button.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }

    @objc private func uploadTapped() {
        // TODO: Trigger upload via viewModel or notify coordinator
    }
}

