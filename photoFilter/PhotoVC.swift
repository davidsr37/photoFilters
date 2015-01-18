//
//  PhotoVC.swift
//  photoFilter
//
//  Created by David Rogers on 1/14/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit
import Photos

class PhotoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
  
  var fetchResults : PHFetchResult!
  var assetCollect : PHAssetCollection!
  var imageManager = PHCachingImageManager()
  
  var collectView : UICollectionView!
  
  var destinationImageSize : CGSize!
  
  var delegate : ImageSelectedProtocol?
  
  override func loadView() {
    
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    
    self.collectView = UICollectionView(frame: rootView.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    
    let flowLayout = collectView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.itemSize = CGSize(width: 100, height: 100)
    
    rootView.addSubview(collectView)
    
    collectView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    self.view = rootView
    
  }
  override func viewDidLoad() {
        super.viewDidLoad()
    self.imageManager = PHCachingImageManager()
    self.fetchResults = PHAsset.fetchAssetsWithOptions(nil)
    
    self.collectView.dataSource = self
    self.collectView.delegate = self
    self.collectView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "PHOTO_CELL")
    
        // Do view setup here.
  }
  
  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.fetchResults.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as GalleryCell
    let asset = self.fetchResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      cell.imageView.image = requestedImage
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let selectedAsset = self.fetchResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(selectedAsset, targetSize: self.destinationImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) {(requestedImage, info) -> Void in
      
      println()
      
  
      self.delegate?.controllerDidSelectImage(requestedImage)
      
      self.navigationController?.popToRootViewControllerAnimated(true)
    }
  }
}
