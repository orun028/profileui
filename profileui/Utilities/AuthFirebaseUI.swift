import Firebase
import SafariServices

class CustomAuthUIDelegate: NSObject, AuthUIDelegate {

    weak var presentingViewController: UIViewController?

    // Implement the required method of the AuthUIDelegate protocol to customize the web view
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let safariViewController = viewControllerToPresent as? SFSafariViewController {
            safariViewController.delegate = self
            presentingViewController = safariViewController
        }
        presentingViewController?.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

// Implement the SFSafariViewControllerDelegate protocol to handle dismissal of the Safari view controller
extension AuthFirebaseUI: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
