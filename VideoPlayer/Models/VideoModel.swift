//
//  VideoModel.swift
//  VideoPlayer
//
//  Created by iraniya on 27/09/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import Foundation
import Photos

struct VideoModel {
    let videoAsset: PHAsset
    let audioTrackName: String
    let videoFileName: String
    let videoFileFormate: String
    var isBookMark: Bool
}

