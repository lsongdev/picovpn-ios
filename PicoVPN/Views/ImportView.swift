
import SwiftUI
import CodeScanner

struct ImportView: View {
    @State var text: String = ""
    @State private var showingScanner = false
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    var onSave: (([Outbound]) -> Void)
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextEditor(text: $text)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 300)
                        .frame(maxHeight: 500)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    Button(action: {
                        showingScanner = true
                    }) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Scan QRcode")
                        }
                    }
                }
            }
            .navigationBarTitle("Import", displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .sheet(isPresented: $showingScanner) {
                CodeScannerView(codeTypes: [.qr]) { result in
                    showingScanner = false
                    switch result {
                    case .success(let code):
                        text = code.string
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if let str = UIPasteboard.general.string {
                    text = str
                }
            }
        }
    }
    var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    var saveButton: some View {
        Button("Save") {
            do {
                let outbounds = try Config.parseShareLinks(text)
                onSave(outbounds)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        .disabled(text.isEmpty)
    }
}
