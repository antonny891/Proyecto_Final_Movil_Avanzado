// LoginViewController.swift
// cookers
// Created by Kael Dexx on 19/06/24.

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var txtemail: UITextField!
    @IBOutlet weak var txtpassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btniniciarsesion(_ sender: Any) {
        guard let email = txtemail.text, !email.isEmpty,
              let password = txtpassword.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Por favor, completa todos los campos")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Error al iniciar sesión: \(error.localizedDescription)")
                return
            }

            // Inicio de sesión exitoso
            self.showAlert(title: "Éxito", message: "Inicio de sesión exitoso") {
                self.performSegue(withIdentifier: "InicioSesionSegue", sender: nil)
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
