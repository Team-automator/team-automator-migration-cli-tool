import Foundation

/// Maps UIKit components to SwiftUI-equivalent representations with necessary layout and content metadata.
///
/// Each case corresponds to a common UIKit component and holds values needed to convert it to a SwiftUI view.
///
/// - Cases:
///   - UILabel: Represents a label with `text`, `frame`, `constraints`, and `element ID`.
///   - UIButton: Represents a button with `title`, `frame`, `constraints`, and `element ID`.
///   - UITextField: Represents a text field with `placeholder`, `frame`, `constraints`, and `element ID`.
///   - Spacer: Represents vertical space with a `height` and `element ID`.
///   - UIImageView: Represents an image with `image name`, `frame`, `constraints`, and `element ID`.
///   - UITextView: Represents a text view with `text`, `frame`, `constraints`, and `element ID`.
///   - UISlider: Represents a slider with `initial value`, `frame`, `constraints`, and `element ID`.
///   - UISwitch: Represents a toggle with `initial on/off state`, `frame`, `constraints`, and `element ID`.
///   - UIPickerView: Represents a picker with a list of `options`, `frame`, `constraints`, and `element ID`.
///   - UIDatePicker: Represents a date picker with `date`, `frame`, `constraints`, and `element ID`.
///   - UITableView: Represents a table view with `frame`, `constraints`, and `element ID`.
///   - UIScrollView: Represents a scroll view with `frame` and `element ID`.
///   - hStack: Represents a horizontal stack containing nested components, along with its `frame`, `constraints`, `children`, and `element ID`.
enum UIComponentMapper {
    case UILabel(String, CGRect, String, String)
    case UIButton(String, CGRect, String, String)
    case UITextField(String, CGRect, String, String)
    case Spacer(CGFloat, String)
    case UIImageView(String, CGRect, String, String)
    case UITextView(String, CGRect, String, String)
    case UISlider(CGFloat, CGRect, String, String)
    case UISwitch(Bool, CGRect, String, String)
    case UIPickerView([String], CGRect, String, String)
    case UIDatePicker(Date, CGRect, String, String)
    case UITableView(CGRect, String, String)
    case UIScrollView(CGRect, String)
    case hStack(CGRect, String, [UIComponentMapper], String)
    case vStack(CGRect, String, [UIComponentMapper], String)

    var id: String {
        switch self {
        case .UILabel(_, _, _, let elementID),
             .UIButton(_, _, _, let elementID),
             .UITextField(_, _, _, let elementID),
             .UIImageView(_, _, _, let elementID),
             .UITextView(_, _, _, let elementID),
             .UISlider(_, _, _, let elementID),
             .UISwitch(_, _, _, let elementID),
             .UIPickerView(_, _, _, let elementID),
             .UIDatePicker(_, _, _, let elementID),
             .UITableView(_, _, let elementID),
             .UIScrollView(_, let elementID),
             .hStack(_, _, _, let elementID),
             .vStack(_, _, _, let elementID),
             .Spacer(_, let elementID):
            return elementID
        }
    }

    var yPosition: CGFloat {
        switch self {
        case .UILabel(_, let frame, _, _),
             .UIButton(_, let frame, _, _),
             .UITextField(_, let frame, _, _),
             .UIImageView(_, let frame, _, _),
             .UITextView(_, let frame, _, _),
             .UISlider(_, let frame, _, _),
             .UISwitch(_, let frame, _, _),
             .UIPickerView(_, let frame, _, _),
             .UIDatePicker(_, let frame, _, _),
             .UITableView(let frame, _, _),
             .UIScrollView(let frame, _),
             .hStack(let frame, _, _, _),
             .vStack(let frame, _, _, _):
            return frame.origin.y
        case .Spacer(let height, _):
            return height
        }
    }

