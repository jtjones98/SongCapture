import UIKit

final class UploadViewController: UIViewController {
    
    private let viewModel: UploadViewModel
    private weak var coordinator: AddSongsCoordinating?

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
    }
}

