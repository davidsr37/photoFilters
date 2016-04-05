//
//  GalleryViewController.swift
//  Photo Viewer
//
//  Created by David Rogers on 1/12/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//


import UIKit

protocol ImageSelectedProtocol {
  func controllerDidSelectImage(_: UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var collectionView : UICollectionView!
  var images = [UIImage]()
  var delegate : ImageSelectedProtocol?
  var collectionVFlowLayout : UICollectionViewFlowLayout!
  
  
  
//MARK: loadView
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    self.collectionVFlowLayout = UICollectionViewFlowLayout()
    
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionVFlowLayout)
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    collectionVFlowLayout.itemSize = CGSize(width: 200, height: 200)
    
    self.view = rootView
    
    
  }
//MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = UIColor.blackColor()
      self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
      
      
      let image0 = UIImage(named: "leopard.jpg")
      let image1 = UIImage(named: "dragonfly.jpg")
      let image2 = UIImage(named: "butterfly.jpg")
      let image3 = UIImage(named: "IsoFionabel.jpg")
      let image4 = UIImage(named: "FionaKite.jpg")
      let image5 = UIImage(named: "ripples.jpg")
      
   
      self.images.append(image0!)
      self.images.append(image1!)
      self.images.append(image2!)
      self.images.append(image3!)
      self.images.append(image4!)
      self.images.append(image5!)
      
      
      
      //don't forget colon on selector below for checking, steps 1&2 of GR workflow
		let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(collectionVPinched))
      self.collectionView.addGestureRecognizer(pinchGR)
        // Do any additional setup after loading the view.
    }
//MARK: Gesture Recognizer Actions
  
  func collectionVPinched(sender : UIPinchGestureRecognizer) {
    
    switch sender.state {
    
    case .Began:
      print("began")
    case .Changed:
      print("changed with velocity \(sender.velocity)")
      self.collectionView.performBatchUpdates({ () -> Void in
        if sender.velocity > 0 {
          let newSize = CGSize(width: self.collectionVFlowLayout.itemSize.width * 1.03, height: self.collectionVFlowLayout.itemSize.height * 1.03)
          self.collectionVFlowLayout.itemSize = newSize
          
        } else if sender.velocity < 0 {
          let newSize = CGSize(width: self.collectionVFlowLayout.itemSize.width * 0.97, height: self.collectionVFlowLayout.itemSize.height * 0.97)
          self.collectionVFlowLayout.itemSize = newSize
          
        }
        
        }, completion: {(finished) -> Void in
          
      })
      

    case .Ended:
      print("ended")
          default:
      print("default")
    }
    print("Gallery CV Pinched")
  }
  
  
//MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.images.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as! GalleryCell
    let image = self.images[indexPath.row]
    cell.imageView.image = image
    return cell
  }

  //MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("gallery")
    self.delegate?.controllerDidSelectImage(self.images[indexPath.row])
    
    self.navigationController?.popViewControllerAnimated(true)
  }
  
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


