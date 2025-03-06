//
//  AvatarPhotoView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 27.02.2025.
//

import SwiftUI

struct AvatarPhotoView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPhotoSourceActionSheetPresented: Bool
    @Binding var isCameraPresented: Bool
    @Binding var isImagePickerPresented: Bool
    @Binding var isFilePickerPresented: Bool

    var body: some View {
        Button(action: {
            isPhotoSourceActionSheetPresented = true
        }) {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(content: {
                            Text("Add Avatar")
                                .foregroundColor(.white)
                        })
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.yellow, lineWidth: 1)
            )
            .frame(width: 150, height: 150)
        }
        .actionSheet(isPresented: $isPhotoSourceActionSheetPresented) {
            ActionSheet(title: Text("Select Photo Source"), buttons: [
                .default(Text("Camera")) { isCameraPresented = true },
                .default(Text("Gallery")) { isImagePickerPresented = true },
                .default(Text("Files")) { isFilePickerPresented = true },
                .cancel()
            ])
        }
    }
}
