//
//  VerRecetaViewController.swift
//  cookers
//
//  Created by Kael Dexx on 22/06/24.
//

import UIKit
import SDWebImage

class VerRecetaViewController: UIViewController {
    
    var receta : Receta?

    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var IngredientesLabel: UITextView!
    @IBOutlet weak var praparacionLabel: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var tipoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(receta!)
        
        if let receta = receta {
            nombreLabel.text = receta.nombre
            tipoLabel.text = receta.tipo
            IngredientesLabel.text = receta.ingredientes
            praparacionLabel.text = receta.preparacion
            if let imageUrl = URL(string: receta.imagen) {
                imageView.sd_setImage(with: imageUrl, completed: nil)
            }
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
