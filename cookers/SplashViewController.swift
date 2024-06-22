import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Esperar unos segundos antes de la transición
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.transitionToMainViewController()
        }
    }

    func transitionToMainViewController() {
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = mainVC
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
    }
}
