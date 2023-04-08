//
//  MainCameraView.swift
//  profileui
//
//  Created by Admin on 06/04/2023.
//

import SwiftUI

struct MainCameraView: View {
    let viewModel = CameraViewModel()
    @Binding var caturedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            CameraView(viewModel: viewModel) { result in
                switch result {
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        caturedImage = UIImage(data: data)
                    } else {
                        print("Error: no image data found")
                    }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
            VStack {
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "circle")
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

