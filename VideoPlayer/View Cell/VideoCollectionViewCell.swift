//
//  VideoCollectionViewCell.swift
//  VideoPlayer
//
//  Created by iraniya on 27/09/20.
//  Copyright © 2020 iraniya. All rights reserved.
//


import UIKit
import AVFoundation
import Photos


class VideoCollectionViewCell: UICollectionViewCell {
    
    //MARK:- Properties
    
    //  View properties -------------------------------
    
    //labels for displaying video details
    private let audioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        
        return label
    }()
    
    //Container view for containing video player
    private let videoContainerView = UIView()
    
    
    //BookmarkButton
    @objc private let bookmarkButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
        return button
    }()
    
    
    static let identifier = "VideoCollectionViewCell"
    
    
    //video player
    var playerLayer: AVPlayerLayer?
    
    
    //Video model object to interect with our Video model
    private var viewModel: VideoViewModel?
    
    
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .label
        contentView.clipsToBounds = true
        
        addSubview()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoContainerView.frame = contentView.bounds
        
        let size: CGFloat =  50.0 //contentView.frame.size.width/8
        let height = contentView.frame.size.height - 100
        let width  = contentView.frame.size.width
        
        //As we have only one button to set using frame insteen to Autolayout and Size class
        //setting bookmark button
        bookmarkButton.frame = CGRect(x: width - size-20, y: 50, width: size, height: size)
       
        //setting label setting
        audioLabel.frame = CGRect(x: 5, y: height-30, width: width-size-10, height: 50)
       
    }
    
    
    override func prepareForReuse() {
        //setting label to nil before resuse
        audioLabel.text = nil
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
    }
    
    
    //MARK:- Cell UI layout
    private func addSubview() {
        
        contentView.addSubview(videoContainerView)
        contentView.addSubview(audioLabel)
        contentView.addSubview(bookmarkButton)
       
        //Add actions for our button
        bookmarkButton.addTarget(self, action: #selector(didTapBookmarkButton), for: .touchUpInside)
       
        videoContainerView.clipsToBounds = true
        contentView.sendSubviewToBack(videoContainerView)
    }
    
    
    //MARK: - Video player configuration methods
    
    private func playVideo(with View: UIView,asset:PHAsset) {
        
        guard (asset.mediaType == PHAssetMediaType.video) else {
                print("Not a valid video media type")
                return
        }
        
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: nil) { (playerItem, info) in
            DispatchQueue.main.async {
                guard self.playerLayer == nil else { return }
                // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                let player = AVPlayer(playerItem: playerItem)
                let playerLayer = AVPlayerLayer(player: player)
                
                // Configure the AVPlayerLayer and add it to the view.
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                playerLayer.frame = self.videoContainerView.layer.bounds
                self.videoContainerView.layer.addSublayer(playerLayer)
                
                //player.play()
                
                // Cache the player layer by reference, so you can remove it later.
                self.playerLayer = playerLayer
            }
        }
    }
    
    //Bookmark Toggle method
    
    private func toggleFavorite(for asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges({
            let changeRequest = PHAssetChangeRequest(for: asset)
            changeRequest.isFavorite = !asset.isFavorite
        }){ (sucess, error) in
            print("Favourite changed")
        }
    }
    
    
    //MARK:  - Public Methods
    
    public func configure(with viewModel: VideoViewModel) {
        self.viewModel = viewModel
        playVideo(with: videoContainerView, asset: viewModel.videoAsset)
        //setting video file name label
        audioLabel.text = viewModel.audioTrackName
        let image = viewModel.videoAsset.isFavorite ? UIImage(systemName: "bookmark.fill") :  UIImage(systemName: "bookmark")
        self.bookmarkButton.setBackgroundImage(image, for: .normal)
    }
    
    
    public func playVideo() {
        guard let viewModel = viewModel else { return }
        if let player = self.playerLayer?.player {
            player.play()
        } else {
            playVideo(with: videoContainerView, asset: viewModel.videoAsset)
        }
    }
    
    
    public func pauseVideo() {
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
    }
    
    
    //MARK: - Action Methods
    @objc func didTapBookmarkButton() {
        guard let _ = viewModel else { return }
        //delegate?.didTappedBookmarkButton(with: videoViewModel)
        
        viewModel!.isVideoBookmarked = !viewModel!.isVideoBookmarked    //we are checking viewModel nil or not before force unwrapping
        toggleFavorite(for: viewModel!.videoAsset)
        let image = viewModel!.isVideoBookmarked ? UIImage(systemName: "bookmark.fill") :  UIImage(systemName: "bookmark")
        self.bookmarkButton.setBackgroundImage(image, for: .normal)
    }
    
}
