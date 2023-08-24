//
//  UIsearchBar+TintColorExtension.swift
//  CryptoRate
//
//  Created by Viktor Golovach on 24.08.2023.
//

import UIKit

extension UISearchBar {
    func setPlaceholder(with text: String, and color: UIColor) {
         let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color.withAlphaComponent(0.5) // Your desired color
         ]
         
        
         if let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField {
             textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(
                string: text,
                attributes: placeholderAttributes)
             textFieldInsideSearchBar.defaultTextAttributes = [NSAttributedString.Key.foregroundColor: color] // Your desired color
             
             if let leftView = textFieldInsideSearchBar.leftView as? UIImageView {
                 leftView.tintColor = color // Your desired color
             }
         }
    }
}

