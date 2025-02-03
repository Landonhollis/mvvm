//
//  NoteView.swift
//  mvvm
//
//  Created by Landon Hollis on 2/2/25.
//

import SwiftUI
import PencilKit

struct NoteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TaskViewModel
    @State private var noteName: String = ""
    @State private var attributedText: NSAttributedString = NSAttributedString(string: "")
    @State private var showingFormatting = false
    @State private var showingDrawing = false
    @State private var canvasView = PKCanvasView()
    @State private var selectedFontSize: CGFloat = 17
    
    // Text formatting states
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderlined = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        saveNote()
                        dismiss()
                    }) {
                        Text("Back")
                            .font(.title2)
                            .foregroundColor(Color("LinesAndTextColor"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color("SecondaryColor"))
                            .cornerRadius(20)
                    }
                    
                    TextField("Name of note here", text: $noteName)
                        .font(.title)
                        .foregroundColor(Color("LinesAndTextColor"))
                        .padding(.horizontal)
                    
                    // Formatting menu button
                    Button(action: { showingFormatting.toggle() }) {
                        Image(systemName: "textformat")
                            .foregroundColor(Color("LinesAndTextColor"))
                    }
                    
                    // Drawing toggle button
                    Button(action: { showingDrawing.toggle() }) {
                        Image(systemName: "pencil.tip")
                            .foregroundColor(Color("LinesAndTextColor"))
                    }
                }
                .padding()
                
                // Formatting toolbar
                if showingFormatting {
                    FormattingToolbar(
                        isBold: $isBold,
                        isItalic: $isItalic,
                        isUnderlined: $isUnderlined,
                        fontSize: $selectedFontSize
                    )
                }
                
                Divider()
                    .background(Color("LinesAndTextColor"))
                
                // Note Content
                ZStack {
                    RichTextEditor(attributedText: $attributedText,
                                 isBold: isBold,
                                 isItalic: isItalic,
                                 isUnderlined: isUnderlined,
                                 fontSize: selectedFontSize)
                        .padding()
                    
                    if showingDrawing {
                        DrawingCanvas(canvasView: $canvasView)
                            .opacity(0.9)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .interactiveDismissDisabled()
    }
    
    private func saveNote() {
        let newNote = NoteTask(
            noteName: noteName,
            noteText: attributedText.string,
            attributedText: attributedText,
            drawingData: canvasView.drawing.dataRepresentation()
        )
        viewModel.addNoteTask(newNote)
    }
}

struct FormattingToolbar: View {
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isUnderlined: Bool
    @Binding var fontSize: CGFloat
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                FormatButton(isSelected: $isBold, symbol: "bold") {}
                FormatButton(isSelected: $isItalic, symbol: "italic") {}
                FormatButton(isSelected: $isUnderlined, symbol: "underline") {}
                
                Divider()
                
                // Font size picker
                Menu {
                    ForEach([12, 14, 17, 20, 24, 28, 32], id: \.self) { size in
                        Button(action: { fontSize = CGFloat(size) }) {
                            Text("\(size)")
                        }
                    }
                } label: {
                    Image(systemName: "textformat.size")
                        .foregroundColor(Color("LinesAndTextColor"))
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FormatButton: View {
    @Binding var isSelected: Bool
    let symbol: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            action()
        }) {
            Image(systemName: "text.\(symbol)")
                .foregroundColor(isSelected ? Color("AddButtonColor") : Color("LinesAndTextColor"))
        }
    }
}

struct DrawingCanvas: View {
    @Binding var canvasView: PKCanvasView
    
    var body: some View {
        DrawingViewRepresentable(canvasView: $canvasView)
    }
}

struct DrawingViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .white, width: 1)
        canvasView.backgroundColor = .clear
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var isBold: Bool
    var isItalic: Bool
    var isUnderlined: Bool
    var fontSize: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        let newFont = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: isBold ? UIFont.boldSystemFont(ofSize: fontSize) : newFont,
            .foregroundColor: UIColor(named: "LinesAndTextColor") ?? .white,
            .underlineStyle: isUnderlined ? NSUnderlineStyle.single.rawValue : 0
        ]
        
        let newAttributedString = NSMutableAttributedString(attributedString: attributedText)
        newAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: newAttributedString.length))
        
        if textView.attributedText != newAttributedString {
            textView.attributedText = newAttributedString
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }
    }
}

#Preview {
    NavigationView {
        NoteView()
            .environmentObject(TaskViewModel())
    }
}

