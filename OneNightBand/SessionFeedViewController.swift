//
//  SessionFeedViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/3/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftOverlays
import YNDropDownMenu
//import Firebase


protocol FeedDismissalDelegate : class
{
    func finishedShowing(viewController: UIViewController);
    
}

protocol FeedDismissable : class
{
    weak var feedDismissalDelegate : FeedDismissalDelegate? { get set }
}

extension FeedDismissalDelegate where Self: UIViewController
{
    func finishedShowing(viewController: UIViewController) {
        if viewController.isBeingPresented && viewController.presentingViewController == self
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        //self.navigationController?.popViewController(animated: true)
    }
}




class SessionFeedViewController: UIViewController, UIGestureRecognizerDelegate,UINavigationControllerDelegate, FeedDismissalDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UITabBarDelegate{
    @IBOutlet weak var sessionBioTextView: UITextView!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var sessionViewCountLabel: UILabel!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var backgroundGuitarImage: UIImageView!
    
    
    var sessionArray = [SessionFeedSess]()
    var ref = Database.database().reference()
    var firstTouch = CGPoint()
    var viewPins: NSMutableArray!
    var scrollOffset = CGFloat()
    var currentButton: ONBGuitarButton?
    var player:Player?
    
    let ONBPink = UIColor(colorLiteralRed: 201.0/255.0, green: 38.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    
    
    @IBOutlet weak var playerContainerView: PlayerView!
    
    
    @IBOutlet weak var artistTableView: UITableView!
    @IBOutlet weak var sessInfoView: UIView!
    //var ref = Database.database().reference()
    var currentVideoURL: URL?
    let kFretY = 383
    
    @IBAction func visitBandPageTouched(_ sender: Any) {
        var tempSess = SessionFeedSess()
        for sess in sessionArray{
            if sess.sessionID == currentButtonFunc().sessionFeedKey{
                
                tempSess = sess
                break
            }
        }

        if tempSess.bandType == "onb"{
            performSegue(withIdentifier: "feedToONB", sender: self)
        } else{
            performSegue(withIdentifier: "SessionFeedToBandPage", sender: self)
        }
    }
    @IBOutlet weak var bandBio: UITextView!
    @IBOutlet weak var bandInfoViewName: UILabel!
    @IBOutlet weak var bandImageView: UIImageView!
    @IBOutlet weak var sessionArtistsLabel: UILabel!
    @IBAction func bandNameButtonPressed(_ sender: Any) {
        var tempSess = SessionFeedSess()
        for sess in sessionArray{
            if (sess.button["sessionFeedKey"] as! String) == currentButtonFunc().sessionFeedKey {
                
                tempSess = sess
                break
            }
        }
        ref.child("bands").child(tempSess.bandID).observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    if snap.key == "bandName"{
                        self.bandInfoViewName.text = snap.value as! String?
                                            }
                    else if snap.key == "bandPictureURL"{
                        self.bandImageView.loadImageUsingCacheWithUrlString((snap.value as! [String]).first!)
                    }
                    else if snap.key == "bandBio"{
                        self.bandBio.text = snap.value as! String

                    }
                }
            }
            self.dropMenu?.showAndHideMenuAt(index: 0)
        })
        
        DispatchQueue.main.async {
            if self.sessInfoView.isHidden == true{
                self.sessInfoView.isHidden = false
            } else {
                self.sessInfoView.isHidden = true
            }
        }

        
        
    }
    //@IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var bandNameButton: UIButton!
    @IBOutlet weak var bandLabel: UILabel!
    @IBAction func picVidSwitched(_ sender: Any) {
        if picVidSegment.selectedSegmentIndex == 0{
            picCollect.isHidden = false
            videoCollect.isHidden = true
            self.sessionViewsLabel2.isHidden = true
            self.sessionNameLabel2.isHidden = true
            
            self.sessionNameLabel.isHidden = true
            //self.sessionLabel.isHidden = true
            //self.bandLabel.isHidden = true
            self.bandNameButton.isHidden = false
            self.sessionBioTextView.isHidden = true
            self.artistTableView.isHidden = true
           // self.sessionArtistsLabel.isHidden = true
           // self.bioLabel.isHidden = true
            //self.sessionPicksLabel.isHidden = true


        } else if picVidSegment.selectedSegmentIndex == 1{
            picCollect.isHidden = true
            videoCollect.isHidden = false
            self.sessionViewsLabel2.isHidden = true
            self.sessionNameLabel2.isHidden = true
            
            self.sessionNameLabel.isHidden = true
            //self.sessionLabel.isHidden = true
            //self.bandLabel.isHidden = true
            self.bandNameButton.isHidden = false
            self.sessionBioTextView.isHidden = true
            self.artistTableView.isHidden = true
           // self.sessionArtistsLabel.isHidden = true
            //self.bioLabel.isHidden = true
            //self.sessionPicksLabel.isHidden = true

        }else{
            picCollect.isHidden = true
            videoCollect.isHidden = true
            self.sessionViewsLabel2.isHidden = false
            self.sessionNameLabel2.isHidden = true
            tableViewBackView.isHidden = false
            bioBackView.isHidden = false
            
            self.sessionNameLabel.isHidden = false
            //self.sessionLabel.isHidden = false
            //self.bandLabel.isHidden = false
            self.bandNameButton.isHidden = false
            self.sessionBioTextView.isHidden = false
            self.artistTableView.isHidden = false
            //self.sessionArtistsLabel.isHidden = false
           // self.bioLabel.isHidden = false
           // self.sessionPicksLabel.isHidden = false
            
        }
    }
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var sessionPicksLabel: UILabel!
    @IBOutlet weak var picVidSegment: UISegmentedControl!
    @IBOutlet weak var picCollect: UICollectionView!
    @IBOutlet weak var videoCollect: UICollectionView!
    override func viewDidAppear(_ animated: Bool) {
              //self.player = storyboard.view
       //888888 self.player = Player()
        //var currentItem = player?.playerItem
        //print(currentItem)
        
        //self.currentButton = currentButtonFunc()
        
        
        //self.player?.view.frame = self.sessionImageView.frame
        //self.player?.view.topAnchor.constraint(equalTo: se self.view.topAnchor).isActive = true
        //self.player?.view.heightAnchor.constraint(equalToConstant: self.view.frame.height/3.14).isActive = true
        //self.player?.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        //self.playerContainerView.viewController()?.addChildViewController(player!)
        //self.playerContainerView.viewController().
        //self.player?.delegate = self
        
        /*switch UIScreen.main.bounds.width{
        case 320:
            self.player?.view.frame = CGRect(x: 35,y:50,width:250,height:130)
            
        case 375:
            self.player?.view.frame = CGRect(x: 40,y:85,width:300,height:200)
            
            
        case 414:
            self.player?.view.frame = CGRect(x: 33,y:100,width:350,height:250)
            
        default:
            self.player?.view.frame = CGRect(x: 60,y:140,width:350,height:250)
            
            
            
        }*/
        
        
        
        

        
        
        self.sessionInfoView.autoresizesSubviews = true
        
        /*888self.addChildViewController(self.player!)
        sessionInfoView.addSubview((self.player?.view)!)
       
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.playerItem)*/
        
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        SwiftOverlays.removeAllBlockingOverlays()
        
        if sessionArray.count != 0{
            for session in 0...sessionArray.count-1{
                var tempDict = [String:Int]()
                tempDict["views"] = viewArray[session]
                ref.child("sessionFeed").child(sessFeedKeyArray[session]).updateChildValues(tempDict)
            }
        }
    }
    @IBOutlet weak var postToFeedButton: UIButton!
    
    func addNewSession(){
        performSegue(withIdentifier: "FeedToUpload", sender: self)
    }
    func backToNav(){
        SwiftOverlays.showBlockingTextOverlay("Loading Your Profile")
        performSegue(withIdentifier: "BackToMainNav", sender: self)
    }
    @IBOutlet weak var sessionViewsLabel2: UILabel!
    @IBOutlet weak var sessionNameLabel2: UILabel!
    var dropMenu: YNDropDownMenu?
    var sessionsInDatabase = [Session]()
    var sessFeedKeyArray = [String]()
    var displayLineMidY = CGFloat()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bandNameButton.isHidden = true
        
        
        self.postToFeedButton.layer.cornerRadius = self.postToFeedButton.frame.width
        postToFeedButton.layer.borderWidth = 2
        postToFeedButton.layer.borderColor = ONBPink.cgColor
        self.picCollect.layer.cornerRadius = 10
        self.videoCollect.layer.cornerRadius = 10
        self.postToFeedButton.layer.cornerRadius = 10
        tabBar.delegate = self
        tabBar.tintColor = ONBPink
        tabBar.selectedItem = tabBar.items?[3]
        displayLineMidY = displayLine.bounds.midY
        picVidSegment.isHidden = true
        self.sessionNameLabel.isHidden = true
        //self.sessionLabel.isHidden = true
        //self.bandLabel.isHidden = true
        //self.bandNameButton.isHidden = false
        self.sessionBioTextView.isHidden = true
        self.artistTableView.isHidden = true
        //self.sessionArtistsLabel.isHidden = true
        //self.bioLabel.isHidden = true
        //self.sessionPicksLabel.isHidden = true

        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: picCollect.bounds.width, height: picCollect.bounds.width)
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        picCollect.collectionViewLayout = layout
        videoCollect.collectionViewLayout = layout
        
       // self.sessInfoView.isHidden = true
       // var tempRect = CGRect(x: self.sessInfoView.bounds.origin.x, y: self.sessInfoView.bounds.origin.y, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        dropMenu = YNDropDownMenu(frame:sizeView.frame, dropDownViews: [sessInfoView], dropDownViewTitles: [""])
        //dropMenu?.labelFontSize = 30.0
        dropMenu?.setLabelColorWhen(normal: .orange, selected: UIColor.orange.withAlphaComponent(0.5) , disabled: UIColor.gray)
        //dropMenu?.colo
        dropMenu?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
       
        dropMenu?.autoresizesSubviews = true
        dropMenu?.clipsToBounds = true
       // dropMenu.changeMenuTitleAt(index: 0, title: "hello")
        dropMenu?.setImageWhen(normal: UIImage(named: "dropNoSelect"), selected: UIImage(named: "dropSelect"), disabled: UIImage(named: "dropNoSelect"))
       dropMenu?.backgroundBlurEnabled = false
        dropMenu?.backgroundColor = UIColor.clear
        
        self.view.addSubview(dropMenu!)
        dropMenu?.isHidden = true
        
       // guitarPickButton.setImage(UIImage(named: "s_solid_white-1"), for: .normal)
        
        navigationItem.title = "Session Feed"
        let profileButton = UIBarButtonItem(title: "Profile", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SessionFeedViewController.backToNav)) // navigationItem.leftBarButtonItem
        navigationItem.leftBarButtonItem = profileButton
                let uploadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(SessionFeedViewController.addNewSession))
        navigationItem.rightBarButtonItem = uploadButton
        
        
        
        self.ref.child("sessionFeed").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount != 0{
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    
                    let tempSess = SessionFeedSess()
                    let dictionary = snap.value as? [String: AnyObject]
                    if dictionary?["soloSessBool"] as! String == "false"{
                    
                 
                        tempSess.setValuesForKeys(dictionary!)
                        self.viewArray.append(tempSess.views)
                        self.sessionArray.append(tempSess)
                        self.sessFeedKeyArray.append(snap.key as String)
                        print(snap.key as String)
                        }
                    else{
                        tempSess.setValuesForKeys(dictionary!)
                        self.soloViewArray.append(tempSess.views)
                        self.soloSessionArray.append(tempSess)
                        self.soloSessFeedKeyArray.append(snap.key as String)
                    }
                    }
                }
                
            }
        
            
                
            self.view.clipsToBounds = true
            self.scrollOffset = 0
            
            self.viewPins = NSMutableArray()
            
            for session in self.sessionArray{
                var tempButton = ONBGuitarButton()
                
                print("sessButt: \(session.button)")
                
                
                
                
                tempButton._baseX = session.button["_baseX"] as! CGFloat
                tempButton.kMaxY = session.button["kMaxY"] as! Double
                tempButton.lane = session.button["lane"] as! Int
                tempButton.sessionName = session.button["sessionName"] as! String?
                tempButton.isDisplayed = session.button["isDisplayed"] as! Bool?
                tempButton._yPosition = session.button["_yPosition"] as! CGFloat
                tempButton._slope = session.button["_slope"] as! CGFloat
                tempButton.sessionFeedKey = session.button["sessionFeedKey"] as! String?
                tempButton.kStartY = session.button["kStartY"] as! Int
                tempButton.sessionViews = session.button["sessionViews"] as! Int?
                let tap = UITapGestureRecognizer(target: self, action: #selector(SessionFeedViewController.scrollToPin))
                
                tap.numberOfTapsRequired = 1
                //button.tap = tap
                tempButton.addGestureRecognizer(tap)
                tempButton.isUserInteractionEnabled = true

                //tempButton.setValuesForKeys(session.button)
                self.view.addSubview(tempButton)
                self.viewPins.add(tempButton)
                self.buttonArray.append(tempButton)
                //tempButton.lane = session.button.lane
                //tempButton._slope = session.button._slope
               // tempButton._yPosition = session.button._yPosition
                //tempButotn
                //let button = sessionArray[i].button as ONBGuitarButton
            }
            
            
            
            //for i in -27..<7{
            
            /*for i in 0..<self.sessionArray.count{
                let button = ONBGuitarButton()
                button.initWithLane(lane: Int(arc4random_uniform(6)))
                button.setYPosition(yPosition: (3 - CGFloat(i)) * 2.3)
                //button.image = UIImage(named:"GuitarPin_Red.png")
                button.sessionFeedKey = self.sessFeedKeyArray[i]
                
                
                
                
                self.view.addSubview(button)
                self.viewPins.add(button)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.scrollToPin))
                
                tap.numberOfTapsRequired = 1
                button.addGestureRecognizer(tap)
                button.isUserInteractionEnabled = true
                button.session = self.sessionArray[i]
                button.sessionViews = self.viewArray[i]
                self.buttonArray.append(button)
                    
            
            }
            for button in self.viewPins{
                print((button as! ONBGuitarButton)._baseX)
                print((button as! ONBGuitarButton).lane)
            }*/

        })
        
                //self.currentButton = self.currentButtonFunc()

            //self.displaySessionInfo()
        
        
        
        

        // Do any additional setup after loading the view.
    }
    var buttonArray = [ONBGuitarButton]()
    var soloViewArray = [Int]()
    var soloSessionArray = [SessionFeedSess]()
    var soloSessFeedKeyArray = [String]()
    
    var viewArray = [Int]()
    
    var sender = String()
    
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        
        if segue.identifier == "FeedToUpload"{
            if let vc = segue.destination as? FeedDismissable
            {
                vc.feedDismissalDelegate = self
            }
        }
        if segue.identifier == "FeedToProfile"{
            if let vc = segue.destination as? profileRedesignViewController{
                //print(self.cellTouchedArtistUID)
                if self.tabBarPressed == true{
                    vc.fromTabBar = true
                } else {
                    vc.fromTabBar = false
                }
                vc.sender = self.sender
                vc.artistID = cellTouchedArtistUID
                vc.userID = cellTouchedArtistUID
            }
        }
        if segue.identifier == "SessionFeedToBandPage"{
            var tempSess = SessionFeedSess()
            for sess in sessionArray{
                if (sess.button["sessionFeedKey"] as! String) == currentButtonFunc().sessionFeedKey {
                    
                    tempSess = sess
                    break
                }
            }

            if let vc = segue.destination as? SessionMakerViewController{
                vc.sender = self.sender
                vc.sessionID = tempSess.bandID
            }
            
        }
        if segue.identifier == "feedToONB"{
            var tempSess = SessionFeedSess()
            for sess in sessionArray{
                if (sess.button["sessionFeedKey"] as! String) == currentButtonFunc().sessionFeedKey {
                    
                    tempSess = sess
                    break
                }
            }

            if let vc = segue.destination as? OneNightBandViewController{
                vc.sender = self.sender
                vc.onbID = tempSess.bandID
                
            }
        }

    }
    
    
   

    
    
    func scrollToPin(sender: UITapGestureRecognizer){
        let button = sender.view //as! ONBGuitarButton
        let scrollDistance = 13 - sqrt((button?.center.y)! - 200)
       
        UIView.animate(withDuration: 0.5, animations:{self.viewPins.forEach { button in
            (button as! ONBGuitarButton).offsetYPosition(offset: scrollDistance)
            self.scrollOffset += scrollDistance
            }

            }, completion: {
                (value: Bool) in
                self.displaySessionInfo()
        })
    }
        //func goToSession()
    @IBOutlet weak var guitarPickButton: UIButton!
  
    @IBAction func guitarPickPressed(_ sender: Any) {
        if guitarPickButton.imageView?.image == UIImage(named: "s_solid_white-1.png"){
            guitarPickButton.setImage(UIImage(named: "s_goldenrod-1.png"), for: .normal)
        }else{
            guitarPickButton.setImage(UIImage(named: "s_solid_white-1.png"), for: .normal)
        }
        
    }
    var sessionArtists = [Artist]()
    public func tableView(_
        : UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        
        return artistDict.keys.count
    }
    var cellTouchedArtistUID = String()
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //(tableView.cellForRow(at: indexPath) as ArtistCell).artistUID
        self.cellTouchedArtistUID = (tableView.cellForRow(at: indexPath) as! ArtistCell).artistUID
        print(self.cellTouchedArtistUID)
        performSegue(withIdentifier: "FeedToProfile", sender: self)
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath as IndexPath) as! ArtistCell
        let tempArtist = Artist()
        //let userID = Auth.auth().currentUser?.uid
        var tempArtistArray = [String]()
        var tempInstrumentArray = [String]()
        for (key, value) in artistDict{
            tempArtistArray.append(key)
            tempInstrumentArray.append(value)
        }
        
        ref.child("users").child(tempArtistArray[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            let dictionary = snapshot.value as? [String: AnyObject]
            tempArtist.setValuesForKeys(dictionary!)
            
            /*var tempInstrument = ""
             let userID = Auth.auth().currentUser?.uid
             for value in self.thisSession.sessionArtists{
             if value.key == userID{
             tempInstrument = value.value as! String
             
             }
             }*/
            cell.artistUID = tempArtist.artistUID!
            
            cell.artistNameLabel.text = tempArtist.name
            cell.artistInstrumentLabel.text = "test"
            cell.artistImageView.loadImageUsingCacheWithUrlString(tempArtist.profileImageUrl.first!)
            cell.artistInstrumentLabel.text = tempInstrumentArray[indexPath.row]
            
        })
        return cell
    }
    
    @IBOutlet weak var sizeView: UIView!

    
    var artistDict = [String: String]()
    
    
    func displaySessionInfo(){
        //picArray.removeAll()
        //bandMedia.removeAll()
        print("jpppppp")
        picVidSegment.selectedSegmentIndex = 0
        self.sessionNameLabel.isHidden = true
       // self.sessionLabel.isHidden = true
        //self.bandLabel.isHidden = true
        self.bandNameButton.isHidden = false
        self.bandNameButton.layer.cornerRadius = 10
        self.sessionBioTextView.isHidden = true
        self.artistTableView.isHidden = true
        //self.sessionArtistsLabel.isHidden = true
       // self.bioLabel.isHidden = true
       // self.sessionPicksLabel.isHidden = true

        picVidSegment.isHidden = false
        videoCollect.isHidden = true
        picCollect.isHidden = false
        sessionNameLabel2.isHidden = true
        sessionViewsLabel2.isHidden = true
        dropMenu?.isHidden = false
        dropMenu?.setLabelColorWhen(normal: UIColor.orange, selected: UIColor.orange.withAlphaComponent(0.6), disabled: UIColor.gray)
        artistDict.removeAll()
        let cButton = currentButtonFunc()
        var tempSess = SessionFeedSess()
        for sess in sessionArray{
            if (sess.button["sessionFeedKey"] as! String) == cButton.sessionFeedKey {
                
                tempSess = sess
                break
            }
        }

        //if cButton.isDisplayed == true{
            //8888self.player?.playerView.isHidden = false
            //sessInfoView.isHidden = false
            //dropMenu?.dropDownViewTitles = [(cButton.session?.sessionName!)!]
            dropMenu?.backgroundColor = UIColor.clear
            //dropMenu?.bringSubview(toFront: sessInfoView)
            //dropMenu.view
            //dropMenu?.dropDownViewTitles.append(cButton.sessionName)
            //changeMenu(title: cButton.sessionName, at: 0)
            f
            let tempLabel = tempSess.sessionName
            sessionNameLabel.text = tempLabel
        bandNameButton.setTitle(tempSess.bandName, for: .normal)
        sessionBioTextView.text = tempSess.sessionBio
        sessionBioTextView.isEditable = false
        
        
        
            //sessionViewCountLabel.text = "Views: \(String(describing: cButton.sessionViews!))"
                sessionNameLabel2.text = tempLabel
                sessionViewsLabel2.text = "Views: \(String(describing: cButton.sessionViews!))"
                for (key, value) in (tempSess.sessionArtists){
                    self.artistDict[key] = value as? String
                }
            
                for _ in artistDict.keys{
                    let cellNib = UINib(nibName: "ArtistCell", bundle: nil)
                    self.artistTableView.register(cellNib, forCellReuseIdentifier: "ArtistCell")
                    self.artistTableView.delegate = self
                    self.artistTableView.dataSource = self
                }
            //need to fix this to play proper video
        bandMedia.removeAll()
        picArray.removeAll()
        for sess in self.sessionArray{
            if sess.sessionID == (tempSess.sessionID) {
                if sess.sessionMedia.count != 0{
                    for vid in sess.sessionMedia{
                        bandMedia.append(NSURL(string: vid)!)
                    }
                
                var tempPicArray = tempSess.sessionPictureURL
                for pic in tempPicArray{
                    if let url = NSURL(string: pic){
                        if let data = NSData(contentsOf: url as URL){
                            self.picArray.append(UIImage(data: data as Data)!)
                        }
                    }
                }
                }

             break
            }
        }
        DispatchQueue.main.async{
            for _ in self.bandMedia{
                
                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                self.videoCollect.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                
                self.videoCollect.backgroundColor = UIColor.clear
                self.videoCollect.dataSource = self
                self.videoCollect.delegate = self
                
            }
            for _ in self.picArray{
                print("picArray")
                let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                self.picCollect.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                
                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                self.picCollect.backgroundColor = UIColor.clear
                self.picCollect.dataSource = self
                self.picCollect.delegate = self
                
            }
            DispatchQueue.main.async{
                self.picCollect.reloadData()
            }

        }
        
        
      
        
        //when Cell begins playing
                swiftTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(SessionFeedViewController.updateCounter), userInfo: nil, repeats: true)
        
                //print("ct \(player?.currentTime)")
           
            //}else{
                //currentButtonFunc().setIsDiplayedButton(isDisplayedButton: false)
            
               // self.player?.stop()
            //cButton.setIsDiplayedButton(isDisplayedButton: false)
           // }
        /*}else{
            //self.sessInfoView.isHidden = true
            self.player?.stop()
            self.player?.playerView.isHidden = true
            sessionNameLabel.text = " "
            
            sessionViewCountLabel.text = " "
        }*/
        DispatchQueue.main.async{
            self.artistTableView.reloadData()
            
            
        }

    }
    var sizingCell = PictureCollectionViewCell()
    var sizingCell2 = VideoCollectionViewCell()
        var bandMedia = [NSURL]()
    var swiftTimer = Timer()
    //problem is caused by current button moving before update count occurs
    func playerDidFinishPlaying(note: NSNotification){
        var tempSess = SessionFeedSess()
        for sess in sessionArray{
            if sess.sessionID == currentButtonFunc().sessionFeedKey{
                
                tempSess = sess
                break
            }
        }
        //tempSess.setValuesForKeys(self.sessionArray. index(of: <#T##SessionFeedSess#>) [currentButtonFunc().sessionFeedKey])
        print("pf")
        currentButtonFunc().sessionViews! += 1
        viewArray[sessionArray.index(of: tempSess)!] += 1
    }
    
    var count = Int()
    func updateCounter() {
        
        var tempSess = SessionFeedSess()
        for sess in sessionArray{
            if sess.sessionID == currentButtonFunc().sessionFeedKey{
                
                tempSess = sess
                break
            }
        }

        if count == 30{
            currentButtonFunc().sessionViews! += 1
            //viewArray[sessionArray.index(of: tempSess)!] += 1
            swiftTimer.invalidate()
            count = 0
        }
        count += 1
        //countingLabel.text = String(SwiftCounter++)
    }
    @IBOutlet weak var tableViewBackView: UIView!
    @IBOutlet weak var bioBackView: UIView!
    func hideSessionInfo(){
        tableViewBackView.isHidden = true
        bioBackView.isHidden = true
        self.sessionNameLabel.isHidden = true
        self.bandNameButton.isHidden = true
        //self.sessionLabel.isHidden = true
        //self.bandLabel.isHidden = true
        //self.bandNameButton.isHidden = false
        self.sessionBioTextView.isHidden = true
        self.artistTableView.isHidden = true
        //self.sessionArtistsLabel.isHidden = true
        //self.bioLabel.isHidden = true
        //self.sessionPicksLabel.isHidden = true
        
        picVidSegment.isHidden = true
        videoCollect.isHidden = true
        picCollect.isHidden = true
        sessionNameLabel2.isHidden = true
        sessionViewsLabel2.isHidden = true
        dropMenu?.isHidden = true

    }
    
    var fromTabBar = Bool()
    @available(iOS 2.0, *)
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        self.tabBarPressed = true
        
        if item == tabBar.items?[0]{
            performSegue(withIdentifier: "FeedToFindMusicians", sender: self)
            
            
        } else if item == tabBar.items?[1]{
            performSegue(withIdentifier: "FeedToJoinBand", sender: self)
            
        } else if item == tabBar.items?[2]{
            performSegue(withIdentifier: "FeedToProfile", sender: self)
            
        } else {
            
        }
    }

    
    var tabBarPressed = Bool()
    //var curButton = ONBGuitarButton()
    @IBOutlet weak var displayLine: UIView!
    
    func currentButtonFunc()->ONBGuitarButton{
        
        if self.viewPins.count != 0 {
            var closest = self.viewPins[0]
            for i in viewPins{
                if(fabs((i as! ONBGuitarButton).center.y - CGFloat(kFretY)) < (fabs((closest as! ONBGuitarButton).center.y - CGFloat(kFretY)))){
                    closest = i as! ONBGuitarButton
                
                }
            }
            self.currentButton = (closest as! ONBGuitarButton)
            /*if (currentButton != nil) && currentButton != closest as? ONBGuitarButton{
                currentButton?.setIsDiplayedButton(isDisplayedButton: false)
                self.player?.stop()
            }*/
           // print((closest as! ONBGuitarButton).center.y)
           // print(self.displayLine.bounds.maxY)
            if(closest as! ONBGuitarButton).center.y >= self.displayLine.center.y {
                (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: true)
                
            }else{
                (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
                
                
            }
       
            return (closest as! ONBGuitarButton)
            
        }else{
            let temp = ONBGuitarButton()
            return temp
        }
       
    }
    var touchesBeganBool = Bool()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBeganBool = true
        let t = touches.first
        //print(t)
        firstTouch = (t?.location(in: self.view))!
        //print(firstTouch)
        firstTouch.y /= 15
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //88888self.player?.stop()
        picVidSegment.isHidden = true
        picCollect.isHidden = true
        videoCollect.isHidden = true
        sessionNameLabel2.isHidden = true
        sessionViewsLabel2.isHidden = true
        dropMenu?.isHidden = true
        dropMenu?.hideMenu()
        let t = touches.first
        var nextTouch = t?.location(in: self.view)
        nextTouch?.y /= 15
        if sessionArray.count != 0{
        for i in viewPins{
            (i as! ONBGuitarButton).offsetYPosition(offset: (nextTouch?.y)! - firstTouch.y)
            scrollOffset += (nextTouch?.y)! - firstTouch.y
            //(i as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
            
            
                
            }
            
            

            
            
        
        firstTouch = nextTouch!
            
        /*if ((currentButton?.center.y)! >= self.sessionInfoView.bounds.maxY){
                currentButton?.setIsDiplayedButton(isDisplayedButton: true)
            
        }else{
            currentButton?.setIsDiplayedButton(isDisplayedButton: false)
            }*/
           // if(currentButtonFunc().center.y >= self.sessionInfoView.bounds.maxY){
            //currentButtonFunc().setIsDiplayedButton(isDisplayedButton: true)
            //displaySessionInfo()
       // }
            
        //displaySessionInfo()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBeganBool = false
        /*for i in viewPins{
            //(i as! ONBGuitarButton).offsetYPosition(offset: (nextTouch?.y)! - firstTouch.y)
            //scrollOffset += (nextTouch?.y)! - firstTouch.y
            (i as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
            
            
            
        }*/

        if currentButtonFunc().isDisplayed == true{
            print("j")
            displaySessionInfo()
        }else{
            hideSessionInfo()
        }
    }

    @IBOutlet weak var segmentViewHolder: UIView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var picArray = [UIImage]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == self.picCollect{
            return self.picArray.count
        }else{
            if self.bandMedia.count == 0{
                return 1
            }else{
                return self.bandMedia.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("cell4Item: \(self.currentCollect)")
        if collectionView != self.picCollect{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureVidCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.player?.playerView.playerLayer.frame =  cell.youtubePlayerView.bounds
            cell.indexPath = indexPath
            
            //self.curIndexPath.append(indexPath)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            
            //self.curIndexPath.append(indexPath)
            
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != self.picCollect{
            if (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).videoURL?.absoluteString?.contains("youtube") == false && (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).videoURL?.absoluteString?.contains("youtu.be") == false {
                if (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playbackState == .playing {
                    (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.stop()
                    
                }else{
                    (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playerView.playerLayer.frame =  (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).youtubePlayerView.bounds
                    
                    if (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playbackState == .playing {
                    (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.avplayer.pause()
                    } else {
                        (self.videoCollect.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.avplayer.play()
                    }
                }
                
            }
        }
        
        
        
    }
    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        
        
        if self.bandMedia.count == 0{
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 2
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
            
            
            
            cell.videoURL =  self.bandMedia[indexPath.row] as NSURL?
            if(String(describing: cell.videoURL).contains("youtube") || String(describing: cell.videoURL).contains("youtu.be")){
                cell.youtubePlayerView.loadVideoURL(cell.videoURL as! URL)
                cell.youtubePlayerView.isHidden = false
                cell.player?.view.isHidden = true
                cell.isYoutube = true
            }else{
                cell.player?.setUrl(cell.videoURL as! URL)
                cell.player?.view.isHidden = false
                cell.player?.playerView.playerLayer.frame = cell.youtubePlayerView.bounds
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
        /* switch UIScreen.main.bounds.width{
         case 320:
         
         cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width:320, height:267)
         
         case 375:
         cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:375,height:267)
         
         
         case 414:
         cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:267)
         
         default:
         cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:267)
         
         
         
         }*/
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
            
            return UIEdgeInsetsMake(0, 0, 0, 0)
            /*}else{
             let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.picArray.count)
             let totalSpacingWidth = 10 * (self.picArray.count - 1)
             
             let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
             let rightInset = leftInset
             return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
             }*/
            }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    /*class DropDownView: YNDropDownView {
        // override method to call open & close
        override func dropDownViewOpened() {
            print("dropDownViewOpened")
        }
        
        override func dropDownViewClosed() {
            print("dropDownViewClosed")
        }
    }*/


}

