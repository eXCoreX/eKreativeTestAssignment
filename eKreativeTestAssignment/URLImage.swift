//
//  URLImage.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 10.06.2021.
//

import SwiftUI


/// Asynchronosly loads an image from the given URL.
/// Sadly either it or LazyVStack has some bug that causes it to infinitely reload,
/// so I used SDWebImage as a substitute
struct URLImage: View {
    private enum LoadState {
        case loading, loaded, failure
    }
    
    private class Loader : ObservableObject {
        var state = LoadState.loading
        var data = Data()
        
        init(url: String) {
            guard let parsedUrl = URL(string: url) else {
                print("Bad url: \(url) given in URLImage")
                state = .failure
                return
            }
            
            URLSession.shared.dataTask(with: parsedUrl) { data, response, error in
                if let data = data, !data.isEmpty {
                    self.data = data
                    self.state = .loaded
                } else {
                    self.state = .failure
                }
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
    
    @StateObject private var loader: Loader
    private var url: String
    
    init(url: String) {
        self.url = url
        _loader = StateObject(wrappedValue: Loader(url: url))
    }
    
    var body: some View {
        chooseImage()
            .aspectRatio(contentMode: .fit)
    }
    
    func chooseImage() -> Image {
        switch loader.state {
        case .loading:
            return Image(systemName: "photo")
        case .failure:
            return Image(systemName: "exclamationmark.circle")
        default:
            if let uiImage = UIImage(data: loader.data) {
                return Image(uiImage: uiImage)
            } else {
                return Image(systemName: "exclamationmark.circle")
            }
        }
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(url: "https://www.w3.org/People/mimasa/test/imgformat/img/w3c_home.jpg")
    }
}
