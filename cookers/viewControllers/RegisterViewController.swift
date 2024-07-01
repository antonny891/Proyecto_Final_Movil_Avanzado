import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class RegisterViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var txtnombre: UITextField!
    @IBOutlet weak var txtemail: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    
    @IBOutlet weak var buttonregister: UIButton!
    @IBOutlet weak var btnpreguntasesion: UIButton!
    
    let transicionDesvanecimiento = TransicionDesvanecimiento()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnpregunta(_ sender: Any) {
       
    }
    
    @IBAction func btnregister(_ sender: Any) {
        guard let nombre = txtnombre.text, !nombre.isEmpty,
              let email = txtemail.text, !email.isEmpty,
              let password = txtpassword.text, !password.isEmpty else {
            
            showAlert(title: "Error", message: "Por favor, completa todos los campos")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Manejar error de creación de usuario
                self.showAlert(title: "Error", message: "Error al crear usuario: \(error.localizedDescription)")
                return
            }

            guard let uid = authResult?.user.uid else { return }

            let ref = Database.database().reference()
            ref.child("users").child(uid).setValue([
                "nombre": nombre,
                "email": email
            ]) { error, _ in
                if let error = error {
                    // Manejar error al guardar los datos del usuario en Realtime Database
                    self.showAlert(title: "Error", message: "Error al guardar los datos del usuario: \(error.localizedDescription)")
                } else {
                    // Usuario registrado y datos guardados exitosamente
                    self.showAlert(title: "Éxito", message: "Usuario registrado y datos guardados exitosamente") {
                        // Presentar el MainTabBarController con una transición de desvanecimiento
                        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                            tabBarController.modalPresentationStyle = .fullScreen
                            tabBarController.transitioningDelegate = self
                            self.present(tabBarController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transicionDesvanecimiento
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transicionDesvanecimiento
    }
    
    @IBAction func googleButton(_ sender: Any) {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
              guard error == nil else {
                print("Error during Google Sign-In: \(String(describing: error?.localizedDescription))")
                return
              }

              guard let user = result?.user,
                let idToken = user.idToken?.tokenString
              else {
                print("Error: Google Sign-In returned no user or token")
                return
              }

              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: user.accessToken.tokenString)

              Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error during Firebase authentication: \(error.localizedDescription)")
                    return
                }

                // User successfully signed in, transition to the next screen
                if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                    tabBarController.modalPresentationStyle = .fullScreen
                    tabBarController.transitioningDelegate = self
                    self.present(tabBarController, animated: true, completion: nil)
                }
              }
            }
        }
    
}
