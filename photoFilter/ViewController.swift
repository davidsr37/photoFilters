//
//  ViewController.swift
//  Photo Viewer
//
//  Created by David Rogers on 1/12/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//  Credits: Code Fellows Seattle- Brad, Jeff, Kevin, Carol, Clint, John.
//
//  Still to do on this project before it might resemble "complete":
//  - Refactor for better MVC design
//  - better constraints on the gallery VC to support landscape orientation
//  - constraints to maintain aspect ratio of images (no stretchy photos)
//  But these parts were not the assignment this week so I will have to come back to this at some point...

import UIKit
import Social

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate {
  
  //setup alertController variable with options - can use alert sytle or actionsheet style
  let alertCon = UIAlertController(title: NSLocalizedString("Menu", comment: "This is the main menu"), message: NSLocalizedString("Choose from the following options:", comment: "Choose View"), preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  //
  let mainImgView = UIImageView()
  var collectView : UICollectionView!
  var collectViewYConstraint : NSLayoutConstraint!
  var mainImgVConstraintVertOpt : NSLayoutConstraint!
  var origImage : UIImage?
  var filteredImage : UIImage?
  var origThumb : UIImage!
  var filterNames = [String]()
  
  let imageQ = NSOperationQueue()
  var gpuContext : CIContext!
  var thumbnails = [Thumbnail]()
  
  var doneButton : UIBarButtonItem!
  var shareButton : UIBarButtonItem!
  var rootView : UIImageView!
  
  var delegate : ImageSelectedProtocol?
  
  var images = [UIImage]()
  
  
    
//MARK: LOADVIEW
  override func loadView() {
    
    //set rootView frame with mainscreen bounds property
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    //background color
    rootView.backgroundColor = UIColor.blackColor()
    //
    self.mainImgView.translatesAutoresizingMaskIntoConstraints = false
    self.mainImgView.backgroundColor = UIColor.grayColor()
    rootView.addSubview(self.mainImgView)
    //instantiate button
    let photoButton = UIButton()
  //IMPORTANT - MUST SET TO USE AUTOLAYOUT WITHOUT STORYBOARD
    photoButton.translatesAutoresizingMaskIntoConstraints = false
    //add view of button to rootView
    rootView.addSubview(photoButton)
    //set button title and title color
    photoButton.setTitle(NSLocalizedString("Photos", comment: "photo button"), forState: .Normal)
    photoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    //add target for button, which is self, and set the action as a string; forControlEvents - touch up inside selects as finger is removed from the button
    photoButton.addTarget(self, action: #selector(photoButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)
    
    //
    let collectVFlowLay = UICollectionViewFlowLayout()
    self.collectView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectVFlowLay)
    collectVFlowLay.itemSize = CGSize(width: 100, height: 100)
    collectVFlowLay.scrollDirection = .Horizontal
    rootView.addSubview(collectView)
    collectView.translatesAutoresizingMaskIntoConstraints = false
    collectView.dataSource = self
    collectView.delegate = self
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
    
	let aSelector : Selector = #selector(mainImgDoubleTapped)
    let doubleTapGR = UITapGestureRecognizer(target: self, action: aSelector)
    doubleTapGR.numberOfTapsRequired = 2
    view.addGestureRecognizer(doubleTapGR)

    
	self.doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "done button"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(donePressed))
	self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(sharePressed))
    self.navigationItem.rightBarButtonItem = self.shareButton
    
    //setup action option in the alert allowing us to select gallery mode
    let galleryOption = UIAlertAction(title: NSLocalizedString("Gallery", comment: "gallery button"), style: UIAlertActionStyle.Default) { (action) -> Void in
      print("gallery tapped")
      //set variable for galleryview class
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      //push that view when gallery action/option tapped
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
      //final step to setup the action
      self.alertCon.addAction(galleryOption)
    
  //MARK: Filter Option
    
    
    let filterOpt = UIAlertAction(title: NSLocalizedString("Filter", comment: "filter button"), style: UIAlertActionStyle.Default) { (action) -> Void in
      self.collectViewYConstraint.constant = 20
      
      self.mainImgVConstraintVertOpt.constant = 62
      
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
    
      //
		let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.donePressed))
      self.navigationItem.rightBarButtonItem = doneButton
    }
    
    //final step for adding the alert
    self.alertCon.addAction(filterOpt)
    
  
  //MARK: Camera Option
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
    let camOpt = UIAlertAction(title: NSLocalizedString("Camera", comment: "camera button"), style: .Default, handler: { (action) -> Void in
      
      let imgPickCon = UIImagePickerController()
      imgPickCon.sourceType = UIImagePickerControllerSourceType.Camera
      imgPickCon.allowsEditing = true
      imgPickCon.delegate = self
      self.presentViewController(imgPickCon, animated: true, completion: nil)
    })
    self.alertCon.addAction(camOpt)
  }
    
    
 //MARK: Photo Option
  let photoOpt = UIAlertAction(title: NSLocalizedString("Your Photos", comment: "photo button"), style: .Default)
    { (action) -> Void in
    let photoVC = PhotoVC()
    photoVC.destinationImageSize = self.mainImgView.frame.size
    photoVC.delegate = self
    self.navigationController?.pushViewController(photoVC, animated: true)
      
      }
  self.alertCon.addAction(photoOpt)
    
    
   let options = [kCIContextWorkingColorSpace : NSNull()] //for fast UI
    
   let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    
    self.setupThumbs()
    
    // Do any additional setup after loading the view, typically from a nib.
  }
