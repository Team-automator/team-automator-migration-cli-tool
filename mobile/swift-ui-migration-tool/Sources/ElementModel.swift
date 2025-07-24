import Foundation

/// Represents a screen node in the storyboard.
///
/// - Parameters:
///   - id: Unique identifier for the screen node.
///   - storyboardID: The storyboard ID of the view controller.
///   - vcElement: The XML element representing the view controller in the storyboard.
struct ScreenNode: Identifiable {
    var id: String
    var storyboardID: String
    var vcElement: XMLElement
}

/// Represents a complete navigation flow starting from a root screen.
///
/// - Parameters:
///   - id: Unique identifier for the navigation flow.
///   - root: The root screen of the flow.
///   - allScreens: All screens involved in the flow.
struct NavigationFlowModel: Identifiable {
    var id: String
    var root: ScreenNode
    var allScreens: [ScreenNode]
}

/// Represents a tab bar controller's child navigation controller and view controller.
///
/// - Parameters:
///   - naviID: The storyboard ID of the navigation controller.
///   - vcID: The storyboard ID of the view controller.
///   - vcClass: The class name of the view controller.
///   - vcElement: The XML element for the view controller.
struct TabBarControllerElement {
    let naviID: String
    let vcID: String
    let vcClass: String
    let vcElement: XMLElement
}

/// Represents a navigation link like a segue or relationship between view controllers.
///
/// - Parameters:
///   - type: The type of navigation (e.g., segue, relationship).
///   - identifier: Unique ID of the navigation element.
///   - viewControllerElement: The view controller's XML element that contains this navigation.
///   - attributes: Additional attributes related to the navigation.
struct NavigationElement {
    let type: String
    let identifier: String
    let viewControllerElement: XMLElement
    let attributes: [String: String]
}
