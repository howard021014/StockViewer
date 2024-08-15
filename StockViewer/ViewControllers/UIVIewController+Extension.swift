//
//  UIVIewController+Extension.swift
//  StockViewer
//
//  Created by Howard tsai on 2024-08-15.
//

import UIKit

extension UIViewController {
    
    func createErrorAlert(with message: String) {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(errorAlert, animated: true)
    }
    
    func presentErrorAlert(with message: String) {
        if let presentedVC = self.presentedViewController as? UIAlertController {
            presentedVC.dismiss(animated: false) { [weak self] in
                self?.createErrorAlert(with: message)
            }
        } else {
            createErrorAlert(with: message)
        }
    }
    
}