//MARK: End of viewDidLoad
  
//MARK: Gesture: double tap
  func mainImgDoubleTapped(sender : UITapGestureRecognizer) {
    
    self.collectViewYConstraint.constant = 20
    
    self.mainImgVConstraintVertOpt.constant = 62
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    
	let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(donePressed))
    self.navigationItem.rightBarButtonItem = doneButton

  }
    

  
//MARK: viewDidAppear

  override func viewDidAppear(animated: Bool) {
    print("viewDidAppear")
    self.origImage = self.mainImgView.image
  }
  
//MARK: Filters
  //thumbnails
  func setupThumbs() {
    //list of filters
    self.filterNames = ["CISepiaTone", "CIPhotoEffectChrome", "CIColorPosterize", "CIVibrance", "CIPhotoEffectNoir"]
    //loops through for each filter and creates thumbnail
    for name in self.filterNames {
      let thumb = Thumbnail(filterName: name, operationQueue: self.imageQ, context: self.gpuContext)
      //add to thumbnail collection
      self.thumbnails.append(thumb)
    }
  }

//MARK: ImageSelectedDelegate
  
  func controllerDidSelectImage(image: UIImage) {
    print("image selected")
    self.mainImgView.image = image
    self.generateThumb(image)
    
    for thumb in self.thumbnails {
      thumb.origImage = self.origThumb
      thumb.filteredImage = nil
    }
    self.collectView.reloadData()
  }

//MARK: UIImagePickerController
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let img = info[UIImagePickerControllerEditedImage] as? UIImage
    self.controllerDidSelectImage(img!)
  
    picker.dismissViewControllerAnimated(true , completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
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
    //close the context to avoid memory leak
    UIGraphicsEndImageContext()
  }
  
  func donePressed() {
    self.collectViewYConstraint.constant = -120
    self.mainImgVConstraintVertOpt.constant = 30
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    self.navigationItem.rightBarButtonItem = self.shareButton
  }
  
  func sharePressed() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let compVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      compVC.addImage(self.mainImgView.image) 
      self.presentViewController(compVC, animated: true, completion: nil)
    } else {
      
      //display alert advising to sign into Twitter account
      
      
    }
  }
  
//MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.thumbnails.count
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as! GalleryCell
    let thumb = self.thumbnails[indexPath.row]
    if thumb.origImage != nil {
      if thumb.filteredImage == nil {
        thumb.generateFilteredImage()
        cell.imageView.image = thumb.filteredImage!
    } else {
      
      cell.imageView.image = thumb.filteredImage!
      }}
    
    return cell
  }
  
//MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    
 //MARK: Apply filter, Image orientation
    let startImage = CIImage(image: self.origImage!)
    
    print("check image orientation")
    
    let filter = CIFilter(name: self.filterNames[indexPath.row])
    filter!.setDefaults()
    filter!.setValue(startImage, forKey: kCIInputImageKey)
    let result = filter!.valueForKey(kCIOutputImageKey) as! CIImage
    let extent = result.extent
    let imageReference = self.gpuContext.createCGImage(result, fromRect: extent)
    self.mainImgView.image = UIImage(CGImage: imageReference, scale: self.origImage!.scale, orientation: self.origImage!.imageOrientation)
    
  }

  
//MARK: Autolayout Constraints
  func setupConstraintsOnRootView(rootView : UIView, forViews views : [String : AnyObject]) {
    
    //set variable for vertical constraint on photoButton
    let photoButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-30-|", options: [], metrics: nil, views: views)
    
    //instantiate the constraint
    rootView.addConstraints(photoButtonConstraintVertical)
    
    //watch the () vs [] on this next line, we are setting a
    let photoButton = views["photoButton"] as! UIView!
    
    //set variable for horizontal constraint
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    
    //instantiate the constraint
    rootView.addConstraint(photoButtonConstraintHorizontal)
    
    //
    photoButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Vertical)
    
    //
    let mainImgVConstraintHoriz = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImgView]-|", options: [], metrics: nil, views: views)
    rootView.addConstraints(mainImgVConstraintHoriz)
    
    
    let mainImgVConstraintVert = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImgView]-30-[photoButton]", options: [], metrics: nil, views: views)
    rootView.addConstraints(mainImgVConstraintVert)
    self.mainImgVConstraintVertOpt = mainImgVConstraintVert.last! as NSLayoutConstraint
    
    
	
    let collectVConstraintHoriz = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectView]|", options: [], metrics: nil, views: views)
    rootView.addConstraints(collectVConstraintHoriz)
    
    
    let collectVConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectView(100)]", options: [], metrics: nil, views: views)
    self.collectView.addConstraints(collectVConstraintHeight)
    
    
    let collectVConstraintVert = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectView]-(-120)-|", options: [], metrics: nil, views: views)
    rootView.addConstraints(collectVConstraintVert)
    self.collectViewYConstraint = collectVConstraintVert.first! as NSLayoutConstraint
    
  }

}

