// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreGraphics

func promptForStoryboardOrXibFilePathAndGenerateSwiftUICode() {
    let _ = Notifier()
    print("Enter the path to your storyboard/xib file to migrate:")
    if let filePath = readLine(), !filePath.isEmpty {
        addUploadedFileAndParse(filePath: filePath)
    } else {
        print("No file selected.")
    }
}

func addUploadedFileAndParse(filePath: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        .replacingOccurrences(of: "/", with: "-")
        .replacingOccurrences(of: " ", with: "_")
        .replacingOccurrences(of: ",", with: "-")
    let uniqueFolderName = "StoryboardConverter_\(timestamp)"
    let destinationFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        .appendingPathComponent(uniqueFolderName)
    do {
        try FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
        let destinationURL = destinationFolder.appendingPathComponent(fileURL.lastPathComponent)
        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
        print("🥳 File added successfully to \(destinationURL.path)")
        if let root = getRootElementFromStoryboard(from: filePath) {
            printExtractedComponents(from: root)
            let tabBarExists = !getAllTabBarViewControllerElements(from: root).isEmpty
            if tabBarExists {
                print("✨ Tab bar controller detected. Generating SwiftUI code for tab bar...")
                generateSwiftUIFilesWithTabBarNavigationFlow(filePath, destinationRoot: destinationFolder)
            } else if isNavigationControllerExists(in: root) {
                generateSwiftUIFilesWithNavigationFlow(filePath, destinationRoot: destinationFolder)
            } else {
                parseStoryboardAndExtractComponentsAndGenerateSwiftUIFiles(root, destinationRoot: destinationFolder)
            }
        } else {
            print("❌ Failed to parse storyboard.")
        }
    } catch {
        print("❌ Error adding file: \(error.localizedDescription)")
    }
}

func generateSwiftUIFile(for screenNode: NavigationFlowModel, destinationRoot: URL) {
    let swiftUICode = generateSwiftUIView(for: screenNode)
    let generatedFolder = destinationRoot.appendingPathComponent("GeneratedSwiftUIFiles")
    do {
        try FileManager.default.createDirectory(at: generatedFolder, withIntermediateDirectories: true)
        let fileURL = generatedFolder.appendingPathComponent("\(screenNode.root.storyboardID)View.swift")
        try swiftUICode.write(to: fileURL, atomically: true, encoding: .utf8)
        print("✅ SwiftUI view generated successfully at \(fileURL.path)")
    } catch {
        print("❌ SwiftUI view generation failed: \(error.localizedDescription)")
    }
}

func downloadGeneratedSwiftUIFile(with fileName: String, and content: String, destinationRoot: URL) {
    let generatedFolder = destinationRoot.appendingPathComponent("GeneratedSwiftUIFiles")
    do {
        try FileManager.default.createDirectory(at: generatedFolder, withIntermediateDirectories: true)
        let fileURL = generatedFolder.appendingPathComponent(fileName)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        print("✅ File created successfully at \(fileURL.path)")
    } catch {
        print("❌ Failed to create file: \(error.localizedDescription)")
    }
}

func getRootElementFromStoryboard(from filePath: String) -> XMLElement? {
    let url = URL(fileURLWithPath: filePath)
    do {
        let document = try XMLDocument(contentsOf: url, options: [])
        return document.rootElement()
    } catch {
        print("Error parsing storyboard XML: \(error.localizedDescription)")
        return nil
    }
}

func getNavigationElementsFromStoryboard(from filePath: String) -> [NavigationElement] {
    let navElements = NavigationFlowHandler().getNavigationElements(from: filePath)
    return navElements
}

func getAllViewElementsInAbsenceOfViewController(from root: XMLElement) -> [XMLElement] {
    root.elements(forName: "objects").first?
        .elements(forName: "view") ?? []
}

private func getViewSubType(from root: XMLElement) -> InputFileViewSubtype {
    if root.elements(forName: "objects").first?
        .elements(forName: "tableViewCell").isEmpty ?? false {
        return .tableViewCell
    }
    return .tableViewCell
}

