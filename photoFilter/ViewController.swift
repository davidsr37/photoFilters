//
//  ViewController.swift
//  Photo Viewer
//
//  Created by David Rogers on 1/12/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource {
  
  //setup alertController variable with options - can use alert sytle or actionsheet style
  let alertCon = UIAlertController(title: "Menu", message: "Choose your view", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  //
  let mainImgView = UIImageView()
  var collectView : UICollectionView!
  var collectViewYConstraint : NSLayoutConstraint!
  var origThumb : UIImage!
  var filterNames = [String]()
  let imageQ = NSOperationQueue()
  var gpuContext : CIContext!
  var thumbnails = [Thumbnail]()
  
//MARK: LOADVIEW
  override func loadView() {
    
    //set rootView frame with mainscreen bounds property
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    //background color
    rootView.backgroundColor = UIColor.blackColor()
    //
    self.mainImgView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.mainImgView.backgroundColor = UIColor.grayColor()
    rootView.addSubview(self.mainImgView)
    //instantiate button
    let photoButton = UIButton()
  //IMPORTANT - MUST SET TO USE AUTOLAYOUT WITHOUT STORYBOARD
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    //add view of button to rootView
    rootView.addSubview(photoButton)
    //set button title and title color
    photoButton.setTitle("Photos", forState: .Normal)
    photoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    //add target for button, which is self, and set the action as a string; forControlEvents - touch up inside selects as finger is removed from the button
    photoButton.addTarget(self, action: "photoButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    
    //
    let collectVFlowLay = UICollectionViewFlowLayout()
    self.collectView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectVFlowLay)
    collectVFlowLay.itemSize = CGSize(width: 100, height: 100)
    collectVFlowLay.scrollDirection = .Horizontal
    rootView.addSubview(collectView)
    collectView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectView.dataSource = self
    collectView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    
    //apply constraints for self in code from constraints listed later in this class (set up constraints first)
    let views = ["photoButton" : photoButton, "mainImgView" : self.mainImgView, "collectView" : collectView]
    
    self.setupConstraintsOnRootView(rootView, forViews: views)
    
    //establish self.view as rootview - this is the last thing we always do in LOADVIEW func
    self.view = rootView
  }
//MARK: viewDidLoad function
  override func viewDidLoad() {
    super.viewDidLoad()
    //setup action option in the alert allowing us to select gallery mode
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      println("gallery tapped")
      //set variable for galleryview class
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      //push that view when gallery action/option tapped
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
      //final step to setup the action
      self.alertCon.addAction(galleryOption)
    
    //
    
    let filterOpt = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.collectViewYConstraint.constant = 20
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
    }
    
    self.alertCon.addAction(filterOpt)
    
    
//    let options = [kCIContextWorkingColorSpace : NSNull()] //for fast UI
//    
//    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
//    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.gpuContext = CIContext(options: nil)
    self.setupThumbs()
    
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  //
  func setupThumbs() {
    self.filterNames = ["CISepiaTone", "CIPhotoEffectChrome", "CIPhotoEffectNoir"]
    for name in self.filterNames {
      let thumb = Thumbnail(filterName: name, operationQueue: self.imageQ, context: self.gpuContext)
      self.thumbnails.append(thumb)
    }
  }

//MARK: ImageSelectedDelegate
  
  func controllerDidSelectImage(image: UIImage) {
    println("image selected")
    self.mainImgView.image = image
    self.generateThumb(image)
    
    for thumb in self.thumbnails {
      thumb.origImage = self.origThumb
    }
    self.collectView.reloadData()
  }
  
//MARK: Button Selectors
    
  func photoButtonTapped(sender: UIButton) {
    self.presentViewController(self.alertCon, animated: true, completion: nil)
    }
  
  func generateThumb(originalImage: UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.origThumb = UIGraphicsGetImageFromCurrentImageContext()
  }
  
  
//MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.thumbnails.count
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
    let thumb = self.thumbnails[indexPath.row]
    if thumb.origImage != nil {
    if thumb.filteredImage == nil {
        thumb.generateFilteredImage()
        cell.imageView.image = thumb.filteredImage!
      } }
    
    return cell
  }
  
  
//MARK: Autolayout Constraints
  func setupConstraintsOnRootView(rootView : UIView, forViews views : [String : AnyObject]) {
    //set variable for vertical constraint on photoButton
    let photoButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-30-|", options: nil, metrics: nil, views: views)
    //instantiate the constraint
    rootView.addConstraints(photoButtonConstraintVertical)
    
    //watch the () vs [] on this next line
    let photoButton = views["photoButton"] as UIView!
    
    //set variable for horizontal constraint
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    //instantiate the constraint
    rootView.addConstraint(photoButtonConstraintHorizontal)
    
    //
    photoButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Vertical)
    
    //
    let mainImgVConstraintHoriz = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImgView]-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImgVConstraintHoriz)
    let mainImgVConstraintVert = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImgView]-30-[photoButton]", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImgVConstraintVert)
    
    let collectVConstraintHoriz = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectView]|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectVConstraintHoriz)
    let collectVConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectView(100)]", options: nil, metrics: nil, views: views)
    self.collectView.addConstraints(collectVConstraintHeight)
    let collectVConstraintVert = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectVConstraintVert)
    self.collectViewYConstraint = collectVConstraintVert.first as NSLayoutConstraint
    
  }

}

