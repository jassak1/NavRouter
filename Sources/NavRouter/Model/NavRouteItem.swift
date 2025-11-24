//
//  NavRoutes.swift
//  NavRouter
//
//  Created by Adam Jassak on 03/10/2025.
//

import Foundation

/// Custom protocol used as an Interface for App's type containing all navigation Routes.
public protocol NavRouteItem: Hashable, Identifiable {
    var id: Self { get }
}

public extension NavRouteItem {
    var id: Self { self }
}
