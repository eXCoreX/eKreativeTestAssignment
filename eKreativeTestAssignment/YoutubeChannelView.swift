//
//  YoutubeChannelView.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 09.06.2021.
//

import SwiftUI
import GoogleAPIClientForREST

struct YoutubeChannelView: View {
    private var channelUrl = ""

    @State private var fetchedData = false
    @StateObject private var apiHelper: YoutubeApiHelper
    
    init(_ channelUrl: String) {
        self.channelUrl = channelUrl
        _apiHelper = StateObject(wrappedValue: YoutubeApiHelper(channel: channelUrl))
    }
    
    var body: some View {
        Group {
            if apiHelper.channelInfo != nil {
                ScrollView {
                    LazyVStack {
                        ForEach(apiHelper.videos, id: \.self) { video in
                            NavigationLink(destination: VideoDetailView(video, statistics: apiHelper.videoStatistics[(video.resourceId?.videoId)!] ?? GTLRYouTube_VideoStatistics())) {
                                PlaylistItemView(video)
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .animation(.default)
                            .transition(AnyTransition.move(edge: .leading).animation(Animation.default.speed(0.1)))
                            .onAppear() {
                                // -20 here means we load next the page after the 20th from the last video was shown.
                                // That way we load the next page before user reaches the end of the list.
                                // Lower (more negative) value will mean sooner load
                                if video.position as! Int >= apiHelper.videos.count - 20 {
                                    fetchNextPage()
                                }
                            }
                        }
                        .padding()
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            } else {
                Text("Bad channel url, contact developer")
            }
        }
        .navigationTitle("\((apiHelper.channelInfo?.title) ?? "Failed to load the channel")")
        .onAppear() {
            if !fetchedData {
                fetchChannelData()
                fetchChannelVideos()
                fetchedData = true
            }
        }
    }
    
    func fetchChannelData() {
        apiHelper.fetchChannelInfo()
    }
    
    func fetchChannelVideos() {
        apiHelper.fetchVideos()
    }
    
    func fetchNextPage() {
        apiHelper.loadNextPage()
    }
}

class YoutubeApiHelper : NSObject, ObservableObject {
    @Published var channelInfo: GTLRYouTube_ChannelSnippet? = nil
    @Published var videos: [GTLRYouTube_PlaylistItemSnippet] = []
    @Published var videoStatistics: [String : GTLRYouTube_VideoStatistics] = [:]
    @Published var loadedPages = 0
    
    private let service = GTLRYouTubeService()
    private var channelId: String
    private var playlistId: String? = nil
    private var nextPageToken: String?
    
    // Poor man's synchronization
    private var loadingNextPage = false
    private var requestedNewPage = false
    
    var hasNextPage: Bool {
        nextPageToken != nil
    }
    
    init(channel: String) {
        guard let apikey = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String else { fatalError("Youtube api key was not found in bundle.") }
        service.apiKey = apikey
        // channel url is expected to be in form of https://youtube.com/channel/{id}
        // so here I extract the {id} part
        channelId = String(channel[channel.index(channel.lastIndex(of: "/")!, offsetBy: 1)...])
    }
    
    func fetchChannelInfo() {
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["snippet"])
        query.identifier = [channelId]
        service.executeQuery(query, delegate: self, didFinish: #selector(handleChannelResponse(ticket:finishedWithObject:error:)));
    }
    
    @objc func handleChannelResponse (
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_ChannelListResponse,
        error : NSError?) {
        if let err = error {
            print(err.localizedDescription)
            return
        }
        
        if let channels = response.items, !channels.isEmpty {
            channelInfo = channels.first!.snippet!
        }
    }
    
    func fetchVideos() {
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["contentDetails"])
        query.maxResults = 50
        query.identifier = [channelId]
        service.executeQuery(query, delegate: self, didFinish: #selector(handlePlaylistsResponse(ticket:finishedWithObject:error:)))
    }
    
    @objc func handlePlaylistsResponse (
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_ChannelListResponse,
        error : NSError?) {
        if let err = error {
            print(err.localizedDescription)
            return
        }
        
        if let channels = response.items, !channels.isEmpty {
            let result = channels.first?.contentDetails?.relatedPlaylists?.uploads
            if result != nil {
                let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet"])
                query.playlistId = result
                playlistId = result
                query.maxResults = 50
                service.executeQuery(query, delegate: self, didFinish: #selector(handleVideosResponse(ticket:finishedWithObject:error:)))
            }
        }
    }
    
    func loadNextPage() {
        if !hasNextPage {
            return
        }
        if loadingNextPage {
            requestedNewPage = true
            return
        }
        loadingNextPage = true
        requestedNewPage = false
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet"])
        query.playlistId = playlistId
        query.maxResults = 50
        query.pageToken = nextPageToken
        service.executeQuery(query, delegate: self, didFinish: #selector(handleVideosResponse(ticket:finishedWithObject:error:)))
    }
    
    @objc func handleVideosResponse (
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_PlaylistItemListResponse,
        error : NSError?) {
        if let err = error {
            print(err.localizedDescription)
            return
        }
        
        if let videosChunk = response.items, !videosChunk.isEmpty {
            videos.append(contentsOf: videosChunk.map({
                $0.snippet!
            }))
            let videoIds = videosChunk.map({($0.snippet?.resourceId?.videoId)!})
            fillStatistics(for: videoIds)
            loadedPages += 1
            nextPageToken = response.nextPageToken
        }
        
        loadingNextPage = false
        if requestedNewPage {
            loadNextPage()
        }
    }
    
    func fillStatistics(for videoIds: [String]) {
        let query = GTLRYouTubeQuery_VideosList.query(withPart: ["statistics"])
        query.identifier = videoIds
        query.maxResults = 50
        service.executeQuery(query, delegate: self, didFinish: #selector(handleStatisticsResponse(ticket:finishedWithObject:error:)))
    }
    
    @objc func handleStatisticsResponse (
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_VideoListResponse,
        error : NSError?) {
        if let err = error {
            print(err.localizedDescription)
            return
        }
        
        if let videoStatistics = response.items, !videoStatistics.isEmpty {
            for videoStatistic in videoStatistics {
                self.videoStatistics[videoStatistic.identifier!] = videoStatistic.statistics
            }
        }
    }
}

struct YoutubeChannelView_Previews: PreviewProvider {
    static var previews: some View {
        YoutubeChannelView("https://www.youtube.com/channel/UCP_IYZTiqbmUqmI3KXHIEoQ")
    }
}
