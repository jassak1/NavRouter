//
//  Views.swift
//  NavRouter
//
//  Created by Adam Jassak on 03/10/2025.
//

import SwiftUI

/// SwiftUI Wrapper for Convenient Screen (View) creation. Will return target `ScreenView` wrapped around Navigation
/// Stack with provided `NavigationPath` and working destination routing based on provided `DestinationView`.
///
///  - Parameters:
///     - navPath: Binding `NavigationPath` used as a navigation state of wrapped `ScreenView`.
///     - screenView: SwiftUI source View (`ScreenView`) that will be wrapped.
///     - destinationView: SwiftUI destination View (`DestinationView`) containing all destinations of `NavRoutes`.
///     Property is declared as closure providing instance of `NavRoutes` that shall be used within `DestinationView`.
///
///  - Returns: Source `ScreenView` wrapped inside Navigation Stack with proper routing based on `DestinationView`.
public struct NavWrapper<NavRoutes: NavRouteItem, ScreenView: View, DestinationView: View>: View {
    @Binding private var navPath: NavigationPath
    private let screenView: ScreenView
    private let destinationView: (NavRoutes) -> DestinationView
    public var body: some View {
        NavigationStack(path: $navPath) {
            screenView
                .navigationDestination(for: NavRoutes.self) {
                    destinationView($0)
                }
        }
    }
    
    public init(navPath: Binding<NavigationPath>, screenView: ScreenView, destinationView: @escaping (NavRoutes) -> DestinationView) {
        self._navPath = navPath
        self.screenView = screenView
        self.destinationView = destinationView
    }
}

/// Custom SwiftUI ViewModifier providing additional routing setup (`.sheet`, `.fullScreenCover`).
///
///  - Parameters:
///     - navRouter: Instance of `NavRouter` passed via .environmentObject.
///     - destinationView: SwiftUI target View (`DestinationView`) displayed upon calling of additional routing.
///
///  - Returns: SwiftUI ViewModifier with additional routing setup.
struct AdditionalRoutingViewModifier<NavTabs: NavTabItem,
                                     NavRoutes: NavRouteItem,
                                     NavigationRouter: NavRouter<NavTabs, NavRoutes>,
                                     DestinationView: View>: ViewModifier {
    @EnvironmentObject private var navRouter: NavigationRouter
    let destinationView: (NavRoutes) -> DestinationView
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $navRouter[.sheet],
                   onDismiss: { navRouter.dismissSheet() }) { route in
                NavWrapper(navPath: $navRouter[.sheet], screenView: destinationView(route)                            .presentationDetents([navRouter.presentationDetents])
                    .presentationDragIndicator(.visible)) {
                        destinationView($0)
                    }
            }
                   .fullScreenCover(item: $navRouter[.fullScreenCover],
                                    onDismiss: { navRouter.dismissFullScreenCover() }) { route in
                       NavWrapper(navPath: $navRouter[.fullScreenCover], screenView: destinationView(route)) {
                           destinationView($0)
                       }
                   }
    }
}

// MARK: - Helpers / Extensions
extension View {
    /// `AdditionalRoutingViewModifier` as a convenient `View` modifier.
    ///
    ///  - Parameters:
    ///     - navTabs: Type of the App's custom type conforming to `NavTabItem` used with `NavRouter`.
    ///     - destinationView: SwiftUI target View (`DestinationView`) displayed upon calling of additional routing.
    /// Property is declared as closure providing instance of `NavRoutes` that shall be used within `DestinationView`.
    ///
    ///  - Returns: SwiftUI ViewModifier with additional routing setup.
    public func setupAdditionalRouting<NavTabs: NavTabItem,
                                       NavRoutes: NavRouteItem,
                                       DestinationView: View>(_ navTabs: NavTabs.Type,
                                                              destinationView: @escaping (NavRoutes) -> DestinationView) -> some View {
        modifier(AdditionalRoutingViewModifier<NavTabs, NavRoutes, NavRouter<NavTabs, NavRoutes>, DestinationView>(destinationView: destinationView))
    }
}
