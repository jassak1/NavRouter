//
//  NavRouter.swift
//  NavRouter
//
//  Created by Adam Jassak on 03/10/2025.
//

import SwiftUI

/// `NavRouter` utility (Observable class) handling all of the SwiftUI Screens navigation related tasks.
/// Based on the `NavigationPath` the `NavRouter` allows pushing new screens, presenting modal
/// Sheet / FullScreenCover (including pushing new screens within these), dismissing of entire navigation
/// stack (poping to the root), etc. - tl;dr `NavRouter` handles all Navigation related actions.
///
///  - Parameters:
///     - NavTabs: (Generic) - App's Type conforming to `NavTabItem`. Such Type contains app's Tabs.
///     - NavRoutes: (Generic) - App's Type conforming to `NavRouteItem`. Such Type contains app's navigation routes.
@MainActor
public class NavRouter<NavTabs: NavTabItem,
                       NavRoutes: NavRouteItem>: ObservableObject {
    // MARK: - Properties
    /// Observable property holding currently selected Tab.
    @Published public var selectedTab: NavTabs?
    
    /// Observable property holding Dictionary of key:`NavTabs` and value:`NavigationPath` pair.
    /// Used within subscript when obtaining specific `NavigationPath` of a selected tab.
    @Published private var navPaths: [NavTabs: NavigationPath]
    
    /// Observable property holding Dictionary of key:`NavigationStyles` and value:`NavigationPath` pair.
    /// Used within subscript when obtaining specific `NavigationPath` of additional `NavigationStyles` - eg.
    /// `NavigationPath` used for stacking Views within a `.sheet`.
    @Published private var additionalPaths: [NavigationStyles: NavigationPath]
    
    /// Observable property holding Dictionary of key:`NavigationStyles` and value:`NavRoutes?` pair.
    /// Used within susbscript when obtaining specific `NavRoutes?` value, which serves as navigation `Item`.
    /// Such `Item` is used to distinguish whether to display a screen in additional `NavigationStyles`, or
    /// whether to dismiss it when such `NavigationStyles` value is nil.
    @Published private var additionalItems: [NavigationStyles: NavRoutes?]
    
    /// Helper property used for additional setup of `.sheet`'s presentation detents. `.large` by default.
    private(set) var presentationDetents: PresentationDetent
    
    // MARK: - Navigation methods
    
    /// Navigates to specific Screen by pushing screen's `NavRoutes` item into a navigation stack, or by
    /// presenting a modal Sheet / FullScreenCover.
    ///
    ///  - Parameters:
    ///     - destination: `NavRoutes` instance representing navigation destination screen.
    ///     - navigationStyle: Type of navigation - Push (default), Sheet, Ful Screen Cover.
    ///     - sheetStyle: Used to further specify `.sheet` navigationStyle's height. (`.large` by default).
    public func navigate(to destination: NavRoutes,
                         navigationStyle: NavigationStyles = .push,
                         sheetStyle: PresentationDetent = .large) {
        switch navigationStyle {
        case .push:
            if additionalItems[.sheet] != nil {
                additionalPaths[.sheet]?.append(destination)
            } else if additionalItems[.fullScreenCover] != nil {
                additionalPaths[.fullScreenCover]?.append(destination)
            } else {
                if let selectedTab {
                    navPaths[selectedTab]?.append(destination)
                }
            }
        case .sheet:
            presentationDetents = sheetStyle
            additionalItems[.sheet] = destination
        case .fullScreenCover:
            additionalItems[.fullScreenCover] = destination
        }
    }
    
    /// Removes all screens from navigation stack and pushes back to the initial one.
    /// The initial (root) screen depends on whether navigation stack has been build
    /// on top of the Sheet / FullScreenCover, or a Tab.
    public func popToRoot() {
        if additionalItems[.sheet] != nil {
            additionalPaths[.sheet]?.removeAll()
        } else if additionalItems[.fullScreenCover] != nil {
            additionalPaths[.fullScreenCover]?.removeAll()
        } else {
            if let selectedTab {
                navPaths[selectedTab] = .init()
            }
        }
    }
    
    /// Removes currently presented sheet. Sheet's `NavigationPath` stack is also removed
    /// in order to display proper screen once the new Sheet is presented.
    public func dismissSheet() {
        additionalItems[.sheet] = nil
        additionalPaths[.sheet] = .init()
    }
    
    /// Removes currently presented Full Screen Cover. Full Screen Cover's `NavigationPath` stack is also removed
    /// in order to display proper screen once the new Full Screen Cover is presented.
    public func dismissFullScreenCover() {
        additionalItems[.fullScreenCover] = nil
        additionalPaths[.fullScreenCover] = .init()
    }
    
    // MARK: - Subscripts
    /// Navigation path subscript - provides path of subscribted tab.
    ///
    ///  - Parameters:
    ///     - navTab: `NavTabs` value indicating tab for which `NavigationPath` is provided.
    ///
    ///  - Returns: `NavigationPath` of selected tab.
    public subscript(navTab: NavTabs) -> NavigationPath {
        get { navPaths[navTab] ?? .init() }
        set { navPaths[navTab] = newValue }
    }
    
    /// Navigation style subscript - provides navigation item of chosen style.
    ///
    ///  - Parameters:
    ///     - navStyle: `NavigationStyles` value indicating style for which Navigation Item is provided.
    ///
    ///  - Returns: `NavRoutes` optional value of selected style.
    public subscript(navStyle: NavigationStyles) -> NavRoutes? {
        get { additionalItems[navStyle] ?? nil }
        set { additionalItems[navStyle] = newValue }
    }
    
    /// Navigation path subscript - provides path of additional styles (Sheet, FullScreenCover).
    ///
    ///  - Parameters:
    ///    - navStyle: `NavigationStyle` value indicating style for which `NavigationPath` is provided.
    ///
    ///  - Returns: `NavigationPath` of selected style.
    public subscript(navStyle: NavigationStyles) -> NavigationPath {
        get { additionalPaths[navStyle] ?? .init() }
        set { additionalPaths[navStyle] = newValue }
    }
    
    // MARK: - Initialiser
    public init() {
        selectedTab = .allCases.first
        navPaths = .init()
        additionalItems = .init()
        presentationDetents = .large
        additionalPaths = [.sheet: .init(), .fullScreenCover: .init()]
        // Inits empty dictionary value for each tab upon `NavRouter` initialization
        _ = NavTabs.allCases.map {
            navPaths[$0] = .init()
        }
        // Inits nil dictionary value for each navigation style upon `NavRouter` initialization
        _ = NavigationStyles.allCases.map {
            additionalItems[$0] = nil
        }
    }
}

// MARK: - Helpers / Extensions
extension NavigationPath {
    /// Helper method removing entire stack from `NavigationPath` instance.
    mutating func removeAll() {
        removeLast(count)
    }
}
