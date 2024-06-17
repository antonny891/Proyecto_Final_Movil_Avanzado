//
//  RegisterViewController.swift
//  cookers
//
//  Created by Michell Condori on 17/06/24.
//

import UIKit


class RegisterViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    // Opcional: Agrega las imágenes que deseas mostrar en el carrusel
    let images = [UIImage(named: "mapa"), UIImage(named: "hombre"), UIImage(named: "comida")]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configura el UIScrollView
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(images.count), height: scrollView.frame.size.height)

        // Configura el UIPageControl
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black

        // Opcional: Agrega las imágenes al UIScrollView
        addImagesToScrollView()
    }

    func addImagesToScrollView() {
        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