private func getAllViewControllerElements(from root: XMLElement) -> [XMLElement] {
    root.elements(forName: "scenes").first?
        .elements(forName: "scene")
        .flatMap { $0.elements(forName: "objects") }
        .flatMap { $0.elements(forName: "viewController") } ?? []
}

func isNavigationControllerExists(in root: XMLElement) -> Bool {
    if let scenes = root.elements(forName: "scenes").first {
        let sceneObjects = scenes.elements(forName: "scene")
        if sceneObjects.count > 0 {
            let objects = sceneObjects.flatMap { $0.elements(forName: "objects") }
            return !objects.flatMap { $0.elements(forName: "navigationController") }.isEmpty
        }
    }
    return false
}

private func printExtractedComponents(from root: XMLElement) {
    let viewControllers = getAllViewControllerElements(from: root)
    for (index, viewController) in viewControllers.enumerated() {
        print("\n🛠 ViewController \(index + 1) XML Structure:")
        let subviewElements = extractAllUIComponents(from: viewController)
        for subview in subviewElements {
            let componentType = subview.name ?? "Unknown Component"
            let xmlString = subview.xmlString(options: .nodePrettyPrint)
            print("\n🧩 Component Type: \(componentType)\n\(xmlString)")
        }
    }
}

private func parseStoryboardAndExtractComponentsForSpecificVC(_ vcElement: XMLElement) -> [UIComponentMapper] {
    let original = extractAllUIComponents(from: vcElement)
        .compactMap { UIComponentMapper.mapElement($0) }
    let components = original.filter {
        switch $0 {
        case .UILabel(let text, let frame, _, _):
            return text != "Welcome! Please login" && frame.height > 1
        default:
            return true
        }
    }
    return components.sorted { $0.yPosition < $1.yPosition }
}

func generateSwiftUIFilesWithTabBarNavigationFlow(_ filePath: String, destinationRoot: URL) {
    let tabNavigationElements = NavigationFlowHandler().getTabNavigationElements(from: filePath)
    print("tab navigation elements \(tabNavigationElements.count)")
    var tabViewWithItems = """
        """
    for (index, tabNavigationElement) in tabNavigationElements.enumerated() {
        let viewName = tabNavigationElement.vcClass
        performExtractionAndGenerateSwiftUIFiles(from: tabNavigationElement.vcElement, fileName: "\(viewName)View.swift", destinationRoot: destinationRoot)
        let tabItemTitle = tabNavigationElement.vcElement.elements(forName: "tabBarItem").first?.attribute(forName: "title")?.stringValue ?? "tab \(index + 1)"
        let tabItemImageName = tabNavigationElement.vcElement.elements(forName: "tabBarItem").first?.attribute(forName: "image")?.stringValue ?? "house"

        tabViewWithItems += """
        .tabItem {
            Label("\(tabItemTitle)", systemImage: "\(tabItemImageName)")
        }
        """
    }
    let tabBarVCClassContent = """
    import SwiftUI
    struct TabContentView: View {
        var body: some View {
            TabView {
                \(tabViewWithItems)
            }
        }
        #if DEBUG
        #Preview {
            TabContentView()
        }
        #endif
    }
    """
    downloadGeneratedSwiftUIFile(with: "TabContentView.swift", and: tabBarVCClassContent, destinationRoot: destinationRoot)
}

private func generateSwiftUIFilesWithNavigationFlow(_ filePath: String, destinationRoot: URL) {
    let navigationElements = getNavigationElementsFromStoryboard(from: filePath)
    print("tab navigation elements \(navigationElements.count)")
    if let rootNode = buildNavigationFlow(from: navigationElements) {
        generateSwiftUIFile(for: rootNode, destinationRoot: destinationRoot)
        for vc in rootNode.allScreens {
            let components = parseStoryboardAndExtractComponentsForSpecificVC(vc.vcElement)
            if components.isEmpty {
                print("⚠️ No UI components found!")
            } else {
                print("✅ Extracted UI components: \(components)")
            }
            let filteredComponents = removeHStackComponents(from: components)
            var lastY: CGFloat? = nil
            let formattedComponents = filteredComponents.map { component -> String in
                let str = component.getBodyAsString(previousY: lastY)
                lastY = component.yPosition
                return str
            }.joined(separator: "\n\n")
            let content = """
                import SwiftUI
                struct \(vc.storyboardID)View: View {
                    var body: some View {
                        VStack {
                            Text("current view is \(vc.storyboardID)")
                            \(formattedComponents)
                        }
                        .padding()
                        .navigationTitle("\(vc.storyboardID)")
                    }
                    #if DEBUG
                    #Preview {
                        \(vc.storyboardID)View()
                    }
                    #endif
                }
                """
            downloadGeneratedSwiftUIFile(with: "\(vc.storyboardID)View.swift", and: content, destinationRoot: destinationRoot)
            
        }
    }
}

