
#  [iOS] NavRouter

Simple and lightweight Navigation Utility for SwiftUI based iOS applications.
## Overview
**NavRouter** is a SPM (Swift Package Manager) based dependency used for handling all Navigation related actions in SwiftUI iOS applications.

## Features

- ℹ️ All navigation related actions handled via `NavRouter` utility
- 🧭 Switching Tabs, Pushing new Screens, Presenting Sheets / Full Screen Covers - with possibility to Push new screens within Modals as well
- 🚪 Removing of entire Screens stack (poping to root), Modals dismissal, presenting modal Sheets with custom detents
- 📱 Supports iOS 16 and newer
- 🧶 Thread safe (entire NavRouter type is isolated to *@MainActor*)


## Installation

Add following package dependency to Your Xcdoe project:

```swift
dependencies: [
  .package(url: "https://github.com/jassak1/NavRouter", from: "1.0.0")
]
```
    
## Setup

At core of every project is a `NavRouter` instance. `NavRouter` comprises of two Generic types:
- `NavTabs` - Contains all Tabs available in app
- `NavRoutes` - Contains all Navigation routes / screen destinations

**1. Create `NavTabs` type in app conforming to `NavTabItem`, ie:**
```swift
public enum NavigationTabs: NavTabItem {
    case homeTab
    case profileTab
    case settingsTab
}
```

**2. Create `NavRoutes` type in app conforming to `NavRouteItem`, ie:**
```swift
public enum NavigationRoutes: NavRouteItem {
    case detailView
    case contactView
    case aboutView
}
```

**3. Initiate a new `NavRouter` object with created types:**
```swift
@StateObject private var navRouter = NavRouter<NavigationTabs, NavigationRoutes>()
```

We advise to inject newly created instance to all Screens inside the app. The dependency framework is a choice of preference, altough in order to fully utilize all of the `NavRouter` features, it is advised to to use `.environmentObject` (`@EnvironmentObject`).

*Optional:* For simpler definition of NavRouter type without generics, create a typealias:

```swift
typealias NavigationRouter = NavRouter<NavigationTabs, NavigationRoutes>
```


**4. Create a new View containing all destination screens:**
```swift
struct NavDestinations: View {
    let navRoute: NavigationRoutes
    var body: some View {
        switch navRoute {
        case .detailView:
            DetailView()
        case .contactView:
            ContactView()
        case .aboutView:
            AboutView()
        }
    }
}
```

This View is used as a target source of truth for all Screens (`.navigationDestination`).

**5. Create a Tab View with all App's tab**

Here we can leverage the `NavRouter`'s own `NavWrapper` View for a convenient initialization of a View that will be wrapped around `NavigationStack`. Such View contains 3 parameters:
- `navPath`: Binding property used for programmatic navigation
- `screenView`: Source View *(Tab View)* that is wrapped
- `destinationView`: Target View with destination source of truth

```swift
TabView(selection: $navRouter.selectedTab) {
    Tab("Home", systemImage: "house", value: .homeTab) {
        NavWrapper(navPath: $navRouter[.homeTab],
                   screenView: HomeView(),
                   destinationView: {
            NavDestinations(navRoute: $0)
        })
    }
    Tab("About", systemImage: "person", value: .aboutTab) {
        NavWrapper(navPath: $navRouter[.fullScreenCover],
                   screenView: ProfileView(),
                   destinationView: {
            NavDestinations(navRoute: $0)
        })
    }
}
```
Note how we pass `$navRouter[`*NavigationTabs.value*`]` as a `navPath` binding property. This leverages `NavRouter`'s dictionary containing an unique navigation stack per each Tab. 

**6. Setup additional routing**

In case We plan to use `NavRouter`'s navigation also for modal Sheets and Full Screen Covers, We can setup additional routing by applying `setupAdditionalRouting` ViewModifier to the `TabView`.
```swift
.setupAdditionalRouting(NavigationTabs.self) {
    NavDestinations(navRoute: $0)
}
```

**7. Inject dependency**

Pass created `NavRouter` instance to Child Screens (Sub Views) by attaching `.environmentObject` ViewModifier to the `TabView`:
```swift
.environmentObject(navRouter)
```
## Usage

Using `NavRouter` is just as easy as calling any of its methods, or public properties on Main Thread:

- **Scenario 1:** New screen shall be pushed:

    ` navRouter.navigate(to: .detailView)`
- **Scenario 2:** Sheet shall be presented:

    ` navRouter.navigate(to: .detailView, navigationStyle: .sheet)`
- **Scenario 3:** Sheet with custom height shall be presented:
    
    Specify height of the sheet via `.sheetStyle` parameter specifying presentation detent size

    ` navRouter.navigate(to: .detailView, navigationStyle: .sheet, sheetStyle: .medium)`
- **Scenario 4:** Full Screen Cover shall be presented:

    ` navRouter.navigate(to: .detailView, navigationStyle: .fullScreenCover)`
- **Scenario 5:** New screen shall be pushed within a Modal (Sheet / Full Screen Cover):

    Simply call `navigate(to:...)` within a presented Modal:

    ` navRouter.navigate(to: .detailView)`

- **Scenario 6:** Dismiss presented Sheet / Full Screen Cover:

    `navRouter.dismissSheet()`

    `navRouter.dismissFullScreenCover()`
- **Scenario 7:** Pop to Root screen

    `navRouter.popToRoot()`

- **Scenario 8:** Change tab programmatically:

    `navRouter.selectedTab = .settingsTab`




## License

[This package is released under the MIT license.](https://github.com/jassak1/NavRouter/blob/main/LICENSE)

