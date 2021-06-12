//
//  PlaylistItemView.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 10.06.2021.
//

import SwiftUI
import GoogleAPIClientForREST
import SDWebImageSwiftUI

struct PlaylistItemView: View {
    private var item: GTLRYouTube_PlaylistItemSnippet
    
    init(_ item: GTLRYouTube_PlaylistItemSnippet) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            WebImage(url: URL(string: (item.thumbnails?.defaultProperty?.url)!))
            Text(item.title!)
                .fixedSize(horizontal: false, vertical: true)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.clear)
        .overlay(RoundedRectangle(cornerRadius: 25.0).strokeBorder(lineWidth: 2).foregroundColor(Color.accentColor))
    }
}

struct PlaylistItemView_Previews: PreviewProvider {
    static var previews: some View {
        let item = GTLRYouTube_PlaylistItemSnippet()
        item.title = "eKreative Egypt Team Long Video Name Wrapping Test"
        item.thumbnails = GTLRYouTube_ThumbnailDetails()
        item.thumbnails!.defaultProperty = GTLRYouTube_Thumbnail()
        item.thumbnails?.defaultProperty?.url = "https://www.w3.org/People/mimasa/test/imgformat/img/w3c_home.jpg"
        return PlaylistItemView(item)
    }
}
