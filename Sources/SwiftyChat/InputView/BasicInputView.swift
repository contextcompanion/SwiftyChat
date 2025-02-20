//
//  BasicInputView.swift
//  
//
//  Created by Enes Karaosman on 19.10.2020.
//

import SwiftUI

public struct BasicInputView: View {
    
    @Binding private var isEnabled: Bool
    @Binding private var message: String
    @Binding private var isEditing: Bool
    private let placeholder: String

    @State private var contentSizeThatFits: CGSize = .zero

    private var internalAttributedMessage: Binding<NSAttributedString> {
        Binding<NSAttributedString>(
            get: {
                NSAttributedString(
                    string: self.message,
                    attributes: [
                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                        NSAttributedString.Key.foregroundColor: UIColor.label,
                    ]
                )
            },
            set: { self.message = $0.string }
        )
    }

    private var onCommit: ((ChatMessageKind) -> Void)?
    
    public init(
        message: Binding<String>,
        isEditing: Binding<Bool>,
        isEnabled: Binding<Bool>,
        placeholder: String = "",
        onCommit: @escaping (ChatMessageKind) -> Void
    ) {
        self._message = message
        self.placeholder = placeholder
        self._isEditing = isEditing
        self._isEnabled = isEnabled
        self._contentSizeThatFits = State(initialValue: .zero)
        self.onCommit = onCommit
    }

    private var messageEditorHeight: CGFloat {
        min(
            self.contentSizeThatFits.height,
            0.25 * UIScreen.main.bounds.height
        )
    }

    private var messageEditorView: some View {
        MultilineTextField(
            attributedText: self.internalAttributedMessage,
            placeholder: placeholder,
            isEditing: self.$isEditing,
            onCommit: {
                self.onCommit?(.text(message))
                self.message.removeAll()
            }
        )
        .onPreferenceChange(ContentSizeThatFitsKey.self) {
            self.contentSizeThatFits = $0
        }
        .frame(height: self.messageEditorHeight)
    }

    private var sendButton: some View {
        Button(action: {
            self.onCommit?(.text(message))
            self.message.removeAll()
        }, label: {
            let disabled = message.isEmpty || !self.isEnabled
            Circle().fill(Color(disabled ? .systemGray : .systemBlue))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .offset(x: -1, y: 1)
                        .padding(8)
                )
        })
        .disabled(message.isEmpty || !self.isEnabled)
    }

    public var body: some View {
        VStack {
            //Divider()
            HStack {
                self.messageEditorView
                self.sendButton
            }
        }.background(Color.white)
    }
    
}
