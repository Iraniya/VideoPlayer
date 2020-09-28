//
//  ViewController.swift
//  VideoPlayer
//
//  Created by iraniya on 27/09/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    private var playerCollectionView: UICollectionView!
    
    //private var videoListVm = VideoListViewModel()
    
    lazy var videoListVm: VideoListViewModel  = {
        let viewModel = VideoListViewModel()
        return viewModel
    }()
    
    var visibleIP = IndexPath.init(item: 0, section: 0)
    var aboutToBecomeInvisibleCell = -1
    
    //MARK: - View  Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchVideoURL()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerCollectionView?.frame = view.bounds
    }
    
    //MARK: - Fetch all Video from device
    
    func fetchVideoURL() {

        DataManager().fetchVideos {[weak self] (videos) in
            self?.videoListVm.videoViewModel = videos.map(VideoViewModel.init)
            self?.setupTableView()
        }
    }
    
    
    //MARK: - View UI Setup
    private func setupTableView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.0
        playerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        playerCollectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        playerCollectionView?.isPagingEnabled = true
        playerCollectionView?.dataSource = self
        playerCollectionView?.delegate = self
        self.view.addSubview(playerCollectionView!)
    }
    
}


//MARK:- Collection View Delegate Methods

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoListVm.videoViewModel.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = videoListVm.videoViewModel(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        
        cell.configure(with: model)
        return cell
    }
    
}

//MARK: - CollectionView // ScrollView Delegate for pausing and playing video based on current vissible cell

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying")
        guard let cell = cell as? VideoCollectionViewCell else { return }
        cell.pauseVideo()
    }
    
    
    func playVideoOnTheCell(cell : VideoCollectionViewCell, indexPath : IndexPath){
        cell.playVideo()
    }
    
    
    func stopPlayBack(cell : VideoCollectionViewCell, indexPath : IndexPath){
        cell.pauseVideo()
    }
    
    
    //This below method is to check the visible cell and based on that play or pause the video so that one time only one video is playing 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = self.playerCollectionView.indexPathsForVisibleItems
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = self.playerCollectionView.cellForItem(at: ip) as? VideoCollectionViewCell {
                cells.append(videoCell)
            }
        }
        let cellCount = cells.count
        if cellCount == 0 { return }
        if cellCount == 1 {
            if visibleIP != indexPaths[0] {
                visibleIP = indexPaths[0]
            }
            if let videoCell = cells.last! as? VideoCollectionViewCell {
                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths.last)!)
            }
        }
        if cellCount >= 2 {
            for i in 0..<cellCount {
                let theAttributes = playerCollectionView.layoutAttributesForItem(at: indexPaths[i])
                let cellFrameInSuperview = playerCollectionView.convert(theAttributes!.frame, to: playerCollectionView.superview)
                let currentHeight = cellFrameInSuperview.height
                let cellHeight = (cells[i] as AnyObject).frame.size.height
                if currentHeight > (cellHeight * 0.99) {
                    if visibleIP != indexPaths[i] {
                        visibleIP = indexPaths[i]
                        if let videoCell = cells[i] as? VideoCollectionViewCell{
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths[i]))
                        }
                    }
                } else {
                    if aboutToBecomeInvisibleCell != indexPaths[i].row {
                        aboutToBecomeInvisibleCell = (indexPaths[i].row)
                        if let videoCell = cells[i] as? VideoCollectionViewCell {
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths[i]))
                        }
                        
                    }
                }
            }
        }
    }
}
