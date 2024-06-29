//
//  EditarRecetaViewController.swift
//  cookers
//
//  Created by Kael Dexx on 22/06/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class EditarRecetaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    protocol EditarRecetaDelegate: AnyObject {
        func didEditReceta(_ receta: Receta)
    }
    
    var imagePicker = UIImagePickerController()
    
    weak var delegate: EditarRecetaDelegate?
    
    var receta : Receta?
    
    //OUTLETS
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var tipo: UITextField!
    @IBOutlet weak var ingredientes: UITextField!
    @IBOutlet weak var preparacion: UITextField!
    
    //ACTIONS
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)    }
    
    
    @IBAction func editarButton(_ sender: Any) {
        
        
        guard let nombreText = nombre.text, !nombreText.isEmpty,
                     let tipoText = tipo.text, !tipoText.isEmpty,
                     let ingredientesText = ingredientes.text, !ingredientesText.isEmpty,
                     let preparacionText = preparacion.text, !preparacionText.isEmpty,
                     let imagenData = imagen.image?.jpegData(compressionQuality: 0.50),
                     let user = Auth.auth().currentUser else {
                   // Show an error message if any field is empty or if the user is not authenticated
                   return
               }

               let imagenesFolder = Storage.storage().reference().child("imagenes")
               let cargarImagen = imagenesFolder.child("\(NSUUID().uuidString).jpg")
               
               cargarImagen.putData(imagenData, metadata: nil) {(metadata, error) in
                   if error != nil{
                       print("Ocurrio un error subiendo la imagen")
                   }else {
                       cargarImagen.downloadURL(completion: { (url, error) in
                           guard let enlaceURL = url else{
                               print("Ocurrio un error al obtener informacion de imagen \(error)")
                               return
                           }
                           
                           let recetaId = self.receta!.id
                           
                           let receta2: [String: Any] = [
                               "nombre": nombreText,
                               "tipo": tipoText,
                               "ingredientes": ingredientesText,
                               "preparacion": preparacionText,
                               "user_id": user.uid,
                               "imagen" : url?.absoluteString
                           ]

                           
                           let ref = Database.database().reference()
                           ref.child("recetas").child(recetaId).updateChildValues(receta2) { error, _ in
                               if let error = error {
                                   print("Error al guardar la receta: \(error.localizedDescription)")
                        } else {
                            // También agregar la receta al nodo del usuario
                            //ref.child("users").child(user.uid).child("recetas").child(recetaId).setValue(true)
                            self.delegate?.didEditReceta(self.receta!)
                            self.showAlert(title: "Receta guardada", message: "Receta guardada con exito"){
                                self.navigationController?.popViewController(animated: true)

                            }
                            print("Receta guardada con éxito")
                        }
                    }
                    
                })
            }
        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        if let receta = receta {
            nombre.text = receta.nombre
            tipo.text = receta.tipo
            ingredientes.text = receta.ingredientes
            preparacion.text = receta.preparacion
            if let imageUrl = URL(string: receta.imagen) {
                imagen.sd_setImage(with: imageUrl, completed: nil)
            }
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagen.image = image
        imagen.backgroundColor = UIColor.clear
        imagePicker.dismiss(animated: true, completion: nil)
        
    }

}
