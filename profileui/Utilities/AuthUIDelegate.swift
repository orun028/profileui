import Firebase
import Fire
import SafariServices

class AuthUIDelegate: NSObject, FUIAuthDelegate {

    weak var presentingViewController: UIViewController?
    
    // Customize the FirebaseUI web-based authentication experience here
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            // Handle error
            return
        }
        
        guard let user = user else {
            // Handle empty user
            return
        }
        
        // User signed in successfully, handle the user object as needed
        print("User signed in with uid: \(user.uid)")
    }
    
    // Implement the required method of the AuthUIDelegate protocol to customize the web view
    func authUI(_ authUI: FUIAuth, presenting viewController: UIViewController) -> UIViewController {
        self.presentingViewController = viewController
        
        let safariViewController = SFSafariViewController(url: authUI.authUIURL())
        safariViewController.delegate = self
        
        return safariViewController
    }
}

// Implement the SFSafariViewControllerDelegate protocol to handle dismissal of the Safari view controller
extension CustomAuthUIDelegate: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
