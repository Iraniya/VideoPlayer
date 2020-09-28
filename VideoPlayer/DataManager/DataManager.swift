//
//  DataManager.swift
//  VideoPlayer
//
//  Created by iraniya on 27/09/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import Foundation
import Photos



class DataManager {
    //load all the files from the device
    
    func fetchVideos(completion: @escaping ([VideoModel]) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            let allVidOptions = PHFetchOptions()
            allVidOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            allVidOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let allVids = PHAsset.fetchAssets(with: allVidOptions)
            
            var videoModels = [VideoModel]()
            for index in 0..<allVids.count {
                //fetch Asset here
                
                let phAsset = allVids[index]
                let audioTrackName: String = ""
                let videoFileName: String = ""
                let videoFileFormate: String = ""
                let isBookMark: Bool = phAsset.isFavorite
                let videoModel = VideoModel(videoAsset: phAsset, audioTrackName: audioTrackName, videoFileName: videoFileName, videoFileFormate: videoFileFormate, isBookMark: isBookMark)
                videoModels.append(videoModel)
                
            }
            DispatchQueue.main.async {
                completion(videoModels)
            }
        }
    }
    
}
