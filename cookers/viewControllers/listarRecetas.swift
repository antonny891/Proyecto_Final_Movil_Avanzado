//
//  listarRecetas.swift
//  cookers
//
//  Created by Kael Dexx on 29/06/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class listarRecetas: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //YA ESTA EL BORRADO DE DATOS ME FALTA LA MODIFICACION DE REGISTROS
    //YA REGRESO ME IRE A COMER
    
    //OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    var allRecetas: [Receta] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.isEditing = false
        // Do any additional setup after loading the view.
        
        fetchAllRecetas()
    }
    
    func fetchAllRecetas() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No se pudo obtener el ID del usuario actual")
            return
        }
        
        let ref = Database.database().reference().child("recetas")
        let query = ref.queryOrdered(byChild: "user_id").queryEqual(toValue: currentUserID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let recetasSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            self.allRecetas.removeAll() // Clear the current array of recipes
            
            for recetaSnapshot in recetasSnapshot {
                if let recetaData = recetaSnapshot.value as? [String: Any],
                   let nombre = recetaData["nombre"] as? String,
                   let tipo = recetaData["tipo"] as? String,
                   let ingredientes = recetaData["ingredientes"] as? String,
                   let preparacion = recetaData["preparacion"] as? String,
                   let userId = recetaData["user_id"] as? String,
                   let imagen = recetaData["imagen"] as? String {
                    let receta = Receta(id: recetaSnapshot.key, imagen: imagen, nombre: nombre, tipo: tipo, ingredientes: ingredientes, preparacion: preparacion, userId: userId)
                    print(receta)
                    self.allRecetas.append(receta)
                }
            }
            
            // Recargar la tabla
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete{
            var ref = Database.database().reference()
            deleteRecord(withID: allRecetas[indexPath.row].id)
            allRecetas.remove(at: indexPath.row)
            tableView.reloadData()
        } else if editingStyle == .insert {
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let objetoMovido = self.allRecetas[sourceIndexPath.row]
        allRecetas.remove(at: sourceIndexPath.row)
        allRecetas.insert(objetoMovido, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(allRecetas)
        return allRecetas.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //print(allRecetas.count)
        let receta = allRecetas[indexPath.row]
        cell.textLabel?.text = receta.nombre
        cell.detailTextLabel?.text = receta.tipo
        if let imageUrl = URL(string: receta.imagen) {
            cell.imageView?.sd_setImage(with: imageUrl, completed: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recetaSeleccionada = allRecetas[indexPath.row]
        print("La receta seleccionada es la siguiente \(recetaSeleccionada)")
        
        performSegue(withIdentifier: "editarReceta", sender: self)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllRecetas()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editarReceta" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedReceta = allRecetas[indexPath.row]
                let detailVC = segue.destination as! EditarRecetaViewController
                detailVC.receta = selectedReceta
            }
        }
    }
    
    //OTHER FUNCTIONS
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteRecord(withID recordID: String) {
        // Accedemos a la referencia del registro que queremos eliminar
        var ref = Database.database().reference()
        ref.child("recetas").child(recordID).removeValue { error, _ in
            if let error = error {
                print("Error al eliminar el registro: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Borrado exitoso", message: "Se logro borrar la receta correctamente :D")
                print("Registro eliminado exitosamente")
            }
        }
    }
}
