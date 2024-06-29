import UIKit

class MainViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var SignUpButton: UIButton!

    let images = [UIImage(named: "mapa"), UIImage(named: "hombre"), UIImage(named: "comida")]
    var timer: Timer?
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(images.count), height: scrollView.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false

        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black

        addImagesToScrollView()
        startAutoScroll()
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

    func startAutoScroll() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(autoScrollImages), userInfo: nil, repeats: true)
    }

    @objc func autoScrollImages() {
        currentIndex += 1
        if currentIndex >= images.count {
            currentIndex = 0
        }
        let offset = CGPoint(x: scrollView.frame.size.width * CGFloat(currentIndex), y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }

    @IBAction func SignUpPressed(_ sender: Any) {

        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: true) {
                self.presentLoginViewController()
            }
        } else {
            self.presentLoginViewController()
        }
    }

    private func presentLoginViewController() {
        if let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
            let navigationController = UINavigationController(rootViewController: loginViewController)
            navigationController.modalPresentationStyle = .fullScreen
            
            // Configurar la transición personalizada
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .moveIn
            transition.subtype = .fromRight
            view.window?.layer.add(transition, forKey: kCATransition)

            self.present(navigationController, animated: false, completion: nil)
        }
    }

    @IBAction func createAccountPressed(_ sender: UIButton) {
        // Asegúrate de que no haya otras vistas presentadas modalmente
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: true) {
                self.presentRegisterViewController()
            }
        } else {
            self.presentRegisterViewController()
        }
    }

    private func presentRegisterViewController() {
        if let registerViewController = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") {
            let navigationController = UINavigationController(rootViewController: registerViewController)
            navigationController.modalPresentationStyle = .fullScreen
            

            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .moveIn
            transition.subtype = .fromRight
            view.window?.layer.add(transition, forKey: kCATransition)

            self.present(navigationController, animated: false, completion: nil)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
