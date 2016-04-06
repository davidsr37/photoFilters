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
    imageView.frame = self.bounds
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.masksToBounds = true
    let views = ["imageView" : imageView]
    let imageViewConstraintsHoriz = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: views)
    self.addConstraints(imageViewConstraintsHoriz)
    
    let imageViewConstraintsVert = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: views)
    self.addConstraints(imageViewConstraintsVert)
  
  }
  //required in Swift
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
}
