//
//  TransicionDesvanecimiento.swift
//  cookers
//
//  Created by Kael Dexx on 28/06/24.
//

import UIKit

class TransicionDesvanecimiento: NSObject, UIViewControllerAnimatedTransitioning {

    let duracion = 0.5

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duracion
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let vistaDesde = transitionContext.view(forKey: .from),
              let vistaHacia = transitionContext.view(forKey: .to) else {
            return
        }

        let contenedorVista = transitionContext.containerView
        vistaHacia.alpha = 0.0
        contenedorVista.addSubview(vistaHacia)

        UIView.animate(withDuration: duracion, animations: {
            vistaDesde.alpha = 0.0
            vistaHacia.alpha = 1.0
        }) { _ in
            vistaDesde.alpha = 1.0
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
