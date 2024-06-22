import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var txtnombre: UITextField!
    @IBOutlet weak var txtemail: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    
    @IBOutlet weak var buttonregister: UIButton!
    @IBOutlet weak var btnpreguntasesion: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnpregunta(_ sender: Any) {
        // Aquí puedes manejar la lógica para el botón de pregunta de sesión si es necesario
    }
    
    @IBAction func btnregister(_ sender: Any) {
        guard let nombre = txtnombre.text, !nombre.isEmpty,
              let email = txtemail.text, !email.isEmpty,
              let password = txtpassword.text, !password.isEmpty else {
            // Manejar caso de campos vacíos
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
                        // Realizar la transición a HomeViewController
                        self.performSegue(withIdentifier: "RegistroSegue", sender: nil)
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
}
