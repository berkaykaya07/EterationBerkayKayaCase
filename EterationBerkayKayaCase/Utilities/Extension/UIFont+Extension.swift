//
//  UIFont+Extension.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

extension UIFont {
    
    // MARK: - Montserrat Font Family
    static func montserratLight(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func montserratRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func montserratMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func montserratBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func montserratSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func montserratExtraBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-ExtraBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    // MARK: - App Typography Scale
    
    // Headlines
    static var appLargeTitle: UIFont { montserratBold(size: 28) }
    static var appTitle1: UIFont { montserratBold(size: 24) }
    static var appTitle2: UIFont { montserratMedium(size: 20) }
    static var appTitle3: UIFont { montserratMedium(size: 18) }
    
    // Body Text
    static var appBody: UIFont { montserratRegular(size: 16) }
    static var appBodyMedium: UIFont { montserratMedium(size: 16) }
    static var appCallout: UIFont { montserratRegular(size: 14) }
    static var appFootnote: UIFont { montserratRegular(size: 12) }
    
    // Buttons
    static var appButtonLarge: UIFont { montserratMedium(size: 16) }
    static var appButtonMedium: UIFont { montserratMedium(size: 14) }
    static var appButtonSmall: UIFont { montserratMedium(size: 12) }
    
    // Price & Numbers
    static var appPriceLarge: UIFont { montserratBold(size: 18) }
    static var appPriceMedium: UIFont { montserratMedium(size: 16) }
    static var appPriceSmall: UIFont { montserratMedium(size: 14) }
}
