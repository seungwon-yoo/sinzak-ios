//
//  Font+Extension.swift
//  Sinzak
//
//  Created by 유승원 on 2023/06/28.
//

import SwiftUI
import UIKit

enum SpoqaHanSansStyle: String {
    case regular = "SpoqaHanSansNeo-Regular"
    case medium = "SpoqaHanSansNeo-Medium"
    case bold = "SpoqaHanSansNeo-Bold"
}

extension Font {
    // Title
    static var title_B: Font { customFont(SpoqaHanSansStyle.bold.rawValue, size: 30)}
    static var subtitle_B: Font { customFont(SpoqaHanSansStyle.bold.rawValue, size: 20)}
    // Body
    static var body_B: Font {
        customFont(SpoqaHanSansStyle.bold.rawValue, size: 16) }
    static var body_M: Font { customFont(SpoqaHanSansStyle.medium.rawValue, size: 16) }
    static var body_R: Font { customFont(SpoqaHanSansStyle.regular.rawValue, size: 16) }
    // Caption
    static var caption_B: Font { customFont(SpoqaHanSansStyle.bold.rawValue, size: 13) }
    static var caption_M: Font { customFont(SpoqaHanSansStyle.medium.rawValue, size: 13) }
    static var caption_R: Font { customFont(SpoqaHanSansStyle.regular.rawValue, size: 13) }
    // Button Title
    static var buttonText_R: Font { customFont(SpoqaHanSansStyle.medium.rawValue, size: 10) }
    
    // Signout Check
    static var signoutTitle: Font {
        customFont(SpoqaHanSansStyle.bold.rawValue, size: 25.0)
    }
    
    static var signoutSubtitle: Font {
        customFont(SpoqaHanSansStyle.medium.rawValue, size: 14.0)
    }
    
    /// 커스텀 폰트를 설정하는 메서드
    private static func customFont(_ name: String,
                                   size: CGFloat) -> Font {
            let font = Font.custom(name, size: size)
            return font
        }
}

extension UIFont {
    // Title
    static var title_B: UIFont { customFont(SpoqaHanSansStyle.bold.rawValue, size: 30)}
    static var subtitle_B: UIFont { customFont(SpoqaHanSansStyle.bold.rawValue, size: 20)}
    // Body
    static var body_B: UIFont {
        customFont(SpoqaHanSansStyle.bold.rawValue, size: 16) }
    static var body_M: UIFont { customFont(SpoqaHanSansStyle.medium.rawValue, size: 16) }
    static var body_R: UIFont { customFont(SpoqaHanSansStyle.regular.rawValue, size: 16) }
    // Caption
    static var caption_B: UIFont { customFont(SpoqaHanSansStyle.bold.rawValue, size: 13) }
    static var caption_M: UIFont { customFont(SpoqaHanSansStyle.medium.rawValue, size: 13) }
    static var caption_R: UIFont { customFont(SpoqaHanSansStyle.regular.rawValue, size: 13) }
    // Button Title
    static var buttonText_R: UIFont { customFont(SpoqaHanSansStyle.medium.rawValue, size: 10) }
    
    // Signout Check
    static var signoutTitle: UIFont {
        customFont(SpoqaHanSansStyle.bold.rawValue, size: 25.0)
    }
    
    static var signoutSubtitle: UIFont {
        customFont(SpoqaHanSansStyle.medium.rawValue, size: 14.0)
    }

    /// 커스텀 폰트를 설정하는 메서드
    private static func customFont(
        _ name: String, size: CGFloat,
        style: UIFont.TextStyle? = nil,
        scaled: Bool = false ) -> UIFont {
            guard let font = UIFont(name: name, size: size) else {
                print("Warning: Font '\(name)' not found.")
                return UIFont.systemFont(ofSize: size, weight: .regular)
            }
            if scaled, let style = style {
                let metrics = UIFontMetrics(forTextStyle: style)
                return metrics.scaledFont(for: font)
            } else {
                return font
            }
        }
}
