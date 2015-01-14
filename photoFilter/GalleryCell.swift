//
//  GalleryCell.swift
//  Photo Viewer
//
//  Created by David Rogers on 1/12/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
  
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(self.imageView)
    self.backgroundColor = UIColor.blackColor()
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    imageView.frame = self.bounds
    // or can use: imageView.layer.maskToBounds = true
  }
  //required in Swift
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
}
