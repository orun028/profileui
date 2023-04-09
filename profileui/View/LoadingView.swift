//
//  LoadingView.swift
//  profileui
//
//  Created by Admin on 09/04/2023.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false
        
        var body: some View {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                } else {
                    Text("Welcome!")
                }
            }
            .onAppear {
                isLoading = true
                // Perform your background task here...
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isLoading = false
                }
            }
        }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
