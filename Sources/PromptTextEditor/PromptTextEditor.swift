//
//  PromptTextEditor.swift
//  PromptTextEditor
//
//  Created by Duy Tran on 25/11/24.
//

import SwiftUI

/// A view that can display and edit long-form text or display a prompt when the editor's content is empty.
public struct PromptTextEditor: View {
    
    /// `true` when focus moves to the view, otherwise, `false`.
    @FocusState private var isFocused: Bool
    
    /// A `Binding` to the variable containing the text to edit.
    @Binding private var text: String
    
    /// A view that can display and edit long-form text.
    private let textEditor: TextEditor
    
    /// A text representing the prompt of the text editor which provides users with guidance on what to type into the text editor.
    private let prompt: Text?
    
    /// The distance to offset the prompt.
    private let promptOffset: CGSize
    
    /// `true` if the text editor is not focused the editable text is empty, otherwise, `false`.
    private var isShowingPrompt: Bool {
        !isFocused && text.isEmpty
    }
    
    /// Init a plain text editor.
    /// - Parameters:
    ///   - text: A `Binding` to the variable containing the text to edit.
    ///   - prompt: A text representing the prompt which provides users with guidance on what to type into.
    ///   - promptOffset: The distance to offset the prompt. The default value `.zero` is to match the default content margin of the `TextEditor`, because the final result will be translated with the platform default offset.
    public init(
        text: Binding<String>,
        prompt: Text? = nil,
        promptOffset: CGSize = .zero
    ) {
        self._text = text
        self.textEditor = TextEditor(text: text)
        self.prompt = prompt
        self.promptOffset = PromptTextEditor.translatingPromptOffset(promptOffset)
    }
    
    /// Init a plain text editor.
    /// - Parameters:
    ///   - text: A `Binding` to the variable containing the text to edit.
    ///   - selection: A `Binding` to the variable containing the selection.
    ///   - prompt: A text representing the prompt which provides users with guidance on what to type into.
    ///   - promptOffset: The distance to offset the prompt. The default value `.zero` is to match the default content margin of the `TextEditor`, because the final result will be translated with the platform default offset.
    @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
    public init(
        text: Binding<String>,
        selection: Binding<TextSelection?>,
        prompt: Text? = nil,
        promptOffset: CGSize = .zero
    ) {
        self._text = text
        self.textEditor = TextEditor(text: text, selection: selection)
        self.prompt = prompt
        self.promptOffset = PromptTextEditor.translatingPromptOffset(promptOffset)
    }

    public var body: some View {
        textEditor
            .overlay(alignment: .topLeading) {
                if let prompt, isShowingPrompt {
                    prompt
                        .foregroundStyle(.secondary)
                        .offset(promptOffset)
                }
            }
            .focused($isFocused)
    }
    
    /// The distance to offset the prompt as equal to match the default content margin of `TextEditor`.
    ///
    /// This offset should match to the current content margin (that is specified by [contentMargins(_:for:)](https://developer.apple.com/documentation/swiftui/view/contentmargins(_:for:)). At this moment, it hasn't been possible to read this value from the environment.
    nonisolated private static var defaultPromptOffset: CGSize {
        #if os(iOS)
        CGSize(width: 5, height: 8)
        #else
        CGSize(width: 5, height: 0)
        #endif
    }
    
    /// Translate the origin prompt offset with the default value of each platforms.
    /// - Parameter offset: The horizontal and vertical amount to offset the prompt.
    nonisolated private static func translatingPromptOffset(_ offset: CGSize) -> CGSize {
        let defaultOffset = PromptTextEditor.defaultPromptOffset
        let width = defaultOffset.width + offset.width
        let height = defaultOffset.height + offset.height
        let result = CGSize(width: width, height: height)
        return result
    }
}

@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)
#Preview {
    @Previewable @State var text: String = ""
    @Previewable @FocusState var isFocused: Bool
    let contentMargin: CGFloat = 16
    
    NavigationStack {
        PromptTextEditor(
            text: $text,
            prompt: Text("Lorem ipsum"),
            promptOffset: CGSize(width: contentMargin, height: contentMargin)
        )
        .font(.title)
        .focused($isFocused)
        .contentMargins(contentMargin)
        .background(Color.secondary.opacity(0.2))
        .scrollContentBackground(.hidden)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
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
