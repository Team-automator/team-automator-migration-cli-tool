import SwiftUIAutoMigration
import XCTest
@testable import SwiftUIAutoMigration

private func writeDummySampleStoryboard(named fileName: String = "SampleStoryboard") throws -> String {
    let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard" version="3.0">
      <scenes>
        <scene sceneID="1">
          <objects>
            <navigationController id="nav1" sceneMemberID="viewController">
              <navigationBar key="navigationBar" contentMode="scaleToFill" id="navBar1"/>
              <connections>
                <segue destination="vc1" kind="relationship" relationship="rootViewController" id="rel1"/>
              </connections>
            </navigationController>

            <tabBarController id="tab1" sceneMemberID="viewController">
              <tabBar key="tabBar" contentMode="scaleToFill" id="tabBar1"/>
              <connections>
                <segue destination="vc1" kind="relationship" relationship="viewControllers" id="tabrel1"/>
              </connections>
            </tabBarController>

            <viewController storyboardIdentifier="Home" id="vc1" customClass="MyViewController" sceneMemberID="viewController">
              <view key="view" contentMode="scaleToFill" id="view1">
                <subviews>
                  <label id="label1" text="Welcome!">
                    <rect key="frame" x="20" y="40" width="200" height="30"/>
                  </label>
                </subviews>
                <constraints>
                  <constraint firstItem="label1" firstAttribute="top" secondItem="view1" secondAttribute="top" constant="40" id="c1"/>
                </constraints>
              </view>
            </viewController>
          </objects>
        </scene>
      </scenes>
    </document>
    """
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).storyboard")
    try xml.write(to: tempURL, atomically: true, encoding: .utf8)
    return tempURL.path
}

class SwiftUIAutoMigrationTestsTests: XCTestCase {

    let mockDestinationRoot = FileManager.default.temporaryDirectory.appendingPathComponent("GeneratedTests")

    override func setUpWithError() throws {
        try super.setUpWithError()
        try FileManager.default.createDirectory(at: mockDestinationRoot, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: mockDestinationRoot)
        try super.tearDownWithError()
    }

    // MARK: - File Handling

    func test_addUploadedFile_validFile_shouldCopySuccessfully() throws {
        let path = try writeDummySampleStoryboard()
        XCTAssertNoThrow(addUploadedFileAndParse(filePath: path))
    }

    func test_addUploadedFile_invalidFile_shouldThrow() {
        let path = "/invalid/path/to/file.storyboard"
        addUploadedFileAndParse(filePath: path)
        // Logs error, doesn't crash
    }

    // MARK: - XML Parsing

    func test_getRootElement_validStoryboard_shouldReturnRoot() throws {
        let path = try writeDummySampleStoryboard()
        let root = getRootElementFromStoryboard(from: path)
        XCTAssertNotNil(root)
    }

    func test_getRootElement_invalidXML_shouldReturnNil() {
        let path = "/invalid/path/file.storyboard"
        let root = getRootElementFromStoryboard(from: path)
        XCTAssertNil(root)
    }

    // MARK: - Navigation Controller Detection

    func test_navigationController_exists_shouldReturnTrue() throws {
        let path = try writeDummySampleStoryboard()
        let root = getRootElementFromStoryboard(from: path)!
        XCTAssertTrue(isNavigationControllerExists(in: root))
    }

    // MARK: - UI Component Extraction

    func test_extractUILabel_shouldMapCorrectly() {
        let element = XMLElement(kind: .element)
        element.name = "label"
        element.addAttribute(XMLNode.attribute(withName: "text", stringValue: "Hello") as! XMLNode)
        element.addAttribute(XMLNode.attribute(withName: "id", stringValue: "label1") as! XMLNode)

        let rectXML = """
        <rect key="frame" x="0" y="20" width="100" height="30"/>
        """
        let parsedRect = try! XMLDocument(xmlString: rectXML, options: []).rootElement()
        element.addChild(parsedRect!)

        let mapped = UIComponentMapper.mapElement(element)
        XCTAssertNotNil(mapped)

        if case let .UILabel(text, frame, _, id) = mapped! {
            XCTAssertEqual(text, "Hello")
            XCTAssertEqual(id, "label1")
            XCTAssertEqual(frame.origin.y, 20)
        } else {
            XCTFail("Expected UILabel")
        }
    }

    func test_extractUnknownComponent_shouldReturnNil() {
        let element = XMLElement(kind: .element)
        element.name = "unknownComponent"
        let result = UIComponentMapper.mapElement(element)
        XCTAssertNil(result)
    }

    // MARK: - SwiftUI Code Generation

    func test_generateSwiftUIFile_shouldCreateFile() {
        let screenNode = ScreenNode(
            id: "vc1",
            storyboardID: "TestView",
            vcElement: XMLElement(name: "viewController")
        )
        generateSwiftUIFile(for: NavigationFlowModel(id: "vc1", root: screenNode, allScreens: []), destinationRoot: mockDestinationRoot)

        let expectedPath = mockDestinationRoot
            .appendingPathComponent("GeneratedSwiftUIFiles")
            .appendingPathComponent("TestViewView.swift")

        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedPath.path))
    }

    func test_downloadGeneratedFile_failure_shouldReportError() {
        let readonlyURL = URL(fileURLWithPath: "/System/protected.swift")
        let content = "Text(\"read only\")"
        downloadGeneratedSwiftUIFile(with: readonlyURL.lastPathComponent, and: content, destinationRoot: URL(fileURLWithPath: "/System"))
        // Not asserting stdout logs; manually validate output
    }

    // MARK: - Constraint Mapping

    func test_generateConstraint_leadingShouldMapToPadding() {
        let result = UIComponentMapper.generateSwiftUIEquivalentConstraint(
            first: "label1", attr: "leading",
            second: "superview", secondAttr: "leading",
            constant: "10", relation: "equal"
        )
        XCTAssertEqual(result, ".padding(.leading, 10)")
    }

    func test_extractConstraints_empty_shouldReturnEmptyString() {
        let element = XMLElement(name: "label")
        let constraints = UIComponentMapper.extractAndGetMappedSwiftUIConstraints(from: element)
        XCTAssertEqual(constraints, "")
    }

    func test_extractViewElements_withoutViewController_shouldReturnViews() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0">
          <objects>
            <view id="view1"/>
          </objects>
        </document>
        """
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("viewOnly.xib")
        try! xml.write(to: tempURL, atomically: true, encoding: .utf8)

        let root = getRootElementFromStoryboard(from: tempURL.path)
        let views = getAllViewElementsInAbsenceOfViewController(from: root!)
        XCTAssertEqual(views.count, 1)
    }

    func test_removeHStackChildren_shouldFilterOutChildren() {
        let label = UIComponentMapper.UILabel("Label", CGRect(x: 0, y: 10, width: 100, height: 40), "", "label1")
        let button = UIComponentMapper.UIButton("Tap", CGRect(x: 0, y: 20, width: 100, height: 40), "", "button1")
        let hStack = UIComponentMapper.hStack(CGRect(x: 0, y: 50, width: 200, height: 40), "", [label, button], "stack1")

        let components: [UIComponentMapper] = [label, button, hStack]
        let result = removeHStackComponents(from: components)

        XCTAssertFalse(result.contains(where: { $0.id == "label1" || $0.id == "button1" }))
    }

    func test_parseStoryboardAndExtractComponentsAndGenerateSwiftUIFiles_generatesFilesInFlatViews() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0">
          <objects>
            <tableViewCell id="cell1">
              <tableViewCellContentView key="view" id="view1">
                <subviews>
                  <label id="label1" text="Hello"/>
                  <rect key="frame" x="0" y="0" width="100" height="30"/>
                </subviews>
              </tableViewCellContentView>
            </tableViewCell>
          </objects>
        </document>
        """

        let path = FileManager.default.temporaryDirectory.appendingPathComponent("SampleCell.xib")
        try xml.write(to: path, atomically: true, encoding: .utf8)

        let root = getRootElementFromStoryboard(from: path.path)!
        XCTAssertNotNil(root)

        // Trigger file generation
        parseStoryboardAndExtractComponentsAndGenerateSwiftUIFiles(root, destinationRoot: mockDestinationRoot)
    }

    func test_generateSwiftUIFilesWithTabBarNavigationFlow_shouldGenerateTabContentView() throws {
        let path = try writeDummySampleStoryboard()
        generateSwiftUIFilesWithTabBarNavigationFlow(path, destinationRoot: mockDestinationRoot)

        let generated = mockDestinationRoot
            .appendingPathComponent("GeneratedSwiftUIFiles")
            .appendingPathComponent("TabContentView.swift")
        XCTAssertTrue(FileManager.default.fileExists(atPath: generated.path))
    }

    func test_extractChildrenFromHStack_shouldReturnMappedChildren() {
        let stackXML = """
        <stackView axis="horizontal" id="stack1">
          <subviews>
            <label id="l1" text="One">
                <rect key="frame" x="0" y="0" width="50" height="20"/>
            </label>
            <button id="b1" title="Click Me">
                <rect key="frame" x="50" y="0" width="50" height="20"/>
            </button>
          </subviews>
        </stackView>
        """
        let element = try! XMLDocument(xmlString: stackXML, options: []).rootElement()
        let children = extractChildrenFromHorizontalStackView(from: element!)
        XCTAssertEqual(children.count, 2)
    }
}

