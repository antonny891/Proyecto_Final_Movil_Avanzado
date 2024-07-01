//
//  crearReceta.swift
//  cookers
//
//  Created by Kael Dexx on 24/06/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Firebase
import AVFoundation

class crearReceta: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var imagePicker = UIImagePickerController()

    //OUTLET
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var tipo: UITextField!
    @IBOutlet weak var ingredientes: UITextField!
    @IBOutlet weak var preparacion: UITextField!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var grabarButton: UIButton!
    
    //VARS
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var audioURL: URL?
    
    //ACTIONS
    @IBAction func publicarButton(_ sender: Any) {
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
                           
                           let recetaId = UUID().uuidString
                           
                           let receta: [String: Any] = [
                               "nombre": nombreText,
                               "tipo": tipoText,
                               "ingredientes": ingredientesText,
                               "preparacion": preparacionText,
                               "user_id": user.uid,
                               "imagen" : url?.absoluteString
                           ]

                           
                           let ref = Database.database().reference()
                           ref.child("recetas").child(recetaId).setValue(receta) { error, _ in
                               if let error = error {
                                   print("Error al guardar la receta: \(error.localizedDescription)")
                        } else {
                            // También agregar la receta al nodo del usuario
                            //ref.child("users").child(user.uid).child("recetas").child(recetaId).setValue(true)
                            self.showAlert(title: "Receta guardada", message: "Receta guardada con exito")
                            print("Receta guardada con éxito")
                        }
                    }
                    
                })
            }
        }
        
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if audioRecorder!.isRecording {
            audioRecorder?.stop()
            grabarButton.setTitle("Grabar", for: .normal)
            reproducirButton.isEnabled = true
        } else {
            audioRecorder?.record()
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer?.play()
            print("Reproduciendo")
        } catch {
            print("Error al reproducir audio: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        imagePicker.delegate = self
        configurarGrabacion()
    }
    
    
    //OTHER FUNCTIONS
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
    
    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
                
            let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
                
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject
            settings[AVSampleRateKey] = 44100.0 as AnyObject
            settings[AVNumberOfChannelsKey] = 2 as AnyObject
                
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
}
