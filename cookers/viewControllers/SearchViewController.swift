//
//  SearchViewController.swift
//  cookers
//
//  Created by Kael Dexx on 30/06/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var allRecetas: [Receta] = []
    var filteredRecetas: [Receta] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        searchTextField.delegate = self

        fetchAllRecetas()
    }

    func fetchAllRecetas() {
        let ref = Database.database().reference().child("recetas")

        ref.observeSingleEvent(of: .value) { snapshot in
            guard let recetasSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                print("No se encontraron recetas")
                return
            }

            self.allRecetas.removeAll()

            for recetaSnapshot in recetasSnapshot {
                if let recetaData = recetaSnapshot.value as? [String: Any],
                   let nombre = recetaData["nombre"] as? String,
                   let tipo = recetaData["tipo"] as? String,
                   let ingredientes = recetaData["ingredientes"] as? String,
                   let preparacion = recetaData["preparacion"] as? String,
                   let userId = recetaData["user_id"] as? String, // Optional filtering based on user ID
                   let imagen = recetaData["imagen"] as? String {

                    let receta = Receta(id: recetaSnapshot.key, imagen: imagen, nombre: nombre, tipo: tipo, ingredientes: ingredientes, preparacion: preparacion, userId: userId)
                    self.allRecetas.append(receta)
                } else {
                    print("Error al procesar la receta: \(recetaSnapshot.key)")
                }
            }

            print("Recetas cargadas: \(self.allRecetas.count)")
            self.filterContentForSearchText("") // Ensure initial display of all recipes
        } withCancel: { error in
            print("Error al obtener recetas: \(error.localizedDescription)")
        }
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        filterContentForSearchText(newText)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        filterContentForSearchText("")
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecetas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let receta = filteredRecetas[indexPath.row]

        cell.textLabel?.text = receta.nombre
        cell.detailTextLabel?.text = receta.tipo
        if let imageUrl = URL(string: receta.imagen) {
            cell.imageView?.sd_setImage(with: imageUrl, completed: nil)
        }

        return cell
    }

    // MARK: - Helper methods

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredRecetas = allRecetas
        } else {
            filteredRecetas = allRecetas.filter { receta in
                return receta.nombre.lowercased().contains(searchText.lowercased())
            }
        }

        print("Recetas filtradas: \(filteredRecetas.count)")
        tableView.reloadData()
    }
}