private func generateOtherSwiftUIFiles(for screenNode: NavigationFlowModel) -> String {
    var output = """
    import SwiftUI
    struct \(screenNode.root.storyboardID)View: View {
        var body: some View {
            NavigationStack {
                VStack {
    """
    for vc in screenNode.allScreens {
        output += """
        struct \(vc.storyboardID)View: View {
            var body: some View {
                Text("current view is \(vc.storyboardID)")
                .navigationTitle("\(vc.storyboardID)")
            }
        }
        #if DEBUG
        #Preview {
            \(vc.storyboardID)View()
        }
        #endif
        """
    }
    return output
}

private func generateSwiftUIView(for screenNode: NavigationFlowModel) -> String {
    var lastY: CGFloat? = nil
    let components = parseStoryboardAndExtractComponentsForSpecificVC(screenNode.root.vcElement)
    if components.isEmpty {
        print("⚠️ No UI components found!")
    } else {
        print("✅ Extracted UI components: \(components)")
    }
    let formattedComponents = components.map { component -> String in
        let str = component.getBodyAsString(previousY: lastY)
        lastY = component.yPosition
        return str
    }.joined(separator: "\n\n")
    var output = """
    import SwiftUI
    struct \(screenNode.root.storyboardID)View: View {
        var body: some View {
            NavigationStack {
                VStack {
    \(formattedComponents)
                }
    """
    for _ in screenNode.allScreens {
        output += """
                    NavigationLink("\\(vc.storyboardID)", destination: \\(vc.storyboardID)View())
        """
    }
    output += """
                }
                .navigationTitle("\\(screenNode.root.storyboardID)")
            }
        }
    #if DEBUG
    #Preview {
        \\(screenNode.root.storyboardID)View()
    }
    #endif
    """
    return output
}

 func parseStoryboardAndExtractComponentsAndGenerateSwiftUIFiles(_ root: XMLElement, destinationRoot: URL) {
    let viewControllers = getAllViewControllerElements(from: root)
    let inputFileViewType = viewControllers.isEmpty ? InputFileViewType.view : .viewController
    switch inputFileViewType {
    case .viewController:
        print("✨ Generating SwiftUI files for view controllers..")
        for (index, viewController) in viewControllers.enumerated() {
            performExtractionAndGenerateSwiftUIFiles(from: viewController, fileName: "GeneratedView\(index + 1).swift", destinationRoot: destinationRoot)
        }
    case .view:
        print("✨ Generating SwiftUI files for views...")
        let views = getAllViewElementsInAbsenceOfViewController(from: root)
        if views.isEmpty {
            let subType = getViewSubType(from: root)
            switch subType {
            case .tableViewCell:
                let tableViewCellView = subType.getView(from: root)
                let _ = extractAllUIComponents(from: tableViewCellView)
                performExtractionAndGenerateSwiftUIFiles(from: tableViewCellView, fileName: "\(subType.viewName).swift", destinationRoot: destinationRoot)
            }
        } else {
            for (index, view) in views.enumerated() {
                performExtractionAndGenerateSwiftUIFiles(from: view, fileName: "GeneratedView\(index + 1).swift", destinationRoot: destinationRoot)
            }
        }
    }
}

private func performExtractionAndGenerateSwiftUIFiles(from element: XMLElement, fileName: String, destinationRoot: URL) {
    let components = parseStoryboardAndExtractComponentsForSpecificVC(element)
    if components.isEmpty {
        print("⚠️ No UI components found!")
    } else {
        print("✅ Extracted UI components: \(components)")
        let swiftUIViewCode = generateSwiftUIViewCode(from: components)
        downloadGeneratedSwiftUIFile(with: fileName, and: swiftUIViewCode, destinationRoot: destinationRoot)
    }
}

