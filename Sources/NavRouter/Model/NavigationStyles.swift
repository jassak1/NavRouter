//
//  NavigationStyles.swift
//  NavRouter
//
//  Created by Adam Jassak on 03/10/2025.
//

import Foundation

/// Available navigation styles used within `navigate(to: )` method of `NavRouter`.
public enum NavigationStyles: CaseIterable, Hashable {
    case push, sheet, fullScreenCover, fullScreenCoverWithNavBar
}
