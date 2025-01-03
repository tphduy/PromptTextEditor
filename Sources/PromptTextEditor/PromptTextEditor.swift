//
//  PromptTextEditor.swift
//  PromptTextEditor
//
//  Created by Duy Tran on 25/11/24.
//

import SwiftUI

/// A view that can display and edit long-form text or display a prompt when the editor's content is empty.
public struct PromptTextEditor: View {
    
    // MARK: States
    
    /// `true` when focus moves to the view, otherwise, `false`.
    @FocusState private var isFocused: Bool
    
    /// A `Binding` to the variable containing the text to edit.
    @Binding private var text: String
    
    /// A view that can display and edit long-form text.
    private let textEditor: TextEditor
    
    /// A text representing the prompt of the text editor which provides users with guidance on what to type into the text editor.
    private let prompt: Text?
    
    /// The inset distances for the sides of the prompt from the text editor.
    private let promptMargins: EdgeInsets
    
    /// `true` if the text editor is not focused the editable text is empty, otherwise, `false`.
    private var isShowingPrompt: Bool {
        !isFocused && text.isEmpty
    }
    
    /// An environment value that indicates how a text view aligns its lines when the content wraps or contains newlines.
    @Environment(\.multilineTextAlignment) var multilineTextAlignment: TextAlignment
    
    // MARK: Init
    
    /// Init a plain text editor.
    ///
    /// It hasn’t been possible to read the value of [contentMargins(_:for:)](https://developer.apple.com/documentation/swiftui/view/contentmargins(_:for:))  from the environment. Therefore, you must specify the same value for `promptMargins`. Otherwise, the text and the prompt won’t align.
    ///
    /// - Parameters:
    ///   - text: A `Binding` to the variable containing the text to edit.
    ///   - prompt: A text representing the prompt which provides users with guidance on what to type into.
    ///   - promptMargins: The inset distances for the sides of the prompt from the text editor. The default value zero, and the final result will be translated with the platform default margin of the `TextEditor`.
    public init(
        text: Binding<String>,
        prompt: Text? = nil,
        promptMargins: CGFloat
    ) {
        self.init(
            text: text,
            prompt: prompt,
            promptMargins: EdgeInsets(
                top: promptMargins,
                leading: promptMargins,
                bottom: promptMargins,
                trailing: promptMargins
            )
        )
    }
    
    /// Init a plain text editor.
    ///
    /// It hasn’t been possible to read the value of [contentMargins(_:for:)](https://developer.apple.com/documentation/swiftui/view/contentmargins(_:for:))  from the environment. Therefore, you must specify the same value for `promptMargins`. Otherwise, the text and the prompt won’t align.
    ///
    /// - Parameters:
    ///   - text: A `Binding` to the variable containing the text to edit.
    ///   - prompt: A text representing the prompt which provides users with guidance on what to type into.
    ///   - promptMargins: The inset distances for the sides of the prompt from the text editor. The default value zero, and the final result will be translated with the platform default margin of the `TextEditor`.
    public init(
        text: Binding<String>,
        prompt: Text? = nil,
        promptMargins: EdgeInsets = EdgeInsets()
    ) {
        self._text = text
        self.textEditor = TextEditor(text: text)
        self.prompt = prompt
        self.promptMargins = PromptTextEditor.translatedPromptMargins(promptMargins)
    }
    
    /// Init a plain text editor that captures the current selection.
    ///
    /// It hasn’t been possible to read the value of [contentMargins(_:for:)](https://developer.apple.com/documentation/swiftui/view/contentmargins(_:for:))  from the environment. Therefore, you must specify the same value for `promptMargins`. Otherwise, the text and the prompt won’t align.
    ///
    /// - Parameters:
    ///   - text: A `Binding` to the variable containing the text to edit.
    ///   - selection: A `Binding` to the variable containing the selection.
    ///   - prompt: A text representing the prompt which provides users with guidance on what to type into.
    ///   - promptMargins: The inset distances for the sides of the prompt from the text editor. The default value zero, and the final result will be translated with the platform default margin of the `TextEditor`.
    @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
    public init(
        text: Binding<String>,
        selection: Binding<TextSelection?>,
        prompt: Text? = nil,
        promptMargins: CGFloat
    ) {
        self.init(
            text: text,
            selection: selection,
            prompt: prompt,
            promptMargins: EdgeInsets(
                top: promptMargins,
                leading: promptMargins,
                bottom: promptMargins,
                trailing: promptMargins
            )
        )
    }
    
