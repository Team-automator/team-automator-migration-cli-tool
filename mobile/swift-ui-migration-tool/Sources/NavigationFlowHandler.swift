import Foundation

class NavigationFlowHandler {
    init() { }

    func getNavigationElements(from filePath: String) -> [NavigationElement] {
        var elements: [NavigationElement] = []
        let url = URL(fileURLWithPath: filePath)
        let queries = [("navigationController", "//navigationController"),
                       ("viewController", "//*[local-name()='viewController']"),
                       ("relationship", "//relationship"),
                       ("segue", "//segue")]

        do {
            let document = try XMLDocument(contentsOf: url, options: [.nodePreserveAll])
            for (type, xpath) in queries {
                if let elementsNode = try? document.nodes(forXPath: xpath) as? [XMLElement] ?? [] {
                    for elementNode in elementsNode {
                        let id = elementNode.attribute(forName: "id")?.stringValue ?? "unknown"
                        var attributes: [String: String] = [:]
                        for attr in elementNode.attributes ?? [] {
                            if let name = attr.name, let value = attr.stringValue {
                                attributes[name] = value
                            }
                        }
                        elements.append(NavigationElement(type: type, identifier: id, viewControllerElement: type == "viewController" ? elementNode : XMLElement(), attributes: attributes))
                    }
                }
            }
        } catch {
            print("Error parsing storyboard XML: \(error.localizedDescription)")
        }
        return elements
    }

    func getTabNavigationElements(from filePath: String) -> [TabBarControllerElement] {
        var elements: [TabBarControllerElement] = []
        let url = URL(fileURLWithPath: filePath)
        do {
            let document = try XMLDocument(contentsOf: url, options: .nodePreserveAll)
            let tabBarControllerNodes = try document.nodes(forXPath: "//tabBarController") as? [XMLElement] ?? []
            for tabBarControllerNode in tabBarControllerNodes {
                let segues = try tabBarControllerNode.nodes(forXPath: ".//segue[@relationship='viewControllers']") as? [XMLElement] ?? []
                for segue in segues {
                    let naviID = segue.attribute(forName: "destination")?.stringValue ?? ""
                    let vcID = segue.attribute(forName: "id")?.stringValue ?? ""
                    let vcNode = try document.nodes(forXPath: "//viewController[@id='\(naviID)']").first as? XMLElement
                    let vcClass = vcNode?.attribute(forName: "customClass")?.stringValue ?? ""
                    elements.append(TabBarControllerElement(naviID: naviID, vcID: vcID, vcClass: vcClass, vcElement: vcNode ?? XMLElement()))
                }
            }
        } catch {
            print("Error parsing storyboard XML: \(error.localizedDescription)")
        }
        return elements
    }
}
