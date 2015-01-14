//
//  Thumbnail.swift
//  Photo Viewer
//
//  Created by David Rogers on 1/13/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class Thumbnail {
  
  var origImage : UIImage?
  var filteredImage : UIImage?
  var filterName : String
  var imageQ : NSOperationQueue
  var gpuContext : CIContext
  
  init( filterName : String, operationQueue : NSOperationQueue, context : CIContext) {
    self.filterName = filterName
    self.imageQ = operationQueue
    self.gpuContext = context
  }
  
  func generateFilteredImage() {
    let startImage = CIImage(image: self.origImage)
    let filter = CIFilter(name: self.filterName)
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    let imageReference = self.gpuContext.createCGImage(result, fromRect: extent)
    self.filteredImage = UIImage(CGImage: imageReference)
  }
}
