//
//  profileRedesignViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 5/22/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SwiftOverlays

class profileRedesignViewController: UIViewController, UITabBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func segmentSwitched(_ sender: Any) {
        if self.bandONBSegment.selectedSegmentIndex == 0 {
            self.onbCollect.isHidden = true
            self.bandCollect.isHidden = false
        } else {
            self.onbCollect.isHidden = false
            self.bandCollect.isHidden = true
        }
    }
    var sender = String()
    var picArray = [UIImage]()
    var userID = String()
    var yearsArray = [String]()
    var playingYearsArray = ["1","2","3","4","5+","10+"]
    var playingLevelArray = ["beginner", "intermediate", "advanced", "expert"]
    var tempLink: NSURL?
    var rotateCount = 0
    var sizingCell: PictureCollectionViewCell?
    var sizingCell2: VideoCollectionViewCell?
    var sizingCell3: VideoCollectionViewCell?
    var sizingCell4: SessionCell?
    var instrumentArray = [String]()
    var youtubeArray = [NSURL]()
    var nsurlArray = [NSURL]()
    var ref = Database.database().reference()
    var dictionaryOfInstruments = [String: Any]()
    var tags = [Tag]()
    var vidFromPhoneArray = [NSURL]()
    var viewDidAppearBool = false
    var isYoutubeCell: Bool?
    var skillArray = [String]()
    var currentCollect = String()
    var nsurlDict = [NSURL: String]()
    var bandArray = [Band]()
    var bandIDArray = [String]()
    var ONBArray = [Band]()
    var bandsDict = [String: Any]()
    var sizingCell5: SessionCell?
    var onbArray = [ONB]()
    var onbDict = [String: Any]()
    var onbIDArray = [String]()

    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UITextView!
    @IBOutlet weak var onbCollect: UICollectionView!
    @IBOutlet weak var bandCollect: UICollectionView!
    @IBOutlet weak var instrumentTableView: UITableView!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var bandONBSegment: UISegmentedControl!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var infoShiftLocation: UIView!
    @IBAction func bandCountPressed(_ sender: Any) {
        if infoExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                
                self.artistInfoView.bounds = self.infoViewBounds
                self.artistInfoView.frame.origin = self.infoViewOrigin
                
                //self.positionView.isHidden = true
                
            })
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoShiftViewBounds
                self.artistInfoView.frame.origin = self.infoShiftViewOrigin
                
                if self.bandONBSegment.selectedSegmentIndex == 0 {
                    self.onbCollect.isHidden = true
                    self.bandCollect.isHidden = false
                } else {
                    self.onbCollect.isHidden = false
                    self.bandCollect.isHidden = true
                }
                
                self.bandONBSegment.isHidden = false
                self.instrumentTableView.isHidden = true
                self.videoCollectionView.isHidden = true
                //self.positionView.isHidden = true
                
            })
            
        }
        infoExpanded = !self.infoExpanded
        

    }
    @IBAction func mediaButtonPressed(_ sender: Any) {
        if infoExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoViewBounds
                self.artistInfoView.frame.origin = self.infoViewOrigin
                //self.positionView.isHidden = true
                
            })
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoShiftViewBounds
                self.artistInfoView.frame.origin = self.infoShiftViewOrigin
                //self.positionView.isHidden = true
                
                self.onbCollect.isHidden = true
                self.bandCollect.isHidden = true
                self.bandONBSegment.isHidden = true
                self.instrumentTableView.isHidden = true
                self.videoCollectionView.isHidden = false

                
            })
            
        }
        infoExpanded = !self.infoExpanded
    }
    @IBOutlet weak var mediaLabelCount: UILabel!
    @IBOutlet weak var bandsCountLabel: UILabel!
    @IBOutlet weak var instrumentLabel: UILabel!
    @IBAction func createWantedContinuePressed(_ sender: Any) {
        self.createWantedSuccess.isHidden = true
    }
    @IBOutlet weak var createWantedSuccess: UIView!
    @IBAction func instrumentButtonTouched(_ sender: Any) {
        if infoExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoViewBounds
                self.artistInfoView.frame.origin = self.infoViewOrigin
                //self.positionView.isHidden = true
                
            })
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoShiftViewBounds
                self.artistInfoView.frame.origin = self.infoShiftViewOrigin
                //self.positionView.isHidden = true
                
                self.onbCollect.isHidden = true
                self.bandCollect.isHidden = true
                self.bandONBSegment.isHidden = true
                self.instrumentTableView.isHidden = false
                self.videoCollectionView.isHidden = true
                
            })
            
        }
        infoExpanded = !self.infoExpanded
    }
    
    @IBOutlet weak var menuShiftLocation: UIView!
    var menuExpanded = false
    var infoExpanded = false
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var artistInfoView: UIView!
    var menuViewBounds = CGRect()
    var menuViewOrigin = CGPoint()
    var shiftViewBounds = CGRect()
    var shiftViewOrigin = CGPoint()
    
    var infoViewBounds = CGRect()
    var infoViewOrigin = CGPoint()
    var infoShiftViewBounds = CGRect()
    var infoShiftViewOrigin = CGPoint()

    @IBOutlet weak var artistAllInfoView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfToAddMedia"{
            if let vc = segue.destination as? AddMediaToSession {
                vc.senderView = "main"
            }
            
        }
        else if segue.identifier == "MyBandsToSessionMaker" {
            if let viewController = segue.destination as? SessionMakerViewController {
                viewController.sessionID = self.bandIDArray[tempIndex]
               print("bandID = \(self.bandIDArray[tempIndex])")
                print("tempIndex= \(self.tempIndex)")
                viewController.sender = "myBands"
                
            }
        } else {
            if let viewController = segue.destination as? OneNightBandViewController {
                viewController.onbID = self.onbIDArray[tempIndex]
            }
        }
        
        
    }
    */
    let ONBPink = UIColor(colorLiteralRed: 201.0/255.0, green: 38.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    

    var bandONBCount = 0
    var videoCount = 0
    var instrumentCount = 0
    var artistID = String()
    var fromTabBar: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        //SwiftOverlays.showBlockingTextOverlay("Loading Profile")
        if self.sender == "wantedAdCreated"{
            self.createWantedSuccess.isHidden = false
        }
        if self.sender == "onb" || self.sender == "band" || self.sender == "feed" || self.sender == "bandBoard" || self.sender == "bandToFeed"{
            self.tabBar.isHidden = true
            self.backButton.isHidden = false
            if self.sender == "feed" && self.fromTabBar == true{
                self.userID = (Auth.auth().currentUser?.uid)!
                self.tabBar.isHidden = false
                self.backButton.isHidden = true
            
            } else {
                self.userID = self.artistID
                
            }
            self.addMedia.isEnabled = false
            self.invitesMessagesButton.isEnabled = false
            self.updateInfoButton.isEnabled = false
            
        } else {
            self.tabBar.isHidden = false
            self.backButton.isHidden = true
            self.userID = (Auth.auth().currentUser?.uid)!
        }
        tabBar.tintColor = ONBPink
        tabBar.selectedItem = tabBar.items?[2]
        picCollect.isHidden = true
        self.menuView.isHidden = true
        self.artistInfoView.isHidden = true
        self.artistBio.isHidden = true
        self.artistName.isHidden = true
        tabBar.delegate = self
        //ONBLabel.isHidden = false
        //artistAllInfoView.isHidden = true
        //rotateView(targetView: backgroundImageView)
        picCollect.layer.cornerRadius = 10
        
        menuView.layer.cornerRadius = 10
        //profileImageView.dropShadow()
       
        self.shiftViewBounds = menuShiftLocation.bounds
        
        self.shiftViewOrigin = menuShiftLocation.frame.origin
        self.menuViewBounds = menuView.bounds
        self.menuViewOrigin = menuView.frame.origin
        
        self.infoShiftViewBounds = infoShiftLocation.bounds
        
        self.infoShiftViewOrigin = infoShiftLocation.frame.origin
        self.infoViewBounds = artistInfoView.bounds
        self.infoViewOrigin = artistInfoView.frame.origin
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        picCollect.collectionViewLayout = layout
        

        
        menuButton.dropShadow2()
        menuButton.layer.cornerRadius = 10
        artistInfoView.dropShadow3()
        artistInfoView.layer.cornerRadius = 10
        
        self.ref.child("users").child(self.userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                //fill datasources for collectionViews
                for snap in snapshots{
                    if snap.key == "media"{
                        let mediaSnaps = snap.value as! [String]
                        for m_snap in mediaSnaps{
                            //fill youtubeArray
                            self.videoCount += 1
                            self.youtubeArray.append(NSURL(string: m_snap)!)
                            self.nsurlArray.append(NSURL(string: m_snap)!)
                            if m_snap.contains("yout"){
                                self.nsurlDict[NSURL(string: m_snap)!] = "y"
                            } else {
                                self.nsurlDict[NSURL(string: m_snap)!] = "v"
                            }
                            
                            
                            
                            
                        }
                        
                        
                        //fill prof pic array
                    } else if snap.key == "profileImageUrl"{
                        if let snapshots = snap.children.allObjects as? [DataSnapshot]{
                            for p_snap in snapshots{
                                if let url = NSURL(string: p_snap.value as! String){
                                    if let data = NSData(contentsOf: url as URL){
                                        self.picArray.append(UIImage(data: data as Data)!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            print(self.nsurlArray)
            if self.nsurlArray.count == 0{
                self.currentCollect = "youtube"
                
                self.tempLink = nil
                
                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                //self.youtubeCollectionView.backgroundColor = UIColor.clear
                self.videoCollectionView.dataSource = self
                self.videoCollectionView.delegate = self
                
            }
            for vid in self.nsurlArray{
                
                // Put your code which should be executed with a delay here
                self.currentCollect = "youtube"
                
                self.tempLink = vid
                
                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                //self.youtubeCollectionView.backgroundColor = UIColor.clear
                self.videoCollectionView.dataSource = self
                self.videoCollectionView.delegate = self
            }
            
            
            self.viewDidAppearBool = true
            
            self.ref.child("users").child(self.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                self.artistBio.text = value?["bio"] as! String
                self.artistName.text = (value?["name"] as! String)
                let instrumentDict = value?["instruments"] as! [String: Any]
                self.dictionaryOfInstruments = value?["instruments"] as! [String: Any]
                //var instrumentArray = [String]()
                for (key, value) in instrumentDict{
                    self.instrumentCount += 1
                    self.instrumentArray.append(key)
                    self.skillArray.append(self.playingLevelArray[(value as! [Int])[0]])
                    self.yearsArray.append(self.playingYearsArray[(value as! [Int])[1]])
                    
                }
                
                //print(instrumentArray)
                for _ in self.instrumentArray{
                    let cellNib = UINib(nibName: "InstrumentTableViewCell", bundle: nil)
                    self.instrumentTableView.register(cellNib, forCellReuseIdentifier: "InstrumentCell")
                    self.instrumentTableView.delegate = self
                    self.instrumentTableView.dataSource = self
                }
                
                self.ref.child("users").child(self.userID).child("activeSessions").observeSingleEvent(of: .value, with: {(snapshot) in
                    /*if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                     
                     
                     }*/
                    for _ in self.picArray{
                        self.currentCollect = "pic"
                        //self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        
                        let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                        self.picCollect.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                        self.picCollect.backgroundColor = UIColor.clear
                        self.picCollect.dataSource = self
                        self.picCollect.delegate = self
                        
                    }
                    self.ref.child("bands").observeSingleEvent(of: .value, with: {(snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots{
                                self.bandONBCount += 1
                                let dictionary = snap.value as? [String: Any]
                                let tempBand = Band()
                                tempBand.setValuesForKeys(dictionary!)
                                self.bandArray.append(tempBand)
                                self.bandsDict[tempBand.bandID!] = tempBand
                            }
                        }
                        
                        self.ref.child("users").child(self.userID).child("artistsBands").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                for snap in snapshots{
                                    self.bandIDArray.append((snap.value! as! String))
                                }
                            }
                            
                            self.ref.child("oneNightBands").observeSingleEvent(of: .value, with: {(snapshot) in
                                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                    for snap in snapshots{
                                        self.bandONBCount += 1
                                        let dictionary = snap.value as? [String: Any]
                                        let tempONB = ONB()
                                        tempONB.setValuesForKeys(dictionary!)
                                        self.onbArray.append(tempONB)
                                        self.onbDict[tempONB.onbID] = tempONB
                                    }
                                }
                                self.ref.child("users").child(self.userID).child("artistsONBs").observeSingleEvent(of: .value, with: {(snapshot) in
                                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                        for snap in snapshots{
                                            self.onbIDArray.append((snap.value! as! String))
                                        }
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    DispatchQueue.main.async {
                                        for _ in self.bandIDArray{
                                            
                                            let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                            self.bandCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                            self.sizingCell5 = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                            self.bandCollect.backgroundColor = UIColor.clear
                                            self.bandCollect.dataSource = self
                                            self.bandCollect.delegate = self
                                        }
                                        DispatchQueue.main.async{
                                            for _ in self.onbIDArray{
                                                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                                self.onbCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                                self.sizingCell5 = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                                self.onbCollect.backgroundColor = UIColor.clear
                                                self.onbCollect.dataSource = self
                                                self.onbCollect.delegate = self
                                            }
                                            self.mediaLabelCount.text = String(describing: self.videoCount)
                                            self.instrumentLabel.text = String(describing: self.instrumentCount)
                                            self.bandsCountLabel.text = String(describing: self.bandONBCount)
                                            
                                            self.menuView.isHidden = false
                                            self.artistInfoView.isHidden = false
                                            self.picCollect.isHidden = false
                                            self.artistBio.isHidden = false
                                            self.artistName.isHidden = false
                                            
                                            SwiftOverlays.removeAllBlockingOverlays()
                                            
                                            
                                        }
                                    }
                                })
                            })
                        })
                        
                    })

                    
                    
                })
                DispatchQueue.main.async{
                    self.instrumentTableView.reloadData()
                }
            })
        })
        
    
    if Auth.auth().currentUser?.uid == nil {
    perform(#selector(handleLogout), with: nil, afterDelay: 0)
    }
    

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        performSegue(withIdentifier: "LogoutSegue", sender: self)
    }



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var senderID = String()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfToAddMedia"{
            if let vc = segue.destination as? AddMediaToSession {
                vc.senderView = "main"
            }
            
        }
        if segue.identifier == "ProfileToSessionMaker" {
            if let viewController = segue.destination as? SessionMakerViewController {
                if self.sender == "bandToFeed"{
                    self.sender = "feed"
                    
                }
                if self.sender == "band" || self.sender == "bandBoard"{
                    viewController.sessionID = self.senderID
                } /*else if self.sender == "feed"{
                    viewController.
                }*/ else {
                    viewController.sessionID = self.bandIDArray[tempIndex]
                }
                
                viewController.sender = self.sender
                
            }
        }
        if segue.identifier == "ProfileToONB"{
            if let viewController = segue.destination as? OneNightBandViewController {
                viewController.sender = "profile"
                if self.sender == "onb"{
                    viewController.onbID = self.senderID
                } else {
                    viewController.onbID = self.onbIDArray[tempIndex]
                }
            }
        }

    }
    
    fileprivate var animationOptions: UIViewAnimationOptions = [.curveEaseInOut, .beginFromCurrentState]
    
    func
        out() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        performSegue(withIdentifier: "LogoutSegue", sender: self)
    }

    
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        if menuExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.menuView.bounds = self.menuViewBounds
                self.menuView.frame.origin = self.menuViewOrigin
                //self.positionView.isHidden = true
                
            })

        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.menuView.bounds = self.shiftViewBounds
                self.menuView.frame.origin = self.shiftViewOrigin
                //self.positionView.isHidden = true
                
            })

        }
        menuExpanded = !self.menuExpanded
        
    }
    
    @IBAction func addMediaPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProfToAddMedia", sender: self)
    }
    @IBOutlet weak var addMedia: UIButton!
    @IBAction func invitesPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProfToInvites", sender: self)
    }
    @IBOutlet weak var invitesMessagesButton: UIButton!
    
    @IBAction func updateInfoPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var updateInfoButton: UIButton!
    @IBOutlet weak var picCollect: UICollectionView!
    @IBOutlet weak var ONBLabel: UILabel!
    private func rotateView(targetView: UIView, duration: Double = 5) {
        if rotateCount == 4 {
            //performSegue(withIdentifier: "LaunchToScreen1", sender: self)
            ONBLabel.isHidden = true
            artistAllInfoView.isHidden = false
            
        } else {
            
            
            
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(M_PI_4))
            }) { finished in
                //self.rotateCount = self.rotateCount + 1
                //self.rotateView(targetView: targetView, duration: duration)
                self.ONBLabel.isHidden = true
                self.artistAllInfoView.isHidden = false
            }
        }
    }

    
    @available(iOS 2.0, *)
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items?[0]{
            performSegue(withIdentifier: "ProfileToFindMusicians", sender: self)
        } else if item == tabBar.items?[1]{
            performSegue(withIdentifier: "ProfToJoinBand", sender: self)
            
        } else if item == tabBar.items?[2]{
            
        } else {
            performSegue(withIdentifier: "redesignProfileToFeed", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == picCollect{
            return self.picArray.count
        }else if collectionView == videoCollectionView{
            if self.nsurlArray.count == 0{
                return 1
            }else{
                return self.nsurlArray.count
            }
        } else if collectionView == onbCollect{
           return onbIDArray.count
        } else if collectionView == bandCollect{
            return bandIDArray.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == picCollect{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.layer.cornerRadius = 10
            
            
            //self.curIndexPath.append(indexPath)
            
            return cell

        }else if collectionView == videoCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureVidCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.indexPath = indexPath
            
            //self.curIndexPath.append(indexPath)
            
            return cell

        } else if collectionView == onbCollect || collectionView == bandCollect {
            var tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath) as! SessionCell
            if collectionView == bandCollect{
                tempCell.sessionCellImageView.loadImageUsingCacheWithUrlString((bandsDict[bandIDArray[indexPath.row]] as! Band).bandPictureURL[0])
                //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
                tempCell.sessionCellLabel.text = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandName
                tempCell.sessionCellLabel.textColor = UIColor.white
                tempCell.sessionId = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandID
            }
            else {
                tempCell.sessionCellImageView.loadImageUsingCacheWithUrlString((onbDict[onbIDArray[indexPath.row]] as! ONB).onbPictureURL[0])
                //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
                tempCell.sessionCellLabel.text = (onbDict[onbIDArray[indexPath.row]] as! ONB).onbName
                tempCell.sessionCellLabel.textColor = UIColor.white
                tempCell.sessionId = (onbDict[onbIDArray[indexPath.row]] as! ONB).onbID
            }
            
            return tempCell


        } else {
            let cell = UICollectionViewCell()
            return cell
        }

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.videoCollectionView{
            if (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).videoURL?.absoluteString?.contains("youtube") == false && (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).videoURL?.absoluteString?.contains("youtu.be") == false {
                if (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playbackState == .playing {
                    (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.stop()
                    
                }else{
                    (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playFromBeginning()
                }
                
            }
        } else if(collectionView == bandCollect){
            self.tempIndex = indexPath.row
            if self.sender != "onb" && self.sender != "band"{
                performSegue(withIdentifier: "ProfileToSessionMaker", sender: self)
            } else {
                //present bandviewer***************
            }
        } else if collectionView == onbCollect{
            self.tempIndex = indexPath.row
            performSegue(withIdentifier: "ProfileToONB", sender: self)
        }

        
        
        
    }
    var tempIndex = Int()
    
    
    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        
        
        if self.nsurlArray.count == 0{
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.layer.borderWidth = 1
            cell.removeVideoButton.isHidden = true
            cell.videoURL = nil
            cell.player?.view.isHidden = true
            cell.youtubePlayerView.isHidden = true
            //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
            cell.removeVideoButton.isHidden = true
            cell.noVideosLabel.isHidden = false
        }else {
            
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
            
            //cell.youtubePlayerView.isHidden = true
            cell.removeVideoButton.isHidden = true
            cell.noVideosLabel.isHidden = true
            
            
            
            cell.videoURL =  self.nsurlArray[indexPath.row] as NSURL?
            if(String(describing: cell.videoURL).contains("youtube") || String(describing: cell.videoURL).contains("youtu.be")){
                cell.youtubePlayerView.loadVideoURL(cell.videoURL as! URL)
                cell.youtubePlayerView.isHidden = false
                cell.player?.view.isHidden = true
                cell.isYoutube = true
            }else{
                cell.player?.setUrl(cell.videoURL as! URL)
                cell.player?.view.isHidden = false
                cell.youtubePlayerView.isHidden = true
                cell.isYoutube = false
            }
            //print(self.vidArray[indexPath.row])
            //cell.youtubePlayerView.loadVideoURL(self.vidArray[indexPath.row] as URL)
            //self.group.leave()
        }
        
        
        
    }
    func configureCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        
        cell.picImageView.image = self.picArray[indexPath.row]
        cell.deleteButton.isHidden = true
    }
    
    //TABLEVIEW FUNCTIONS********************
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        return self.instrumentArray.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //(tableView.cellForRow(at: indexPath) as ArtistCell).artistUID
        
        //self.cellTouchedArtistUID = (tableView.cellForRow(at: indexPath) as! ArtistCell).artistUID
        //performSegue(withIdentifier: "ArtistCellTouched", sender: self)
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstrumentCell", for: indexPath as IndexPath) as! InstrumentTableViewCell
        cell.instrumentLabel.text = self.instrumentArray[indexPath.row]
        cell.skillLabel.text =  self.skillArray[indexPath.row]
        cell.yearsLabel.text =  "\(self.yearsArray[indexPath.row]) years"
        
        
        return cell
    }

    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButtonPressed(_ sender: Any) {
        if self.sender == "onb"{
            self.performSegue(withIdentifier: "ProfileToONB", sender: self)
        } else if self.sender == "feed"{
            performSegue(withIdentifier: "redesignProfileToFeed", sender: self)
        } else {
            self.performSegue(withIdentifier: "ProfileToSessionMaker", sender: self)
        }
    }
    
}
extension UIImageView{
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 40
        self.layer.cornerRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}
extension UIButton{
    
    func dropShadow2() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 40
        self.layer.cornerRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}
extension UIView{
    
    func dropShadow3() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 40
        self.layer.cornerRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}

