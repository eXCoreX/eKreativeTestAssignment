//
//  VideoDetailView.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 10.06.2021.
//

import SwiftUI
import GoogleAPIClientForREST
import youtube_ios_player_helper

struct VideoDetailView: View {
    private var item: GTLRYouTube_PlaylistItemSnippet
    private var statistics: GTLRYouTube_VideoStatistics
    
    init(_ item: GTLRYouTube_PlaylistItemSnippet, statistics: GTLRYouTube_VideoStatistics) {
        self.item = item
        self.statistics = statistics
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    PlayerWrapper(videoID: (item.resourceId?.videoId)!)
                        .frame(height: 300, alignment: .center)
                    VStack {
                        Text(item.title!)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        HStack {
                            Text("Views: \(statistics.viewCount ?? 0)")
                            Text("Likes: \(statistics.likeCount ?? 0)")
                        }
                        HStack {
                            Text("Favorites: \(statistics.favoriteCount ?? 0)")
                            Text("Comments: \(statistics.commentCount ?? 0)")
                        }
                    }
                }
                Button(action: shareAction) {
                    HStack {
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }
                    .font(.headline)
                }
                .padding(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(.accentColor))
                Text((item.descriptionProperty)!)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func shareAction() {
        let videoURL = URL(string: "https://youtube.com/watch?v=" + (item.resourceId?.videoId)!)!
        let shareVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        UIApplication.shared.rootViewController?.present(shareVC, animated: true, completion: nil)
    }
}

struct PlayerWrapper : UIViewRepresentable {
    var videoID : String
    
    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        playerView.load(withVideoId: videoID)
        return playerView
    }
    
    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        
    }
}

struct VideoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let item = GTLRYouTube_PlaylistItemSnippet()
        item.title = "eKreative Egypt Team Long Video Name"
        item.descriptionProperty = "Description sample lorem ipsum long meaningless text to test wrapping"
        item.resourceId = GTLRYouTube_ResourceId()
        item.resourceId?.videoId = "U9XOr9fNdlg"
        
        let statistics = GTLRYouTube_VideoStatistics()
        statistics.viewCount = 103253
        statistics.likeCount = 6320
        statistics.favoriteCount = 325
        statistics.commentCount = 1322
        
        return VideoDetailView(item, statistics: statistics)
    }
}