    func getBodyAsString(previousY: CGFloat?) -> String {
        var topPadding: String
        switch self {
        case .Spacer:
            topPadding = ""
        default:
            if let prevY = previousY {
                let delta = max(4, min(32, self.yPosition - prevY))
                topPadding = ".padding(.top, \(Int(delta)))"
            } else {
                topPadding = ""
            }
        }
        switch self {
        case .Spacer(let height, _):
            return "Spacer().padding(.vertical, \(Int(height)))"
        case .UILabel(let text, _, let constraints, _):
            return """
            Text("\(text)")
            \(topPadding)
            \(constraints)
            """
        case .UIButton(let title, _, let constraints, _):
            return """
            Button(action: { print("\(title) tapped!") }) {
                Text("\(title)")
            }
            \(topPadding)
            \(constraints)
            """
        case .UITextField(let placeholder, _, let constraints, _):
            return """
            TextField("\(placeholder)", text: .constant(""))
                .textFieldStyle(.roundedBorder)
            \(topPadding)
            \(constraints)
            """
        case .UIImageView(let imageName, _, let constraints, _):
            return """
            Image("\(imageName)")
                .resizable()
                .scaledToFit()
            \(topPadding)
            \(constraints)
            """
        case .UITextView(let text, _, let constraints, _):
            return """
            TextEditor(text: .constant("\(text)"))
            \(topPadding)
            \(constraints)
            """
        case .UISlider(let value, _, let constraints, _):
            return """
            Slider(value: .constant(\(value)), in: 0...100)
            \(topPadding)
            \(constraints)
            """
        case .UISwitch(let isOn, _, let constraints, _):
            return """
            Toggle(isOn: .constant(\(isOn))) {
                Text("Toggle")
            }
            \(topPadding)
            \(constraints)
            """
        case .UIPickerView(let options, _, let constraints, _):
            let joined = options.map { "\"\($0)\"" }.joined(separator: ", ")
            return """
            Picker("Select", selection: .constant(0)) {
                ForEach(0..<(options.count)) { index in
                    Text([\(joined)][index])
                }
            }
            .pickerStyle(.wheel)
            \(topPadding)
            \(constraints)
            """
        case .UIDatePicker(let date, _, let constraints, _):
            return """
            DatePicker("Select Date", selection: .constant(Date(timeIntervalSince1970: \(date.timeIntervalSince1970))))
                .datePickerStyle(.compact)
            \(topPadding)
            \(constraints)
            """
        case .UITableView(_, let constraints, _):
            return """
            List {
            }
            .listStyle(.plain)
            \(constraints)
            """
        case .UIScrollView(_, _):
            return """
            ScrollView {
            }
            """
        case .hStack(_, let constraints, let children, _):
            let content = children.map { $0.getBodyAsString(previousY: nil) }.joined(separator: "\n")
            return """
            HStack {
            \(content)
            }
            \(constraints)
            """
        case .vStack(_, let constraints, let children, _):
            let content = children.map { $0.getBodyAsString(previousY: nil) }.joined(separator: "\n")
            return """
            VStack {
            \(content)
            }
            \(constraints)
            """
        }
    }

