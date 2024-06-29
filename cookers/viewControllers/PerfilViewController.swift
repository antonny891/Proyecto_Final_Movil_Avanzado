//
//  PerfilViewController.swift
//  cookers
//
//  Created by Kael Dexx on 28/06/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PerfilViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    var ref: DatabaseReference!
		
    override func viewDidLoad() {
        super.viewDidLoad()
        // Inicializar la referencia a la base de datos
        ref = Database.database().reference()
        // Cargar información del usuario al cargar la vista
        if let userId = Auth.auth().currentUser?.uid {
            fetchUserInfo(userId: userId)
        }
    }

    func fetchUserInfo(userId: String) {
        ref.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                let name = value["nombre"] as? String ?? ""
                let email = value["email"] as? String ?? ""
                self.nameTextField.text = name
                self.emailTextField.text = email
                // No es posible obtener la contraseña directamente, se omite para fines de seguridad
            } else {
                print("El usuario no existe")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let userId = Auth.auth().currentUser?.uid,
           let name = nameTextField.text,
           let email = emailTextField.text {
            updateUserInfo(userId: userId, name: name, email: email)
        }
    }

    func updateUserInfo(userId: String, name: String, email: String) {
        ref.child("users").child(userId).updateChildValues([
            "nombre": name,
            "email": email
        ]) { (error, ref) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Información del usuario actualizada")
            }
        }

        // Para actualizar la contraseña
        if let newPassword = passwordTextField.text, !newPassword.isEmpty {
            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Error al actualizar la contraseña: \(error.localizedDescription)")
                } else {
                    print("Contraseña actualizada")
                }
            }
        }
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            // Navegar a la pantalla de inicio de sesión
            navigateToLogin()
        } catch let signOutError as NSError {
            print("Error al cerrar sesión: %@", signOutError)
        }
    }

    func navigateToLogin() {
        // Reemplazar "LoginViewController" con el identificador correcto de tu vista de inicio de sesión en el storyboard
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


