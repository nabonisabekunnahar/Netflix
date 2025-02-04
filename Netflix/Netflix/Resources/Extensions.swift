//
//  Extensions.swift
//  Netflix Clone
//
//  Created by Sayaka Alam on 3/1/25.
//

import Foundation


extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
