//
//  Colors.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 01.03.2025.
//

import SwiftUI

extension Color {
    init(simplifiedRed: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.init(uiColor: UIColor(simplifiedRed: simplifiedRed, green: green, blue: blue, alpha: alpha))
    }

    static var menuColors = Color(uiColor: UIColor(simplifiedRed: 75, green: 138, blue: 197, alpha: 1.0))

    static var gradientColorOne = Color(simplifiedRed: 76, green: 41, blue: 221)
    static var gradientColorTwo = Color(simplifiedRed: 135, green: 60, blue: 154)
}

extension UIColor {
    convenience init(simplifiedRed: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: simplifiedRed / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
}