    /// Init a plain text editor that captures the current selection.
    ///
    /// It hasn’t been possible to read the value of [contentMargins(_:for:)](https://developer.apple.com/documentation/swiftui/view/contentmargins(_:for:))  from the environment. Therefore, you must specify the same value for `promptMargins`. Otherwise, the text and the prompt won’t align.
    ///
    /// - Parameters:
    ///   - text: A `Binding` to the variable containing the text to edit.
    ///   - selection: A `Binding` to the variable containing the selection.
    ///   - prompt: A text representing the prompt which provides users with guidance on what to type into.
    ///   - promptMargins: The inset distances for the sides of the prompt from the text editor. The default value zero, and the final result will be translated with the platform default margin of the `TextEditor`.
    @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
    public init(
        text: Binding<String>,
        selection: Binding<TextSelection?>,
        prompt: Text? = nil,
        promptMargins: EdgeInsets = EdgeInsets()
    ) {
        self._text = text
        self.textEditor = TextEditor(text: text, selection: selection)
        self.prompt = prompt
        self.promptMargins = PromptTextEditor.translatedPromptMargins(promptMargins)
    }
    
    // MARK: View
    
    public var body: some View {
        // The first text base line alignments don't work when vertical paddings are applied.
        let alignment: Alignment = switch multilineTextAlignment {
        case .leading: .topLeading
        case .center: .top
        case .trailing: .topTrailing
        }
        
        textEditor
            .overlay(alignment: alignment) {
                if isShowingPrompt {
                    styledPrompt
                }
            }
            .focused($isFocused)
    }
    
    /// Style the original prompt to align with the placeholder and return a new view.
    @ViewBuilder private var styledPrompt: some View {
        let result = prompt
            .multilineTextAlignment(multilineTextAlignment)
            .padding(promptMargins)
            .allowsHitTesting(false)
        if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
            result
                .foregroundStyle(.placeholder)
        } else {
            result
                .foregroundStyle(.tertiary)
        }
    }
    
    /// The default margin values of `TextEditor`.
    ///
    /// Since there’s no official document about this, these numbers are merely estimates.
    nonisolated private static var platformPromptMargins: EdgeInsets {
        #if os(iOS)
        EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5)
        #elseif os(macOS)
        EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        #elseif os(visionOS)
        EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
        #else
        EdgeInsets()
        #endif
    }
    
    /// Translate the origin prompt margins with the `TextEditor` default margin values.
    /// - Parameter margins: The inset distances for the sides of the prompt from the `TextEditor`.
    nonisolated private static func translatedPromptMargins(_ margins: EdgeInsets) -> EdgeInsets {
        let platformMargins = PromptTextEditor.platformPromptMargins
        let result = EdgeInsets(
            top: margins.top + platformMargins.top,
            leading: margins.leading + platformMargins.leading,
            bottom: margins.bottom + platformMargins.bottom,
            trailing: margins.trailing + platformMargins.trailing
        )
        return result
    }
}

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
#Preview {
    @Previewable @State var text: String = ""
    @Previewable @FocusState var isFocused: Bool
    
    NavigationStack {
        VStack {
            PromptTextEditor(
                text: $text,
                prompt: Text("How was your day?"),
                promptMargins: 16
            )
            .font(.system(size: 60))
            
            .contentMargins(16)
            .focused($isFocused)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
            .navigationTitle("Text Editor")
        }
    }
}
