import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var allRecetas: [Receta] = []

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 150 // Altura estimada para las celdas
        tableView.rowHeight = UITableView.automaticDimension
        fetchAllRecetas()

    }
    
    func fetchAllRecetas() {
        let ref = Database.database().reference().child("recetas")
        ref.observeSingleEvent(of: .value) { snapshot in
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
                    //print(receta)
                    self.allRecetas.append(receta)
                }
            }

            // Recargar la tabla
            self.tableView.reloadData()
        }
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
        performSegue(withIdentifier: "mostrartReceta", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mostrartReceta" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedReceta = allRecetas[indexPath.row]
                let detailVC = segue.destination as! VerRecetaViewController
                detailVC.receta = selectedReceta
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllRecetas()
        tableView.reloadData()
    }
}
