//
//  OneNightBandViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 4/6/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class OneNightBandViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, PerformSegueInBandBoard, UICollectionViewDelegate, UICollectionViewDataSource /*GetSessionIDDelegate, DismissalDelegate*/ {
    internal func joinBand(bandID: String, wantedAd: WantedAd) {
        
    }
    @IBOutlet weak var onbNameLabel: UILabel!

    @IBOutlet weak var becomeFanButton: UIButton!
    @IBOutlet weak var fanCount: UILabel!
    
    
    
    @IBAction func becomeFanPressed(_ sender: Any) {
    }
    
    func performSegueToBandPage(bandID: String){
        
    }
    var sender = String()
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var artistTableView: UITableView!
    @IBOutlet weak var onbInfoTextView: UITextView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    @IBAction func addMediaPressed(_ sender: Any) {
        performSegue(withIdentifier: "ONBToAddMedia", sender: self)
    }
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBAction func chatButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ONBToChat", sender: self)
    }
    @IBOutlet weak var findArtistsButton: UIButton!

    @IBAction func findArtistsPressed(_ sender: Any) {
        performSegue(withIdentifier: "ONBToArtistFinder", sender: self)
    }
    @IBOutlet weak var backButton: UIButton!
    var artistDict = [String: Any]()
    var picArray = [UIImage]()
    let ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    var name = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    if snap.key == "name"{
                        self.name = snap.value as! String
                    }
                }
            }
        })

        
        findArtistsButton.setTitleColor(UIColor.darkGray, for: .normal)
         navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        print(sender)
        if sender == "feed" || sender == "bandBoard"{
            backButton.isHidden = false
            addMediaButton.isHidden = true
            chatButton.isHidden = true
            becomeFanButton.isHidden = false
            
            
        } else {
            
            addMediaButton.isHidden = false
            chatButton.isHidden = false
            becomeFanButton.isHidden = true
            

        }
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        pictureCollectionView.collectionViewLayout = layout
        
        artistTableView.dataSource = self
        //addMediaButton.layer.cornerRadius = addMediaButton.frame.width/2
        //chatButton.layer.cornerRadius = chatButton.frame.width/2
        //findArtistsButton.layer.cornerRadius = findArtistsButton.frame.width/2

        // Do any additional setup after loading the view.
        
        ref.child("oneNightBands").child(onbID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                //fill datasources for collectionViews
                for snap in snapshots{
                    if snap.key == "onbPictureURL"{
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
                    if snap.key == "onbName"{
                        self.onbNameLabel.text = snap.value as! String
                    }
                    if snap.key == "onbArtists"{
                        self.artistDict = snap.value as! [String: Any]
                        
                    }
                    if snap.key == "onbDate"{
                        self.dateLabel.text = snap.value as! String
                }
                    if snap.key == "onbInfo"{
                        self.onbInfoTextView.text = snap.value as! String
                    }
                
            }
            }
            
                for _ in self.picArray{
                    let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                    self.pictureCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                    self.pictureCollectionView.backgroundColor = UIColor.clear
                    self.pictureCollectionView.dataSource = self
                    self.pictureCollectionView.delegate = self
            }
            let cellNib = UINib(nibName: "ArtistCell", bundle: nil)
            self.artistTableView.register(cellNib, forCellReuseIdentifier: "ArtistCell")
            self.artistTableView.delegate = self
            self.artistTableView.dataSource = self
            DispatchQueue.main.async{
                self.artistTableView.reloadData()
                //self.sessionVidCollectionView.reloadData()
                //print("vidArray: \(self.vidArray)")
                
            }

        })

        self.ref.child("oneNightBands").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    if (snap.key == self.onbID){
                        
                        let dictionary = snap.value as? [String: AnyObject]
                        //print(dictionary)
                        let tempONB = ONB()
                        tempONB.setValuesForKeys(dictionary!)
                        self.thisONB = tempONB
                    }
                }
            }
        })
        DispatchQueue.main.async{
            if self.sender == "pfm"{
                self.performSegue(withIdentifier: "ONBToArtistFinder", sender: self)
            }
        }



    }
    var onbID = String()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var sizingCell = PictureCollectionViewCell()
    var currentButton = String()
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if self.sender == "bandBoard"{
            performSegue(withIdentifier: "ONBToBandBoard", sender: self)
        }
        if self.sender == "feed"{
            performSegue(withIdentifier: "ONBToFeed", sender: self)
        }
        if self.sender == "profile"{
            performSegue(withIdentifier: "ONBToProf", sender: self)
        }
    }
    //var vidCellBool: Bool?
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        //return (self.thisBand.bandMembers.count)
        return artistDict.count
    }
    var tableViewCellTouched = String()
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
       /* //(tableView.cellForRow(at: indexPath) as ArtistCell).artistUID
        self.cellTouchedArtistUID = (tableView.cellForRow(at: indexPath) as! ArtistCell).artistUID
        performSegue(withIdentifier: "ArtistCellTouched", sender: self)*/
        var tempArray = [String]()
        for (key, val) in self.artistDict{
            tempArray.append(key)
        }
        
        self.tableViewCellTouched = tempArray[indexPath.row]
        self.performSegue(withIdentifier: "ONBToBandMemberProfile", sender: self)
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath as IndexPath) as! ArtistCell
        let tempArtist = Artist()
        //let userID = Auth.auth().currentUser?.uid
        var artistArray = [String]()
        var instrumentArray = [String]()
        for value in thisONB.onbArtists{
            artistArray.append(value.key)
            instrumentArray.append(value.value as! String)
        }
        
        
        ref.child("users").child(artistArray[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
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
            
            print(instrumentArray)
            cell.artistNameLabel.text = tempArtist.name
            cell.artistInstrumentLabel.text = "test"
            cell.artistImageView.loadImageUsingCacheWithUrlString(tempArtist.profileImageUrl.first!)
            cell.artistInstrumentLabel.text = instrumentArray[indexPath.row]
            
        })
        return cell

        /*let tempArtist = Artist()
        //let userID = Auth.auth().currentUser?.uid
        var artistArray = [String]()
        var instrumentArray = [String]()
        for value in thisBand.bandMembers{
            artistArray.append(value.key)
            instrumentArray.append(value.value as! String)
        }
        
        
        ref.child("users").child(artistArray[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
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
            
            print(instrumentArray)
            cell.artistNameLabel.text = tempArtist.name
            cell.artistInstrumentLabel.text = "test"
            cell.artistImageView.loadImageUsingCacheWithUrlString(tempArtist.profileImageUrl.first!)
            cell.artistInstrumentLabel.text = instrumentArray[indexPath.row]
            
        })*/
        return cell
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print(currentButton as Any)
        if collectionView == pictureCollectionView{
            return picArray.count
        }
        else { return 0 }
       
        
    }
    
    var tempIndex: Int?
    var pressedButton: String?
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
        
        tempIndex = indexPath.row
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    
    var selectedCell: SessionCell?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
    }
    var cellArray = [SessionCell]()
    func configureCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        cell.picImageView.image = self.picArray[indexPath.row]
        cell.deleteButton.isHidden = true
       /* if(self.currentButton == "upcoming"){
            print("Whyyyyy")
            if upcomingSessionArray.count == 0{
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Upcoming Sessions"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
            }
            
            if(indexPath.row < upcomingSessionArray.count){
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((upcomingSessionArray[indexPath.row] as Session).sessionPictureURL[0])
                //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
                cell.sessionCellLabel.text = upcomingSessionArray[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
            
        }
        if(self.currentButton == "past"){
            if pastSessionArray.count == 0{
                cell.isHidden = false
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Past Sessions"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false
                if(indexPath.row < pastSessionArray.count){
                    
                    cell.sessionCellImageView.loadImageUsingCacheWithUrlString((pastSessionArray[indexPath.row] as Session).sessionPictureURL[0])
                    cell.sessionCellLabel.text = pastSessionArray[indexPath.row].sessionName
                    cell.sessionCellLabel.textColor = UIColor.white
                    cell.sessionId = bandSessions[indexPath.row]
                }
                
            }
            cellArray.append(cell)
        }
        if(self.currentButton == "feed"){
            if sessionFeedArray.count == 0{
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Sessions On Feed"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false
                
            }
            
            if(indexPath.row < sessionFeedArray.count){
                print(indexPath.row)
                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((sessionFeedArray[indexPath.row] as Session).sessionPictureURL[0])
                cell.sessionCellLabel.text = sessionFeedArray[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
        }
        if(self.currentButton == "active"){
            if activeSessionsArray.count == 0{
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Active Sessions"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
                
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false
            }
            if(indexPath.row < activeSessionsArray.count){
                
                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((activeSessionsArray[indexPath.row] as Session).sessionPictureURL[0])
                cell.sessionCellLabel.text = activeSessionsArray[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
        }
        if(self.currentButton == "all"){
            if allSessions.count == 0{
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Sessions to Show"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false
            }
            if(indexPath.row < allSessions.count){
                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((allSessions[indexPath.row] as Session).sessionPictureURL[0])
                cell.sessionCellLabel.text = allSessions[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
        }
        */
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        /*if(self.currentButton == "active"){
         
         let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.activeSessionsArray.count)
         let totalSpacingWidth = 10 * (self.activeSessionsArray.count - 1)
         
         let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
         let rightInset = leftInset
         return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
         }
         
         else if(self.currentButton == "past"){
         
         let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.pastSessionArray.count)
         let totalSpacingWidth = 10 * (self.pastSessionArray.count - 1)
         
         let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
         let rightInset = leftInset
         return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
         }
         
         else if(self.currentButton == "upcoming"){
         
         let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.upcomingSessionArray.count)
         let totalSpacingWidth = 10 * (self.upcomingSessionArray.count - 1)
         
         let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
         let rightInset = leftInset
         return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
         }
         
         else if(self.currentButton == "all"){
         
         let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.allSessions.count)
         let totalSpacingWidth = 10 * (self.allSessions.count - 1)
         
         let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
         let rightInset = leftInset
         return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
         }
         
         else{
         
         
         let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.sessionFeedArray.count)
         let totalSpacingWidth = 10 * (self.sessionFeedArray.count - 1)
         
         let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
         let rightInset = leftInset
         return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
         
         }*/
        return UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
    var destination = String()

    var thisONB = ONB()
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if (segue.identifier! as String) == "ONBToBandBoard"{
            if let vc = segue.destination as? BandBoardViewController{
                vc.searchType = "OneNightBands"
            }
        }
        if (segue.identifier! as String) == "ONBToArtistFinder"{
            if let vc = segue.destination as? ArtistFinderViewController
            {
                vc.bandID = self.onbID
                vc.thisONBObject = thisONB
                vc.bandType = "onb"
                
            }
        }
        if (segue.identifier! as String) == "ONBToChat"{
            if let vc = segue.destination as? ChatContainer{
                let userID = Auth.auth().currentUser?.uid
                
                vc.name = self.name
                vc.sessionID = self.onbID
                vc.userID = userID!
                vc.bandType = "onb"
                vc.sender = self.sender
                
                
                
                
                
                
            }
        }
        if (segue.identifier! as String) == "ONBToBandMemberProfile"{
            if let vc = segue.destination as? profileRedesignViewController{
                vc.sender = "onb"
                vc.artistID = self.tableViewCellTouched
                vc.senderID = self.onbID
            }
        }
        
        
    }

 

}
