import Foundation

/// Defines the type of view described in the input file.
///
/// - Parameters:
///   - viewController: Represents a full `UIViewController`.
///   - view: Represents a standalone `UIView`.
enum InputFileViewType: String {
    case viewController = "viewController"
    case view = "view"
}

/// Defines the subtype of views for specialized extraction and provides helper methods.
///
/// - Parameters:
///   - tableViewCell: Represents a `UITableViewCell` view.
///
/// - Properties:
///   - viewName: Returns a custom string name used internally to identify this view.
/// - Methods:
///   - getView(from:): Extracts the relevant `XMLElement` from the XML hierarchy based on subtype.
enum InputFileViewSubtype: String {
    case tableViewCell = "tableViewCell"

    /// A human-readable or internal name for the view subtype.
    var viewName: String {
        switch self {
        case .tableViewCell: return "TableCellContentView"
        }
    }

    /// Extracts the appropriate view element from the given XML root based on subtype.
    ///
    /// - Parameter root: The root XML element representing the file.
    /// - Returns: The matching `XMLElement` if found, or an empty `XMLElement` if not.
    func getView(from root: XMLElement) -> XMLElement {
        switch self {
        case .tableViewCell:
            if let tableViewCellContentView = root.elements(forName: "objects").first?
                .elements(forName: "tableViewCell").first?
                .elements(forName: "tableViewCellContentView").first {
                return tableViewCellContentView
            }
        }
        return XMLElement()
    }
}
