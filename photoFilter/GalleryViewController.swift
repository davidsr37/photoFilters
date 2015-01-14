//
//  GalleryViewController.swift
//  Photo Viewer
//
//  Created by David Rogers on 1/12/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

protocol ImageSelectedProtocol {
  func controllerDidSelectImage(UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var collectionView : UICollectionView!
  var images = [UIImage]()
  var delegate : ImageSelectedProtocol?
  
//MARK: loadView
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
    
    self.view = rootView
    
    
  }
//MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = UIColor.blackColor()
      self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
      let image0 = UIImage(named: "photo10.jpeg")
      let image1 = UIImage(named: "photo11.jpeg")
      let image2 = UIImage(named: "photo12.jpeg")
      let image3 = UIImage(named: "photo13.jpeg")
      let image4 = UIImage(named: "photo14.jpeg")
      let image5 = UIImage(named: "photo15.jpeg")
      let image6 = UIImage(named: "photo16.jpeg")
      let image7 = UIImage(named: "photo17.jpg")
      let image8 = UIImage(named: "photo18.jpeg")
      let image9 = UIImage(named: "photo19.jpeg")
      self.images.append(image0!)
      self.images.append(image1!)
      self.images.append(image3!)
      self.images.append(image4!)
      self.images.append(image5!)
      self.images.append(image6!)
      self.images.append(image7!)
      self.images.append(image8!)
      self.images.append(image9!)
      
        // Do any additional setup after loading the view.
    }

  
  
//MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.images.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    let image = self.images[indexPath.row]
    cell.imageView.image = image
    return cell
  }

  //MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("gal img selected")
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


