import SwiftUI
import CoreImage.CIFilterBuiltins
import Photos

struct QRCodeView: View {
    let text: String
    @State private var qrcode: UIImage?
    @State private var showingSaveSuccess = false
    
    var body: some View {
        VStack {
            if let image = qrcode {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .onTapGesture {
                        saveToPhotos(image)
                    }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            generateQRCode()
        }
        .alert("已保存到相册", isPresented: $showingSaveSuccess) {
            Button("确定", role: .cancel) { }
        }
    }
    
    private func generateQRCode() {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(text.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let outputImage = filter.outputImage {
            let scale = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: scale)
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrcode = UIImage(cgImage: cgImage)
            }
        }
    }
    
    private func saveToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                showingSaveSuccess = true
            }
        }
    }
}

#Preview {
    QRCodeView(text: "Hello, World!")
}
