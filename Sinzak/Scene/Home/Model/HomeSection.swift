//
//  HomeSection.swift
//  Sinzak
//
//  Created by Doy Kim on 2023/03/07.
//

import Foundation

enum HomeNotLoginedType: Int, CaseIterable {
    case trading = 3
    case new = 1
    case hot = 2
    var title: String {
        switch self {
        case .trading:
            return I18NStrings.sectionTrading
        case .new:
            return I18NStrings.sectionHot
        case .hot:
            return I18NStrings.sectionNew
        }
    }
}

enum HomeLoginedType: Int, CaseIterable {
    case new = 1
    case recommend = 2
    case following = 3
    var title: String {
        switch self {
        case .new:
            return I18NStrings.sectionNew
        case .recommend:
            return I18NStrings.sectionRecommend
        case .following:
            return I18NStrings.sectionFollowing
        }
    }
}
