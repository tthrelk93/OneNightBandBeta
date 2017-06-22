//
//  AddMediaToProfile.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 12/1/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import SwiftOverlays
//import Firebase

protocol RemoveVideoDelegate : class
{
    func removeVideo(removalVid: NSURL, isYoutube: Bool)
    
}
protocol RemoveVideoData : class
{
    weak var removeVideoDelegate : RemoveVideoDelegate? { get set }
}
protocol RemovePicDelegate : class
{
    func removePic(removalPic: UIImage)
    
}
protocol RemovePicData : class
{
    weak var removePicDelegate : RemovePicDelegate? { get set }
}



class AddMediaToSession: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, RemoveVideoDelegate, RemovePicDelegate{
    
    var bandID: String?
    var sessionID: String?
    var curIndexPath = [IndexPath]()
    var curCount = Int()
    var count1 = Int()
    
    let picker = UIImagePickerController()
    
    var movieURLFromPicker: NSURL?
    var curCell: VideoCollectionViewCell?
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SaveMediaToONB"{
            if let vc = segue.destination as? OneNightBandViewController {
                vc.onbID = self.onbID
                //vc.BandID = self.bandID
                
            }
        }

        
        if segue.identifier == "SaveMediaToSession"{
        if let vc = segue.destination as? MP3PlayerViewController{
            vc.sessionID = self.sessionID
            vc.BandID = self.bandID
            
            }
        }
            
    }
    
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        picker.allowsEditing = true
        picker.mediaTypes = ["kUTTypeImage"]
        
        present(picker, animated: true, completion: nil)

    }
    
    
    @IBAction func chooseVidFromPhoneSelected(_ sender: AnyObject) {
        currentPicker = "vid"
        picker.mediaTypes = ["public.movie"]
        
        present(picker, animated: true, completion: nil)
    }
    var senderView = String()
    @IBOutlet weak var vidFromPhoneCollectionView: UICollectionView!
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    //var tempArray1 = [String]()
    //var tempArray = [String]()
    var lastIndexPath: IndexPath?
    @IBOutlet weak var shadeView: UIView!
    
    
    @IBAction func addYoutubeVideoButtonPressed(_ sender: AnyObject) {
        var tempArray = [String]()
        if senderView == "main"{
            if youtubeLinkField == nil{
                print("youtube field empty")
            } else {
                self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
                ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [DataSnapshot]
            
                    for snap in snapshots {
                        tempArray.append(snap.key)
                    }
            
                    for snap in snapshots{
                        if snap.key == "media"{
                            let mediaKids = snap.children.allObjects as! [DataSnapshot]
                        
                            for mediaKid in mediaKids{
                                tempArray.append(mediaKid.key )
                            }
                        }
                    }
                })
                
                if tempArray.count != 0{
                    
                    self.currentCollectID = "youtube"
                    
                    self.youtubeLinkArray.append(self.currentYoutubeLink)
                    //self.vidFromPhoneArray.append(movieURL)
                    
                    let insertionIndexPath = IndexPath(row: self.youtubeLinkArray.count - 1, section: 0)
                    self.youtubeCollectionView.insertItems(at: [insertionIndexPath])
                    
                }else{
                    self.currentCollectID = "youtube"
                    
                    self.youtubeLinkArray.append(self.currentYoutubeLink)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                    
                    
                }
                
                /*self.tempLink = self.currentYoutubeLink
                self.currentCollectID = "youtube"
                youtubeLinkArray.append(self.currentYoutubeLink)
                print(youtubeLinkArray)
                let insertionIndexPath = IndexPath(row: self.youtubeLinkArray.count - 1, section: 0)
                DispatchQueue.main.async{
                    self.youtubeCollectionView.insertItems(at: [insertionIndexPath])
                            
                }*/
            }
            self.youtubeLinkField.text = ""
            
        } else if senderView == "session"{
            if youtubeLinkField == nil{
                print("youtube field empty")
            }else{
                self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
                ref.child("sessions").child(self.sessionID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                    
                    for snap in snapshots{
                        tempArray.append(snap.key)
                    }
                    
                    for snap in snapshots{
                        if snap.key == "sessionMedia"{
                            let mediaKids = snap.children.allObjects as! [DataSnapshot]
                            
                            for mediaKid in mediaKids{
                                tempArray.append(mediaKid.value as! String)
                            }
                        }
                    }
                    
                })
                if tempArray.count != 0{
                    self.currentCollectID = "youtube"
                    self.youtubeLinkArray.append(self.currentYoutubeLink)
                    let insertionIndexPath = IndexPath(row: self.youtubeLinkArray.count - 1, section: 0)
                    self.youtubeCollectionView.insertItems(at: [insertionIndexPath])
                }else{
                    self.currentCollectID = "youtube"
                    self.youtubeLinkArray.append(self.currentYoutubeLink)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                }
            }
            self.youtubeLinkField.text = ""

        } else {
            if youtubeLinkField == nil{
                print("youtube field empty")
            }else{
                self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
                ref.child("oneNightBands").child(self.onbID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                    
                    for snap in snapshots{
                        tempArray.append(snap.key)
                    }
                    
                    for snap in snapshots{
                        if snap.key == "onbMedia"{
                            let mediaKids = snap.children.allObjects as! [DataSnapshot]
                            
                            for mediaKid in mediaKids{
                                tempArray.append(mediaKid.value as! String)
                            }
                        }
                    }
                    
                })
                if tempArray.count != 0{
                    self.currentCollectID = "youtube"
                    self.youtubeLinkArray.append(self.currentYoutubeLink)
                    let insertionIndexPath = IndexPath(row: self.youtubeLinkArray.count - 1, section: 0)
                    self.youtubeCollectionView.insertItems(at: [insertionIndexPath])
                }else{
                    self.currentCollectID = "youtube"
                    self.youtubeLinkArray.append(self.currentYoutubeLink)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                }
            }
            self.youtubeLinkField.text = ""

        }

    
        }
    
    
    
    var mediaArray: [[String:Any]]?
    let userID = Auth.auth().currentUser?.uid
    //var newestYoutubeVid: String?
    
    var currentYoutubeTitle: String?
    var vidFromPhoneArray = [NSURL]()
    var youtubeDataArray = [String]()
    var recentlyAddedVidArray = [String]()
    var recentlyAddedPicArray = [UIImage]()
    var allVidURLs = [String]()
    //uploads appropriate media to database
    @IBAction func saveTouched(_ sender: AnyObject) {
        if senderView == "main"{
            if (vidFromPhoneCollectionView.visibleCells.count == 0 && currentYoutubeLink == nil && needToUpdatePics == false && needToRemove == false){
                let alert = UIAlertController(title: "No new media", message: "It appears that you have not chosen any media to upload.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            }else{
                SwiftOverlays.showBlockingWaitOverlayWithText("Updating Media")
            
                    _ = Dictionary<String, Any>()
                    var values2 = Dictionary<String, Any>()
                    let recipient = self.ref.child("users").child(userID!)
            
                        //print(youtubeLinkArray)
                        for link in youtubeLinkArray{
                            self.allVidURLs.append(String(describing: link))
                        }
                        //values2["youtube"] = self.youtubeDataArray
                
            
                    if self.recentlyAddedPhoneVidArray.count != 0{
                        count1 = 1
                        
                        for data in self.addedVidDataArray {
                            let videoName = NSUUID().uuidString
                            let storageRef = Storage.storage().reference().child("artist_videos").child("\(videoName).mov")
                            var videoRef = storageRef.fullPath
                            
                            //var downloadLink = storageRef.
                            let uploadMetadata = StorageMetadata()
                            uploadMetadata.contentType = "video/quicktime"
                            
                            _ = storageRef.putData(data, metadata: uploadMetadata){(metadata, error) in
                                if(error != nil){
                                    print("got an error: \(error)")
                                }
                                print("metaData: \(metadata)")
                                print("metaDataURL: \((metadata?.downloadURL()?.absoluteString)!)")
                                self.allVidURLs.append((metadata?.downloadURL()?.absoluteString)!)
                                print("avs:\(self.allVidURLs)")
                                if self.count1 == self.addedVidDataArray.count{
                                    //DispatchQueue.main.async{
                                    values2["media"] = self.allVidURLs
                                    
                                    print("allVids: \(self.allVidURLs)")
                                    recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                                        if err != nil {
                                            print(err!)
                                            return
                                        }
                                    })
                                    //}
                                    
                                }
                                self.count1 += 1
                            }
                        }
                }
            }
            if self.needToUpdatePics == true{
                print("profPicArray: \(self.profPicArray)")
                var count = 0
                for pic in profPicArray{
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
                    if let uploadData = UIImageJPEGRepresentation(pic, 0.1) {
                     
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                        
                        
                        
                       self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
                    //self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
                        
                        
                
               
                    var values3 = Dictionary<String, Any>()
                    print(self.picArray)
                    values3["profileImageUrl"] = self.picArray
                    self.ref.child("users").child(self.userID!).updateChildValues(values3, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
                    })
                        })
                }
            }
           
        }
        DispatchQueue.main.async{
            self.handleCancel()
       
        }
        
        }
        //else senderView == session
        else if senderView == "session"{
            if (vidFromPhoneCollectionView.visibleCells.count == 0 && currentYoutubeLink == nil && needToUpdatePics == false && needToRemove == false){
                let alert = UIAlertController(title: "No new media", message: "It appears that you have not chosen any media to upload.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }else{
                SwiftOverlays.showBlockingWaitOverlayWithText("Updating Media")
                
                _ = Dictionary<String, Any>()
                var values2 = Dictionary<String, Any>()
                let recipient = self.ref.child("sessions").child(self.sessionID!)
                
                
                for link in youtubeLinkArray{
                    self.allVidURLs.append(String(describing: link))
                }
                //values2["youtube"] = self.youtubeDataArray
                
                print("recentlyAddedPhoneVidArray: \(self.recentlyAddedPhoneVidArray)")
                if recentlyAddedPhoneVidArray.count != 0{
                    var count = 1
                    for link in vidFromPhoneArray{
                       // self.allVidURLs.append(String(describing: link))
                    }
                    print("addedVidDataArray: \(self.addedVidDataArray)")
                    print("recentlyAddedPhoneVidArray: \(self.recentlyAddedPhoneVidArray)")
                    for data in self.addedVidDataArray {
                        let videoName = NSUUID().uuidString
                        let storageRef = Storage.storage().reference().child("session_videos").child("\(videoName).mov")
                        var videoRef = storageRef.fullPath
                        
                        //var downloadLink = storageRef.
                        let uploadMetadata = StorageMetadata()
                        uploadMetadata.contentType = "video/quicktime"

                        _ = storageRef.putData(data, metadata: uploadMetadata){(metadata, error) in
                            if(error != nil){
                                print("got an error: \(error)")
                            }
                            print("metaData: \(metadata)")
                            print("metaDataURL: \((metadata?.downloadURL()?.absoluteString)!)")
                            self.allVidURLs.append((metadata?.downloadURL()?.absoluteString)!)
                            print("avs:\(self.allVidURLs)")
                            if count == self.addedVidDataArray.count{
                                //DispatchQueue.main.async{
                                    values2["sessionMedia"] = self.allVidURLs
                                    
                                    print("allVids: \(self.allVidURLs)")
                                    recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                                        if err != nil {
                                            print(err!)
                                            return
                                        }
                                    })
                                //}

                            }
                            count += 1
                        }
                    }
                    
                    
                    //values2["vidsFromPhone"] = self.recentlyAddedVidArray
                }
                else{
                    values2["sessionMedia"] = self.allVidURLs
                    
                    print("allVids: \(self.allVidURLs)")
                    recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
                    })
                    
                }
            }
            
            
            
            
            
            if self.needToUpdatePics == true{
                print("profPicArray: \(self.profPicArray)")
                var count = 0
                for pic in profPicArray{
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("session_images").child("\(imageName).jpg")
                    if let uploadData = UIImageJPEGRepresentation(pic, 0.1) {
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
                            
                            
                            
                            var values3 = Dictionary<String, Any>()
                            print(self.picArray)
                            values3["sessionPictureURL"] = self.picArray
                            self.ref.child("sessions").child(self.sessionID!).updateChildValues(values3, withCompletionBlock: {(err, ref) in
                                if err != nil {
                                    print(err!)
                                    return
                                }
                            })
                        })
                    }
                }
                
            }
            self.performSegue(withIdentifier: "SaveMediaToSession", sender: self)
 
        } else {
            if (vidFromPhoneCollectionView.visibleCells.count == 0 && currentYoutubeLink == nil && needToUpdatePics == false && needToRemove == false){
                let alert = UIAlertController(title: "No new media", message: "It appears that you have not chosen any media to upload.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }else{
                SwiftOverlays.showBlockingWaitOverlayWithText("Updating Media")
                
                _ = Dictionary<String, Any>()
                var values2 = Dictionary<String, Any>()
                let recipient = self.ref.child("oneNightBands").child(self.onbID)
                
                
                for link in youtubeLinkArray{
                    self.allVidURLs.append(String(describing: link))
                }
                //values2["youtube"] = self.youtubeDataArray
                
                print("recentlyAddedPhoneVidArray: \(self.recentlyAddedPhoneVidArray)")
                if recentlyAddedPhoneVidArray.count != 0{
                    var count = 1
                    for link in vidFromPhoneArray{
                        //self.allVidURLs.append(String(describing: link))
                    }
                    print("addedVidDataArray: \(self.addedVidDataArray)")
                    print("recentlyAddedPhoneVidArray: \(self.recentlyAddedPhoneVidArray)")
                    for data in self.addedVidDataArray {
                        let videoName = NSUUID().uuidString
                        let storageRef = Storage.storage().reference().child("onb_videos").child("\(videoName).mov")
                        var videoRef = storageRef.fullPath
                        
                        //var downloadLink = storageRef.
                        let uploadMetadata = StorageMetadata()
                        uploadMetadata.contentType = "video/quicktime"
                        
                        _ = storageRef.putData(data, metadata: uploadMetadata){(metadata, error) in
                            if(error != nil){
                                print("got an error: \(error)")
                            }
                            print("metaData: \(metadata)")
                            print("metaDataURL: \((metadata?.downloadURL()?.absoluteString)!)")
                            self.allVidURLs.append((metadata?.downloadURL()?.absoluteString)!)
                            print("avs:\(self.allVidURLs)")
                            if count == self.addedVidDataArray.count{
                                //DispatchQueue.main.async{
                                values2["onbMedia"] = self.allVidURLs
                                
                                print("allVids: \(self.allVidURLs)")
                                recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                                    if err != nil {
                                        print(err!)
                                        return
                                    }
                                })
                                //}
                                
                            }
                            count += 1
                        }
                    }
                    
                    
                    //values2["vidsFromPhone"] = self.recentlyAddedVidArray
                } else {
                    values2["onbMedia"] = self.allVidURLs
                    
                    print("allVids: \(self.allVidURLs)")
                    recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
                    })
                    
                }

            }
            
            if self.needToUpdatePics == true{
                print("profPicArray: \(self.profPicArray)")
                var count = 0
                for pic in profPicArray{
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("onb_images").child("\(imageName).jpg")
                    if let uploadData = UIImageJPEGRepresentation(pic, 0.1) {
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
                            
                            
                            
                            var values3 = Dictionary<String, Any>()
                            print(self.picArray)
                            values3["onbPictureURL"] = self.picArray
                            self.ref.child("oneNightBands").child(self.onbID).updateChildValues(values3, withCompletionBlock: {(err, ref) in
                                if err != nil {
                                    print(err!)
                                    return
                                }
                            })
                        })
                    }
                }
            }
               self.performSegue(withIdentifier: "SaveMediaToONB", sender: self)
                }

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SwiftOverlays.removeAllBlockingOverlays()
    }
    //**I'm removing the first element everytime rather than at the correct index path. Also might be adding to begginning but appending to array thus creating data inconsistency
    var needToUpdatePics = Bool()
    @IBOutlet weak var picCollectionView: UICollectionView!
    var needToRemovePic = Bool()
    internal func removePic(removalPic: UIImage){
        if profPicArray.count == 1{
            let alert = UIAlertController(title: "Too Few Pictures Error", message: "Must have at least one picture at all times.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
        self.currentCollectID = "picsFromPhone"
        needToRemovePic = true
        needToUpdatePics = true
        print("removePic")
        for pic in 0...profPicArray.count-1{
            if removalPic == profPicArray[pic]{
                profPicArray.remove(at: pic)
                DispatchQueue.main.async{
                    self.picCollectionView.deleteItems(at: [IndexPath(row: pic, section: 0)])
                    print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                }
                break
            }
        }
        }
        
    }
    
    func handleCancel(){
        /*
        if senderView == "main"{
            self.performSegue(withIdentifier: "AddMediaToMain", sender: self)
        }else{
            performSegue(withIdentifier: "SaveMediaToSession", sender: self)
        }*/
        self.performSegue(withIdentifier: "AddMediaToMain", sender: self)

    }
    
   
    var needToRemove = Bool()
    internal func removeVideo(removalVid: NSURL, isYoutube: Bool) {
        print("inRemove")
        if String(describing: removalVid).contains("yout") || String(describing: removalVid).contains("youtu.be") || String(describing: removalVid).contains("You"){
            self.currentCollectID = "youtube"
            self.vidRemovalPressed = true
            needToRemove = true
        
            for vid in 0...youtubeLinkArray.count-1{
                if removalVid == youtubeLinkArray[vid]{
                    youtubeLinkArray.remove(at: vid)
                    DispatchQueue.main.async{
                        self.youtubeCollectionView.deleteItems(at: [IndexPath(row: vid, section: 0)])
                    }
                    break
                
                
                
                }
                }
            }
        else{
            
            self.currentCollectID = "vidFromPhone"
            needToRemove = true
            
            for vid in 0...vidFromPhoneArray.count{
                if removalVid == vidFromPhoneArray[vid]{
                    vidFromPhoneArray.remove(at: vid)
                    DispatchQueue.main.async{
                        self.vidFromPhoneCollectionView.deleteItems(at:[IndexPath(row: vid, section: 0)])
                    }
                    break
                }
            }
        }
        

    }
    
    var picArray = [String]()
    var currentPicker: String?
    @IBOutlet weak var youtubeLinkField: UITextField!
    
    
    weak var dismissalDelegate: DismissalDelegate?
    var ref = Database.database().reference()
    

    var sizingCell = VideoCollectionViewCell()
    var sizingCell2 = PictureCollectionViewCell()
    var currentCollectID = "youtube"
    var currentYoutubeLink: NSURL!
    var youtubeLinkArray = [NSURL]()
    
    var tempLink: NSURL?
   
    
    
    
    
    let imagePicker = UIImagePickerController()
    var videoCollectEmpty: Bool?
    var recentlyAddedPhoneVid = [String]()
    var profPicArray = [UIImage]()
    var viewDidAppearBool = false
    var onbID = String()
    //var sessionID = String()
    var addedVidDataArray = [Data]()
    override func viewDidAppear(_ animated: Bool) {
        if senderView == "main"{
            self.vidRemovalPressed = false
            needToRemove = false
            needToRemovePic = false
            imagePicker.delegate = self
            picker.delegate = self
            curCount = 0
            ref.child("users").child(self.userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
            self.ref.child("users").child(self.userID!).child("media").observeSingleEvent(of: .value, with: { (snapshot) in
            //if self.youtubeLinkArray.count == 0{
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        if (snap.value as! String).contains("you") || (snap.value as! String).contains("You"){
                             self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                        } else {
                            self.vidFromPhoneArray.append(NSURL(string: (snap.value as? String)!)!)
                        }
                    }
                    if self.youtubeLinkArray.count == 0{
                        self.currentCollectID = "youtube"
                        self.videoCollectEmpty = true
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.youtubeCollectionView.backgroundColor = UIColor.clear
                        self.youtubeCollectionView.dataSource = self
                        self.youtubeCollectionView.delegate = self
                    
                    }else{
                        self.videoCollectEmpty = false
                        for vid in self.youtubeLinkArray{
                            self.currentCollectID = "youtube"
                            self.tempLink = vid
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.youtubeCollectionView.backgroundColor = UIColor.clear
                            self.youtubeCollectionView.dataSource = self
                            self.youtubeCollectionView.delegate = self
                            self.curCount += 1
                        }
                    }
                        print("vvPhone: \(self.vidFromPhoneArray)")
                        if self.vidFromPhoneArray.count == 0{
                            self.videoCollectEmpty = true
                            self.currentCollectID = "vidFromPhone"
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                            self.vidFromPhoneCollectionView.dataSource = self
                            self.vidFromPhoneCollectionView.delegate = self
                        }else{
                            self.videoCollectEmpty = false
                            
                            for vid in self.vidFromPhoneArray{
                                self.currentCollectID = "vidFromPhone"
                                self.tempLink = vid
                                //print(self.tempLink)
                                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                self.vidFromPhoneCollectionView.dataSource = self
                                self.vidFromPhoneCollectionView.delegate = self
                                self.curCount += 1
                            }
                    }
                }
            })
                if self.profPicArray.count == 0{
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots{
                            if let url = NSURL(string: snap.value as! String){
                                if let data = NSData(contentsOf: url as URL){
                                    self.profPicArray.append(UIImage(data: data as Data)!)
                                }
                            }
                        }
                    
                        for snap in snapshots{
                            self.currentCollectID = "picsFromPhone"
                            self.tempLink = NSURL(string: (snap.value as? String)!)
                            let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                            self.picCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                            self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                            self.picCollectionView.backgroundColor = UIColor.clear
                            self.picCollectionView.dataSource = self
                            self.picCollectionView.delegate = self
                        }
                    }
                }
                })
        } else if self.senderView == "session" {
            //self.vidRemovalPressed = false
            needToRemove = false
            needToRemovePic = false
            imagePicker.delegate = self
            picker.delegate = self
            curCount = 0
            self.ref.child("sessions").child(self.sessionID!).child("sessionMedia").observeSingleEvent(of: .value, with: { (snapshot) in
                    //if self.youtubeLinkArray.count == 0{
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots{
                            if (snap.value as! String).contains("you") || (snap.value as! String).contains("You"){
                                self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                            } else {
                                self.vidFromPhoneArray.append(NSURL(string: (snap.value as? String)!)!)
                            }
                        }
                        if self.youtubeLinkArray.count == 0{
                        }else{
                            self.videoCollectEmpty = false
                            for vid in self.youtubeLinkArray{
                                self.currentCollectID = "youtube"
                                self.tempLink = vid
                                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                self.youtubeCollectionView.backgroundColor = UIColor.clear
                                self.youtubeCollectionView.dataSource = self
                                self.youtubeCollectionView.delegate = self
                                self.curCount += 1
                            }
                        }
                        print("vvPhone: \(self.vidFromPhoneArray)")
                        if self.vidFromPhoneArray.count == 0{
                            self.videoCollectEmpty = true
                        }else{
                            self.videoCollectEmpty = false
                            print("vPhone: \(self.vidFromPhoneArray)")
                            for vid in self.vidFromPhoneArray{
                                self.currentCollectID = "vidFromPhone"
                                self.tempLink = vid
                                //print(self.tempLink)
                                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                self.vidFromPhoneCollectionView.dataSource = self
                                self.vidFromPhoneCollectionView.delegate = self
                                self.curCount += 1
                            }
                        }
                    }
                })
                if self.profPicArray.count == 0 {
                    ref.child("sessions").child(sessionID!).child("sessionPictureURL").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots{
                            if let url = NSURL(string: snap.value as! String){
                                if let data = NSData(contentsOf: url as URL){
                                    self.profPicArray.append(UIImage(data: data as Data)!)
                                }
                            }
                        }
                        print("pArray: \(self.profPicArray)")
                        for snap in snapshots{
                            self.currentCollectID = "picsFromPhone"
                            self.tempLink = NSURL(string: (snap.value as? String)!)
                            let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                            self.picCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                            self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                            self.picCollectionView.backgroundColor = UIColor.clear
                            self.picCollectionView.dataSource = self
                            self.picCollectionView.delegate = self
                            
                        
                        }
                        }
                    
                
            })
            }
            
        } else {
            needToRemove = false
            needToRemovePic = false
            imagePicker.delegate = self
            picker.delegate = self
            curCount = 0
            self.ref.child("oneNightBands").child(self.onbID).child("onbMedia").observeSingleEvent(of: .value, with: { (snapshot) in
                //if self.youtubeLinkArray.count == 0{
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        if (snap.value as! String).contains("you") || (snap.value as! String).contains("You"){
                            self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                        } else {
                            self.vidFromPhoneArray.append(NSURL(string: (snap.value as? String)!)!)
                        }
                    }
                    if self.youtubeLinkArray.count == 0{
                    }else{
                        self.videoCollectEmpty = false
                        for vid in self.youtubeLinkArray{
                            self.currentCollectID = "youtube"
                            self.tempLink = vid
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.youtubeCollectionView.backgroundColor = UIColor.clear
                            self.youtubeCollectionView.dataSource = self
                            self.youtubeCollectionView.delegate = self
                            self.curCount += 1
                        }
                    }
                    print("vvPhone: \(self.vidFromPhoneArray)")
                    if self.vidFromPhoneArray.count == 0{
                        self.videoCollectEmpty = true
                    }else{
                        self.videoCollectEmpty = false
                        print("vPhone: \(self.vidFromPhoneArray)")
                        for vid in self.vidFromPhoneArray{
                            self.currentCollectID = "vidFromPhone"
                            self.tempLink = vid
                            //print(self.tempLink)
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                            self.vidFromPhoneCollectionView.dataSource = self
                            self.vidFromPhoneCollectionView.delegate = self
                            self.curCount += 1
                        }
                    }
                }
            })
            if self.profPicArray.count == 0 {
                ref.child("oneNightBands").child(onbID).child("onbPictureURL").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots{
                            if let url = NSURL(string: snap.value as! String){
                                if let data = NSData(contentsOf: url as URL){
                                    self.profPicArray.append(UIImage(data: data as Data)!)
                                }
                            }
                        }
                        print("pArray: \(self.profPicArray)")
                        for snap in snapshots{
                            self.currentCollectID = "picsFromPhone"
                            self.tempLink = NSURL(string: (snap.value as? String)!)
                            let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                            self.picCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                            self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                            self.picCollectionView.backgroundColor = UIColor.clear
                            self.picCollectionView.dataSource = self
                            self.picCollectionView.delegate = self
                            
                            
                        }
                    }
                    
                    
                })
            }
            

        }
                    
    }
    
    

    
    override func viewDidLoad(){
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel" , style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        
    }
    
    
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.navigationController?.popViewController(animated: false)
                }
        });
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == youtubeCollectionView{
            if youtubeLinkArray.count == 0{
                return 1
            } else {
                return youtubeLinkArray.count
            }
            

        }
        if collectionView == vidFromPhoneCollectionView{
            if vidFromPhoneArray.count == 0{
                return 1
            } else {
                return vidFromPhoneArray.count
            }
        } else {
            return profPicArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentCollectID != "picsFromPhone"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.indexPath = indexPath
            
            //self.curIndexPath.append(indexPath)
            self.curCell = cell
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
            self.configurePictureCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            
            //self.curIndexPath.append(indexPath)
            
            return cell
        }
        
        
    }
    var vidRemovalPressed: Bool?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       if self.currentCollectID == "vidFromPhone" && self.vidRemovalPressed == false{
        if (self.vidFromPhoneCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playbackState == .playing {
            (self.vidFromPhoneCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.stop()
            
        }else{
            (self.vidFromPhoneCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playFromBeginning()
        }

        }
        
    }
    
    func configurePictureCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        if self.profPicArray.count != 0{
            print(indexPath.row)
            cell.picImageView.image = self.profPicArray[indexPath.row]//loadImageUsingCacheWithUrlString(String(describing: self.profPicArray[indexPath.row]))
            cell.picData = self.profPicArray[indexPath.row]
            cell.removePicDelegate = self
            cell.deleteButton.isHidden = false
        }
    }
    
    func configureCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        print("configVid")
        if(String(describing: cell.videoURL).contains("you") || String(describing: cell.videoURL).contains("You")){
            if self.youtubeLinkArray.count == 0{
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.removeVideoButton.isHidden = true
                cell.videoURL = nil
                cell.player?.view.isHidden = true
                cell.youtubePlayerView.isHidden = true
                //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
                cell.removeVideoButton.isHidden = true
                cell.noVideosLabel.isHidden = false
            }else{
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
                cell.removeVideoButton.isHidden = false
                cell.removeVideoDelegate = self
                cell.youtubePlayerView.isHidden = false
                cell.player?.view.isHidden = true
                
                cell.isYoutube = true
                cell.videoURL = self.youtubeLinkArray[indexPath.row] //NSURL(string: self.youtubeArray[indexPath.row])
                cell.youtubePlayerView.loadVideoURL(self.youtubeLinkArray[indexPath.row] as URL)//NSURL(string: self.recentlyAddedVidArray[indexPath.row])!)
        
                cell.noVideosLabel.isHidden = true
            }
        }
        else{
            print("not youtube")
            if self.vidFromPhoneArray.count == 0 {
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.removeVideoButton.isHidden = true
                cell.videoURL = nil
                cell.player?.view.isHidden = true
                cell.youtubePlayerView.isHidden = true
                //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
                cell.removeVideoButton.isHidden = true
                cell.noVideosLabel.isHidden = false

            } else{
                cell.youtubePlayerView.isHidden = true
                cell.removeVideoButton.isHidden = false
                cell.noVideosLabel.isHidden = true
                cell.isYoutube = false
                cell.player?.view.isHidden = false
                cell.removeVideoDelegate = self
                cell.videoURL =  self.vidFromPhoneArray[indexPath.row] as NSURL?
                cell.player?.setUrl(self.vidFromPhoneArray[indexPath.row] as URL)
                //print(self.vidArray[indexPath.row])
                 //cell.youtubePlayerView.loadVideoURL(self.vidArray[indexPath.row] as URL)
            }
        }
    }
    var recentlyAddedPhoneVidArray = [NSURL]()
    @IBOutlet weak var newImage: UIImageView!
    var isYoutubeCell: Bool?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if currentPicker == "photo"{
        
            var selectedImageFromPicker: UIImage?
            
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
                selectedImageFromPicker = originalImage
            }
        
            if let selectedImage = selectedImageFromPicker {
                
                self.recentlyAddedPicArray.append(selectedImage)
                self.profPicArray.append(selectedImage)
                needToUpdatePics = true
                
                
                
                
                }
            
            
        
            self.dismiss(animated: true, completion: nil)
            
            
            let insertionIndexPath = IndexPath(row: self.profPicArray.count - 1, section: 0)
            
            DispatchQueue.main.async{
                
                print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                self.picCollectionView.insertItems(at: [insertionIndexPath])
                print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                
            }
            

            
        
        }else{
            if senderView == "main"{
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                print("MOVURL: \(movieURL)")
                //print("MOVPath: \(moviePath)")
                if let data = NSData(contentsOf: movieURL as! URL){
                    self.addedVidDataArray.append(data as Data)
                    
                }
                movieURLFromPicker = movieURL
                dismiss(animated: true, completion: nil)
                //self.recentlyAddedPhoneVid.append(String(describing: movieURL))
               // self.vidFromPhoneArray.append(movieURL)
                //uploadMovieToFirebaseStorage(url: movieURL)
                var tempArray1 = [String]()
                ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                    
                    for snap in snapshots{
                        tempArray1.append(snap.key)
                    }
                    if tempArray1.contains("media"){
                        for snap in snapshots{
                            if snap.key == "media"{
                                let mediaKids = snap.children.allObjects as! [DataSnapshot]
                                var tempArray = [String]()
                                for mediaKid in mediaKids{
                                    if (mediaKid.value as! String).contains("you") || (mediaKid.value as! String).contains("You") {
                                        
                                    } else {
                                        tempArray.append(mediaKid.key)
                                    }
                                }
                                if tempArray.count != 0{
                                   // self.tempLink = self.currentYoutubeLink
                                    self.currentCollectID = "vidFromPhone"
                                    //self.isYoutubeCell = false
                                    self.recentlyAddedPhoneVidArray.append(movieURL)
                                    self.vidFromPhoneArray.append(movieURL)
                                    //self.recentlyAddedVidArray.append(String(describing: movieURL))
                                    let insertionIndexPath = IndexPath(row: self.vidFromPhoneArray.count - 1, section: 0)
                                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])
                                        break
                                }else{
                                    self.currentCollectID = "vidFromPhone"
                                    //self.isYoutubeCell = false
                                    self.vidFromPhoneArray.append(movieURL)
                                    self.recentlyAddedPhoneVidArray.append(movieURL)
                                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                    self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                    
                                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                    self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                    self.vidFromPhoneCollectionView.dataSource = self
                                    self.vidFromPhoneCollectionView.delegate = self
                                    
                                    break
                                }
                            }
                        }
                    }//else if it doesnt contain media
                    else{
                        print("noMedia\(movieURL)")
                        self.currentCollectID = "vidFromPhone"
                        
                        self.vidFromPhoneArray.append(movieURL)
                        self.recentlyAddedPhoneVidArray.append(movieURL)
                        
                        
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                        self.vidFromPhoneCollectionView.dataSource = self
                        self.vidFromPhoneCollectionView.delegate = self
                        self.curCount += 1
                        
                    }
                })
                }
            }
            else if senderView == "session"{
                
                
                if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                    print("MOVURL: \(movieURL)")
                    
                    if let data = NSData(contentsOf: movieURL as! URL){
                        self.addedVidDataArray.append(data as Data)
                        
                    }
                    movieURLFromPicker = movieURL
                    dismiss(animated: true, completion: nil)
                    
                    ref.child("sessions").child(self.sessionID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                        var tempArray1 = [String]()
                        for snap in snapshots{
                            tempArray1.append(snap.key)
                        }
                        if tempArray1.contains("sessionMedia"){
                            for snap in snapshots{
                                if snap.key == "sessionMedia"{
                                    let mediaKids = snap.children.allObjects as! [DataSnapshot]
                                    var tempArray = [String]()
                                    for mediaKid in mediaKids{
                                        if (mediaKid.value as! String).contains("you") || (mediaKid.value as! String).contains("You") {
                                            
                                        } else {
                                            tempArray.append(mediaKid.value as! String)
                                        }
                                    }
                                    tempArray.append(String(describing: movieURL))
                                    if tempArray.count != 0{
                                       
                                        self.currentCollectID = "vidFromPhone"
                                       
                                        self.recentlyAddedPhoneVidArray.append(movieURL)
                                        self.vidFromPhoneArray.append(movieURL)
                                        
                                        let insertionIndexPath = IndexPath(row: self.vidFromPhoneArray.count - 1, section: 0)
                                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])
                                        break
                                    }else{
                                        self.currentCollectID = "vidFromPhone"
                                      
                                        self.vidFromPhoneArray.append(movieURL)
                                        self.recentlyAddedPhoneVidArray.append(movieURL)
                                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                        
                                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                        self.vidFromPhoneCollectionView.dataSource = self
                                        self.vidFromPhoneCollectionView.delegate = self
                                        
                                        break
                                    }
                                }
                            }
                        }//else if it doesnt contain media
                        else{
                            print("noMedia\(movieURL)")
                            self.currentCollectID = "vidFromPhone"
                            self.vidFromPhoneArray.append(movieURL)
                            self.recentlyAddedPhoneVidArray.append(movieURL)
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                            self.vidFromPhoneCollectionView.dataSource = self
                            self.vidFromPhoneCollectionView.delegate = self
                            self.curCount += 1
                            
                        }
                    })
                }
            } else {
                if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                    print("MOVURL: \(movieURL)")
                    
                    if let data = NSData(contentsOf: movieURL as! URL){
                        self.addedVidDataArray.append(data as Data)
                        
                    }
                    movieURLFromPicker = movieURL
                    dismiss(animated: true, completion: nil)
                    
                    ref.child("oneNightBands").child(self.onbID).observeSingleEvent(of: .value, with: { (snapshot) in
                        let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                        var tempArray1 = [String]()
                        for snap in snapshots{
                            tempArray1.append(snap.key)
                        }
                        if tempArray1.contains("onbMedia"){
                            for snap in snapshots{
                                if snap.key == "onbMedia"{
                                    let mediaKids = snap.children.allObjects as! [DataSnapshot]
                                    var tempArray = [String]()
                                    for mediaKid in mediaKids{
                                        if (mediaKid.value as! String).contains("you") || (mediaKid.value as! String).contains("You") {
                                            
                                        } else {
                                            tempArray.append(mediaKid.value as! String)
                                        }
                                    }
                                    tempArray.append(String(describing: movieURL))
                                    if tempArray.count != 0{
                                        
                                        self.currentCollectID = "vidFromPhone"
                                        
                                        self.recentlyAddedPhoneVidArray.append(movieURL)
                                        self.vidFromPhoneArray.append(movieURL)
                                        
                                        let insertionIndexPath = IndexPath(row: self.vidFromPhoneArray.count - 1, section: 0)
                                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])
                                        break
                                    }else{
                                        self.currentCollectID = "vidFromPhone"
                                        
                                        self.vidFromPhoneArray.append(movieURL)
                                        self.recentlyAddedPhoneVidArray.append(movieURL)
                                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                        
                                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                        self.vidFromPhoneCollectionView.dataSource = self
                                        self.vidFromPhoneCollectionView.delegate = self
                                        
                                        break
                                    }
                                }
                            }
                        }//else if it doesnt contain media
                        else{
                            print("noMedia\(movieURL)")
                            self.currentCollectID = "vidFromPhone"
                            self.vidFromPhoneArray.append(movieURL)
                            self.recentlyAddedPhoneVidArray.append(movieURL)
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                            self.vidFromPhoneCollectionView.dataSource = self
                            self.vidFromPhoneCollectionView.delegate = self
                            self.curCount += 1
                            
                        }
                    })

                }
            }
        }

        
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    }


    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
        
    
}
//crashes when you click remove video button before view fully loads