private func getAllTabBarViewControllerElements(from root: XMLElement) -> [XMLElement] {
    root.elements(forName: "scenes").first?
        .elements(forName: "scene")
        .flatMap { $0.elements(forName: "objects") }
        .flatMap { $0.elements(forName: "tabBarController") } ?? []
}

private func extractAllUIComponents(from element: XMLElement) -> [XMLElement] {
    var results: [XMLElement] = []
    func collect(from node: XMLElement?) {
        for child in node?.children ?? [] {
            if let elem = child as? XMLElement {
                results.append(elem)
                collect(from: elem)
            }
        }
    }
    collect(from: element)
    return results
}

private func generateSwiftUIViewCode(from components: [UIComponentMapper]) -> String {
    var lastY: CGFloat? = nil
    let formattedComponents = components.map { component -> String in
        let str = component.getBodyAsString(previousY: lastY)
        lastY = component.yPosition
        return str
    }.joined(separator: "\n\n")

    return """
    import SwiftUI

    struct GeneratedView: View {
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                \(formattedComponents)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.white)
        }
    }
    
    #if DEBUG
    #Preview {
        GeneratedView()
    }
    #endif
    """
}

func buildNavigationFlow(from navigationElements: [NavigationElement]) -> NavigationFlowModel? {
    let vcs = navigationElements.filter { $0.type == "viewController" }
    let segues = navigationElements.filter { $0.type == "segue" }
    guard let rootRelationShip = segues.filter({$0.attributes["relationship"] == "rootViewController"}).first,
          let rootID = rootRelationShip.attributes["destination"], let vc = vcs.filter({ $0.identifier == rootID }).first else {
        return nil
    }
    let otherThanRootSegues = segues.filter({$0.attributes["kind"] == "push" || $0.attributes["kind"] == "show" || $0.attributes["kind"] == "presentation" || $0.attributes["kind"] == "model" })
    var children: [ScreenNode] = []
    for segue in otherThanRootSegues {
        if let destinationID = segue.attributes["destination"] {
            let destinationVC = vcs.filter({$0.identifier == destinationID}).first
            if let destinationVC = destinationVC {
                children.append(ScreenNode(id: destinationID, storyboardID: destinationVC.attributes["storyboardIdentifier"] ?? "Screen", vcElement: destinationVC.viewControllerElement))
            }
        }
    }
    return NavigationFlowModel(id: rootID, root: ScreenNode(id: rootID, storyboardID: vc.attributes["storyboardIdentifier"] ?? "Screen", vcElement: vc.viewControllerElement), allScreens: children)
}

func extractChildrenFromHorizontalStackView(from element: XMLElement) -> (String, [UIComponentMapper]) {
    guard element.name == "stackView" else { return ("", []) }
    let stackType = element.attribute(forName: "axis")?.stringValue ?? "horizontal"
    guard let stackSubviews = try? element.nodes(forXPath: ".//subviews/*") else { return ("", []) }
    var stackSubViewIDs: [String] = []
    var children: [UIComponentMapper] = []
    for case let subView as XMLElement in stackSubviews {
        stackSubViewIDs.append(subView.attribute(forName: "id")?.stringValue ?? "unknown")
        if let stackSubView = UIComponentMapper.mapElement(subView) {
            children.append(stackSubView)
        }
    }
    return (stackType, children)
}

func removeHStackComponents(from allComponents: [UIComponentMapper]) -> [UIComponentMapper] {
    let hstackChildIds = allComponents.compactMap { component -> [String]? in
        if case .hStack(_, _, let children, _) = component {
            return children.compactMap { $0.id }
        }
        return nil
    }.flatMap { $0 }
    let hstackIDSet = Set(hstackChildIds)
    return allComponents.filter { component in
        let componentId = component.id
        return !hstackIDSet.contains(componentId)
    }
}

// Run the script
promptForStoryboardOrXibFilePathAndGenerateSwiftUICode()