    static func mapElement(_ subView: XMLElement) -> UIComponentMapper? {
        let frame = extractFrameAttributes(from: subView)
        let constraints = extractAndGetMappedSwiftUIConstraints(from: subView)
        let elementId = subView.attribute(forName: "id")?.stringValue ?? ""
        let stackDetails = extractChildrenFromHorizontalStackView(from: subView)
        let children = stackDetails.1
        
        switch subView.name {
        case "label":
            let text = subView.attribute(forName: "text")?.stringValue ?? "Label"
            return .UILabel(text, frame, constraints, elementId)

        case "button":
            let configTitle = subView.elements(forName: "buttonConfiguration")
                .first?.attribute(forName: "title")?.stringValue
            
            let titleFromState = subView.elements(forName: "state")
                .first(where: { $0.attribute(forName: "key")?.stringValue == "normal" })?
                .attribute(forName: "title")?.stringValue
            
            let fallbackTitle = subView.attribute(forName: "title")?.stringValue
            let title = configTitle ?? titleFromState ?? fallbackTitle ?? "Button"
            return .UIButton(title, frame, constraints, elementId)

        case "textField":
            let placeholder = subView.attribute(forName: "placeholder")?.stringValue ?? ""
            return .UITextField(placeholder, frame, constraints, elementId)

        case "imageView":
            let imageName = subView.attribute(forName: "image")?.stringValue ?? "photo"
            return .UIImageView(imageName, frame, constraints, elementId)

        case "textView":
            let text = subView.elements(forName: "text").first?.stringValue ?? ""
            return .UITextView(text, frame, constraints, elementId)

        case "slider":
            let value = Double(subView.attribute(forName: "value")?.stringValue ?? "50") ?? 50
            return .UISlider(CGFloat(value), frame, constraints, elementId)

        case "switch":
            let isOn = subView.attribute(forName: "on")?.stringValue == "YES"
            return .UISwitch(isOn, frame, constraints, elementId)

        case "pickerView":
            let options = subView.elements(forName: "pickerOption").compactMap {
                $0.attribute(forName: "title")?.stringValue }
            return .UIPickerView(options.isEmpty ? ["Option 1", "Optoins 2"] : options, frame, constraints, elementId)

        case "datePicker":
            let timeStamp = Double(subView.attribute(forName: "timestamp")?.stringValue ?? "\(Date().timeIntervalSince1970)") ?? Date().timeIntervalSince1970
            return .UIDatePicker(Date(timeIntervalSince1970: timeStamp), frame, constraints, elementId)

        case "tableView":
            return .UITableView(frame, constraints, elementId)

        case "scrollView":
            return .UIScrollView(frame, elementId)

        case "stackView":
            switch stackDetails.0 {
            case "horizantal":
                return .hStack(frame, constraints, children, elementId)
            default:
                return .vStack(frame, constraints, children, elementId)
            }
        default:
            return nil
        }
    }
    
    static func extractAndGetMappedSwiftUIConstraints(from element: XMLElement) -> String {
        guard let constraintElement = element.elements(forName: "constraints").first else {
            return ""
        }
        var mappedSwiftUIConstraints = ""
        let constraints = constraintElement.elements(forName: "constraint")
        for constraint in constraints {
            let firstItem = constraint.attribute(forName: "firstItem")?.stringValue ?? "unknown"
            let firstAttribute = constraint.attribute(forName: "firstAttribute")?.stringValue ?? ""
            let secondItem = constraint.attribute(forName: "secondItem")?.stringValue ?? "view"
            let secondAttribute = constraint.attribute(forName: "secondAttribute")?.stringValue ?? ""
            let constant = constraint.attribute(forName: "constant")?.stringValue ?? "0"
            let relation = constraint.attribute(forName: "relation")?.stringValue ?? "equal"
            let mappedSwiftUIConstraint = generateSwiftUIEquivalentConstraint(first: firstItem, attr: firstAttribute, second: secondItem, secondAttr: secondAttribute, constant: constant, relation: relation)
            mappedSwiftUIConstraints += "\(mappedSwiftUIConstraint)\n"
        }
        return mappedSwiftUIConstraints
    }
    
    static func generateSwiftUIEquivalentConstraint(first: String, attr: String, second: String, secondAttr: String, constant: String, relation: String) -> String {
        switch attr {
        case "leading": return ".padding(.leading, \(constant))"
        case "top": return ".padding(.top, \(constant))"
        case "bottom": return ".padding(.bottom, \(constant))"
        case "trailing": return ".padding(.trailing, \(constant))"
        case "centerX": return ".frame(maxWidth: .infinity, alignment: .center)"
        case "centerY": return ".frame(maxHeight: .infinity, alignment: .center)"
        case "width": return ".frame(width: \(constant))"
        case "height": return ".frame(height: \(constant))"
        default:
            return ""
        }
    }
    
    static func extractFrameAttributes(from element: XMLElement) -> CGRect {
        guard let rectElement = element.elements(forName: "rect")
            .first(where: { $0.attribute(forName: "key")?.stringValue == "frame" }) else {
            return CGRect(x: 0, y: 0, width: 100, height: 50)
        }
        let x = Double(rectElement.attribute(forName: "x")?.stringValue ?? "0") ?? 0
        let y = Double(rectElement.attribute(forName: "y")?.stringValue ?? "0") ?? 0
        let width = Double(rectElement.attribute(forName: "width")?.stringValue ?? "100") ?? 100
        let height = Double(rectElement.attribute(forName: "height")?.stringValue ?? "50") ?? 50
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
