import SwiftUI

// MARK: - Alert

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Alert: KnownViewType {
        public static var typePrefix: String = ViewType.PopupContainer<Alert>.typePrefix
        public static var namespacedPrefixes: [String] { [typePrefix] }
        public static func inspectionCall(typeName: String) -> String {
            return "alert(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func alert(_ index: Int? = nil) throws -> InspectableView<ViewType.Alert> {
        return try contentForModifierLookup.alert(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func alert(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.Alert> {
        return try popup(parent: parent, index: index,
                         modifierPredicate: isAlertPresenter(modifier:),
                         standardPredicate: standardAlertModifier)
    }
    
    func standardAlertModifier() throws -> Any {
        return try self.modifier({
            $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
            || $0.modifierType.contains("AlertTransformModifier")
        }, call: "alert")
    }
    
    func alertsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter(isAlertPresenter(modifier:))
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.alert(parent: parent, index: index)
            })
        }
    }
    
    private func isAlertPresenter(modifier: Any) -> Bool {
        let modifier = try? Inspector.attribute(
            label: "modifier", value: modifier, type: BasePopupPresenter.self)
        return modifier?.isAlertPresenter == true
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Alert {

    func title() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func message() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func primaryButton() throws -> InspectableView<ViewType.AlertButton> {
        return try View.supplementaryChildren(self).element(at: 2)
            .asInspectableView(ofType: ViewType.AlertButton.self)
    }
    
    func secondaryButton() throws -> InspectableView<ViewType.AlertButton> {
        return try View.supplementaryChildren(self).element(at: 3)
            .asInspectableView(ofType: ViewType.AlertButton.self)
    }
    
    func dismiss() throws {
        let container = try Inspector.cast(
            value: content.view, type: ViewType.PopupContainer<ViewType.Alert>.self)
        container.presenter.dismissPopup()
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Alert: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 4) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            switch index {
            case 0:
                let view = try Inspector.attribute(path: "popup|title", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "title()")
            case 1:
                let maybeView = try Inspector.attribute(
                    path: "popup|message", value: parent.content.view, type: Text?.self)
                guard let view = maybeView else {
                    throw InspectionError.viewNotFound(parent: "message")
                }
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "message()")
            case 2:
                let view = try Inspector.attribute(path: "popup|primaryButton", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.AlertButton>(
                    content, parent: parent, call: "primaryButton()")
            default:
                let maybeView = try Inspector.attribute(
                    path: "popup|secondaryButton", value: parent.content.view, type: Alert.Button?.self)
                guard let view = maybeView else {
                    throw InspectionError.viewNotFound(parent: "secondaryButton")
                }
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.AlertButton>(
                    content, parent: parent, call: "secondaryButton()")
            }
        }
    }
}

// MARK: - AlertButton

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct AlertButton: KnownViewType {
        public static var typePrefix: String = "Alert.Button"
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension SwiftUI.Alert.Button: CustomViewIdentityMapping {
    var viewTypeForSearch: KnownViewType.Type { ViewType.AlertButton.self }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.AlertButton: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 1) { _ in
            let child = try Inspector.attribute(path: "label", value: parent.content.view)
            let medium = parent.content.medium.resettingViewModifiers()
            let content = try Inspector.unwrap(content: Content(child, medium: medium))
            return try InspectableView<ViewType.Text>(content, parent: parent, call: "labelView()")
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Alert.Button {
    enum Style: String {
        case `default`, cancel, destructive
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.AlertButton {
    
    func labelView() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func style() throws -> Alert.Button.Style {
        let value = try Inspector.attribute(label: "style", value: content.view)
        let stringValue = String(describing: value)
        guard let style = Alert.Button.Style(rawValue: stringValue) else {
            throw InspectionError.notSupported("Unknown Alert.Button.Style: \(stringValue)")
        }
        return style
    }
    
    func tap() throws {
        guard let container = self.parentView?.content.view,
            let presenter = try? Inspector.attribute(
                label: "presenter", value: container,
                type: BasePopupPresenter.self)
        else { throw InspectionError.parentViewNotFound(view: "Alert.Button") }
        presenter.dismissPopup()
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(label: "action", value: content.view, type: Callback.self)
        callback()
    }
}
