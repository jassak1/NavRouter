import Testing
@testable import NavRouter

@MainActor
@Suite("NavRouter Test Suite")
struct NavRouterTests {
    let navRouter = NavRouter<TestNavTabItem, TestNavRouteItem>()
    
    @Test(.tags(.initTests), arguments: [TestNavTabItem.homeTab, .aboutTab, .settingsTab])
    func initSelectedTab(navTabItem: TestNavTabItem) async throws {
        #expect(navRouter.selectedTab == .homeTab)
        navRouter.selectedTab = navTabItem
        #expect(navRouter.selectedTab == navTabItem)
    }
    
    @Test(.tags(.initTests), arguments: [TestNavRouteItem.contactScreen, .detailScreen, .notificationsScreen])
    func initNavPaths(navRouteItem: TestNavRouteItem) async throws {
        #expect(navRouter[.homeTab].isEmpty)
        navRouter.navigate(to: navRouteItem)
        #expect(navRouter[.homeTab].count == 1)
    }
    
    @Test(.tags(.initTests), arguments: [TestNavRouteItem.contactScreen, .detailScreen, .notificationsScreen])
    func initAdditionalStylesPaths(navRouteItem: TestNavRouteItem) async throws {
        #expect(navRouter[.sheet] == nil)
        #expect(navRouter[.fullScreenCover] == nil)
        navRouter.navigate(to: navRouteItem, navigationStyle: .sheet)
        #expect(navRouter[.sheet] != nil)
        #expect(navRouter[.fullScreenCover] == nil)
        navRouter.navigate(to: navRouteItem, navigationStyle: .fullScreenCover)
        navRouter.dismissSheet()
        #expect(navRouter[.sheet] == nil)
        #expect(navRouter[.fullScreenCover] != nil)
        navRouter.navigate(to: navRouteItem)
        navRouter.navigate(to: navRouteItem)
        #expect(navRouter[.sheet].count == 0)
        #expect(navRouter[.fullScreenCover].count == 2)
    }
    
    @Test(.tags(.navigateToTests))
    func navigateToPush() async throws {
        #expect(navRouter.selectedTab == .homeTab)
        navRouter.selectedTab = .settingsTab
        #expect(navRouter.selectedTab == .settingsTab)
        navRouter.navigate(to: .contactScreen)
        #expect(navRouter[.sheet].isEmpty)
        #expect(navRouter[.fullScreenCover].isEmpty)
        #expect(navRouter[.homeTab].isEmpty)
        #expect(navRouter[.settingsTab].count == 1)
        navRouter.navigate(to: .detailScreen)
        #expect(navRouter[.settingsTab].count == 2)
        navRouter.popToRoot()
        #expect(navRouter[.settingsTab].isEmpty)
    }
    
    @Test(.tags(.navigateToTests))
    func navigateToSheet() async throws {
        #expect(navRouter[.sheet] == nil)
        #expect(navRouter[.sheet].isEmpty)
        navRouter.navigate(to: .contactScreen, navigationStyle: .sheet)
        #expect(navRouter[.sheet] == .contactScreen)
        navRouter.navigate(to: .detailScreen)
        navRouter.navigate(to: .contactScreen)
        #expect(navRouter[.sheet] != nil)
        #expect(navRouter[.sheet].count == 2)
        navRouter.popToRoot()
        #expect(navRouter[.sheet].isEmpty)
        #expect(navRouter[.sheet] != nil)
        navRouter.dismissSheet()
        #expect(navRouter[.sheet] == nil)
    }
    
    @Test(.tags(.navigateToTests))
    func navigateToFullScreenCover() async throws {
        #expect(navRouter[.fullScreenCover] == nil)
        #expect(navRouter[.fullScreenCover].isEmpty)
        navRouter.navigate(to: .profileScreen, navigationStyle: .fullScreenCover)
        #expect(navRouter[.fullScreenCover] != nil)
        #expect(navRouter[.fullScreenCover].isEmpty)
        navRouter.navigate(to: .contactScreen)
        navRouter.navigate(to: .notificationsScreen)
        #expect(navRouter[.fullScreenCover].count == 2)
        navRouter.popToRoot()
        #expect(navRouter[.fullScreenCover].isEmpty)
        #expect(navRouter[.fullScreenCover] != nil)
        navRouter.dismissFullScreenCover()
        #expect(navRouter[.fullScreenCover] == nil)
    }
}
