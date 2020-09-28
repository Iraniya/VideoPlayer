//
//  VideoViewModel.swift
//  VideoPlayer
//
//  Created by iraniya on 27/09/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import Foundation
import Photos
import Combine

struct VideoViewModel {
    var video: VideoModel
}

extension VideoViewModel {
    var audioTrackName: String {
        return video.audioTrackName
    }
    
    var videoFileName: String {
        return video.videoFileName
    }
    
    var videoFileFormate: String {
        return video.videoFileFormate
    }
    
    var isVideoBookmarked: Bool {
        get {
            return video.isBookMark
        }
        
        set {
            video.isBookMark = newValue
        }
        
    }
    
    var videoAsset: PHAsset {
        return video.videoAsset
    }
}


class VideoListViewModel: ObservableObject {
    var videoViewModel: [VideoViewModel]
    
    init() {
        self.videoViewModel = [VideoViewModel]()
    }
}

extension VideoListViewModel  {
    func videoViewModel(at index: Int) -> VideoViewModel {
        return self.videoViewModel[index]
    }
    
}
