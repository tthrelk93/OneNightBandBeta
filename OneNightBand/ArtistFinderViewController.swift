//
//  ArtistFinderViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/8/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
//import Firebase
import FirebaseDatabase
import CoreLocation
import FirebaseAuth

protocol WantedAdDelegate : class
{
    func wantedAdCreated(wantedAd: WantedAd)
}



protocol WantedAdDelegator : class
{
    weak var wantedAdDelegate : WantedAdDelegate? { get set }
}



class ArtistFinderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SessionIDDest, PerformSegueInArtistFinderController, UIPickerViewDelegate,UIPickerViewDataSource, WantedAdDelegate, UITabBarDelegate{
 
    @IBOutlet weak var searchByInstrumentButton: UIButton!
    @IBOutlet weak var searchNarrowView: UIView!
    @IBOutlet weak var postToBoardButton: UIButton!
    var thisONBObject = ONB()
    var thisBandObject = Band()
    
    func wantedAdCreated(wantedAd: WantedAd) {
        self.wantedAd = wantedAd
        print("WantedAd: \(self.wantedAd)")
        performSegue(withIdentifier: "ArtistFinderToPFM", sender: self)
    }
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBAction func postToBoardButtonPressed(_ sender: Any) {
        self.destination = "wanted"
        self.buttonSelected = "wanted"
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateWantedAdViewController") as! CreateWantedAdViewController
        self.addChildViewController(popOverVC)
        if self.bandID.isEmpty || self.bandID == ""{
            popOverVC.bandID = ""
            popOverVC.bandType = ""
        } else {
            popOverVC.bandID = self.bandID
            popOverVC.bandType = self.bandType
            if self.bandType == "band"{
            popOverVC.bandObject = self.thisBandObject
            } else {
                popOverVC.onbObject = self.thisONBObject
            }
        }
        popOverVC.wantedAdDelegate = self
        
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
            //searchNarrowView.isHidden = true
        
        
    }
    var senderScreen = String()
    @IBAction func afBackButton(_ sender: Any) {
        if self.senderScreen == "band"{
            performSegue(withIdentifier: "afBackToBand", sender: self)
        } else if self.senderScreen == "onb"{
            performSegue(withIdentifier: "afBackToONB", sender: self)
        } else if self.senderScreen == "pfm" {
            performSegue(withIdentifier: "afBackToPFM", sender: self)
        }
    }
    @IBAction func searchByInstrumentPressed(_ sender: Any) {
        //searchNarrowView.isHidden = true
        
        self.destination = "artistFinder"
        self.buttonSelected = "artistFinder"
        //performSegue(withIdentifier: "ArtistFinderToPFM", sender: self)
        self.searchNarrowView.isHidden = true
    }
    @IBOutlet weak var InstrumentPicker: UIPickerView!
    
    @IBOutlet weak var artistCollectionView: UICollectionView!
    
    
    @IBOutlet weak var noArtistsFoundLabel: UILabel!
    
    var sizingCell: ArtistCardCell?
    weak var getSessionID : GetSessionIDDelegate?
    var artistPageViewController: UIPageViewController!
    var artistArray = [Artist]()
    var ref = Database.database().reference()
    var thisSession: String!
    var thisSessionObject: Band!
    var bandID = String()
    var bandType = String()
    var instrumentPicked: String!
    var distancePicked: String!
    var profileArtistUID: String?
    var wantedAd = WantedAd()
    var destination = String()
    var buttonSelected = String()
    var cityDict = ["New York":"","Los Angeles":"","Chicago":"","Houston":"","Philadelphia":"","Phoenix, AZ":"","San Antonio":"","San Diego":"","Dallas":"","San Jose":"", "Austin":"","Jacksonville": "","San Francisco":"","Indianapolis":"","Columbus":"", "Fort Worth":"","Charlotte":"","Detroit":"","El Paso":"","Seattle":"","Denver":"","Washington ":"","Memphis":"","Boston":"","Nashville":"","Atlanta":""]
    var distanceMenuText = ["25", "50", "75", "100", "125","150", "175","500", "2000"]
    var menuText = ["All","Guitar", "Bass Guitar", "Piano", "Saxophone", "Trumpet", "Stand-up Bass", "violin", "Drums", "Cello", "Trombone", "Vocals", "Mandolin", "Banjo", "Harp"]
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier! as String) == "ArtistFinderToPFM"{
            
                if let vc = segue.destination as? ProfileFindMusiciansViewController{
                    if buttonSelected == "wanted"{
                        vc.wantedAd = self.wantedAd
                        vc.destination = self.destination
                    } else {
                
                        vc.destination = self.destination
                    }
            }

        } else if segue.identifier! == "afBackToONB" {
            if let vc = segue.destination as? OneNightBandViewController{
                vc.onbID = self.bandID
                
                
            }
        } else if segue.identifier! == "afBackToBand" {
            if let vc = segue.destination as? SessionMakerViewController{
                vc.sessionID = self.bandID
            }
        } else {
            
        
        }

        
    }
    


    @IBOutlet weak var searchButton: UIButton!
    func performSegueToProfile(artistUID: String) {
        self.profileArtistUID = artistUID
        performSegue(withIdentifier: "FinderToProfile", sender: self)
    }
    @IBOutlet weak var distancePicker: UIPickerView!
    
    var coordinateUser1: CLLocation?
    var coordinateUser2: CLLocation?
    //var distance: Double?
    
    var tempLong: CLLocationDegrees?
    var tempLat: CLLocationDegrees?
    var distanceInMeters: Double?
    var artistAfterDist = [Artist]()
    
    var instrumentArray = [String]()
    @IBAction func searchForArtistsPressed(_ sender: AnyObject) {
        var tempCoordinate: CLLocation?
        var tempLong: CLLocationDegrees?
        var tempLat: CLLocationDegrees?
        var tempCoordinate2: CLLocation?
        var tempLong2: CLLocationDegrees?
        var tempLat2: CLLocationDegrees?
        var tempDistInMeters: Double?
        artistArray.removeAll()
        artistAfterDist.removeAll()
        instrumentArray.removeAll()
        self.instrumentPicked = self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]
        print("ip: \(instrumentPicked)")
        artistArray = [Artist]()
        artistAfterDist = [Artist]()
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                var artistsAlreadyInSession = [String]()
                for snap in snapshots{
                    let dictionary = snap.value as? [String: Any]
                    let artist = Artist()
                    artist.setValuesForKeys(dictionary!)
                    self.artistArray.append(artist)
                }
                var tempRef = DatabaseReference()
                if self.bandType == "band"{
                    tempRef =  Database.database().reference().child("bands").child(self.bandID).child("bandMembers")
                }
                else{
                    tempRef =  Database.database().reference().child("oneNightBands").child(self.bandID).child("onbArtists")
                }
                   tempRef.observeSingleEvent(of: .value, with: { (ssnapshot) in
                    if let ssnapshots = ssnapshot.children.allObjects as? [DataSnapshot]{
                        for ssnap in ssnapshots{
                            artistsAlreadyInSession.append(ssnap.value as! String)
                        }
                    }
                   
                    for artist in self.artistArray{
                        self.instrumentArray.removeAll()
                        if(artist.artistUID != Auth.auth().currentUser?.uid){
                                if(artistsAlreadyInSession.contains(artist.artistUID!) == false){
                                        for key in artist.instruments.keys{
                                            self.instrumentArray.append(key)
                                        }
                                        print("test: \(self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)])")
                                    if self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)] == "All" {
                                        
                                    } else {
                                        //remove artists from array who dont play instrument pickked
                                    
                                        if(self.instrumentArray.contains(self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]) == false){
                                            self.artistArray.remove(at: self.artistArray.index(of: artist)!)
                                        }
                                    }
                            }
                        }else{
                            self.artistArray.remove(at: self.artistArray.index(of: artist)! )
                        }
                    }
                    DispatchQueue.main.async{
                        print(self.artistArray)
                        let userID = Auth.auth().currentUser?.uid
                        self.ref.child("users").child(userID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
                            for artist in self.artistArray{
                                                               print("in artitAfterDist filler")
                                tempLong = artist.location["long"] as? CLLocationDegrees
                                tempLat = artist.location["lat"] as? CLLocationDegrees
                                
                                tempCoordinate = CLLocation(latitude: tempLat!, longitude: tempLong!)
                                
                                let geoCoder = CLGeocoder()
                                //let location = CLLocation(latitude: tempCoordinate.latitude, longitude: touchCoordinate.longitude)
                                geoCoder.reverseGeocodeLocation(tempCoordinate!, completionHandler: { (placemarks, error) -> Void in
                                    
                                    // Place details
                                    var placeMark: CLPlacemark!
                                    placeMark = placemarks?[0]
                                    
                                    // Address dictionary
                                    print(placeMark.addressDictionary as Any)
                                    
                                
                                    // City
                                    if let city = placeMark.addressDictionary!["City"] as? NSString {
                                        print(city)
                                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                            for snap in snapshots{
                                                if snap.key == "long"{
                                                    tempLong2 = snap.value as? CLLocationDegrees
                                                }else{
                                                    tempLat2 = snap.value as? CLLocationDegrees
                                                }
                                            }
                                            tempCoordinate2 = CLLocation(latitude: tempLat2!, longitude: tempLong2!)
                                            
                                            geoCoder.reverseGeocodeLocation(tempCoordinate2!, completionHandler: { (placemarks, error) -> Void in
                                                
                                                // Place details
                                                var placeMark: CLPlacemark!
                                                placeMark = placemarks?[0]
                                                
                                                // Address dictionary
                                                print(placeMark.addressDictionary as Any)
                                                
                                                
                                                // City
                                                if let city2 = placeMark.addressDictionary!["City"] as? NSString {
                                                    var tempInt = self.distancePicker.selectedRow(inComponent: 0) as Int
                                                    
                                                    if self.cityNameArray[self.distancePicker.selectedRow(inComponent: 0)] == "Current" {
                                                        if city2 == city{
                                                            self.artistAfterDist.append(artist)
                                                        }
                                                    } else if self.cityNameArray[self.distancePicker.selectedRow(inComponent: 0)] == "All"{
                                                        self.artistAfterDist.append(artist)
                                                    } else {
                                                        if city2 as String == self.cityNameArray[tempInt] {
                                                            self.artistAfterDist.append(artist)
                                                        }
                                                    }
                                                    
                                                }
                                
                                        /*    tempDistInMeters = tempCoordinate?.distance(from: tempCoordinate2!)
                                            let distanceInMiles = Double(round(10*(tempDistInMeters! * 0.000621371))/10)
                                            //print(distanceInMiles)
                                            if distanceInMiles <= Double(self.distanceMenuText[self.distancePicker.selectedRow(inComponent: 0)])!{
                                                print(distanceInMiles)
                                                self.artistAfterDist.append(artist)
                                                //tempIndex += 1
                                            }*/
                print(self.artistAfterDist)
                            if self.artistAfterDist.isEmpty{
                                self.noArtistsFoundLabel.isHidden = false
                                self.artistCollectionView.isHidden = true
                                
                            }else{
                                self.noArtistsFoundLabel.isHidden = true
                                self.artistCollectionView.isHidden = false

                                for _ in self.artistAfterDist{
                                    self.InstrumentPicker.delegate = self
                                    self.InstrumentPicker.dataSource = self
                                    self.distancePicker.delegate = self
                                    self.distancePicker.dataSource = self
                                    let cellNib = UINib(nibName: "ArtistCardCell", bundle: nil)
                                    self.artistCollectionView.register(cellNib, forCellWithReuseIdentifier: "ArtistCardCell")
                                    self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! ArtistCardCell?
                                    self.artistCollectionView.dataSource = self
                                    self.artistCollectionView.delegate = self
                                    
                                    self.artistCollectionView.reloadData()
                                    self.artistCollectionView.gestureRecognizers?.first?.cancelsTouchesInView = false
                                    self.artistCollectionView.gestureRecognizers?.first?.delaysTouchesBegan = false
                                }
                                
                                
                                                }
                                            })
                                        }
                                    }
                                })
                            }
                        })
                    }
                })
            }
            
            
            
        })
    }


    
    
    
            
        
        
                        
                                        
                                
                            
                              
            
            
            
     let ONBPink = UIColor(colorLiteralRed: 201.0/255.0, green: 38.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    var cityArray = String()
    var cityNameArray = [String]()
    var cityInfoDict = [String:Any]()
   override func viewDidLoad() {
        super.viewDidLoad()
    if /*self.PFMChoiceSelected == true ||*/ self.senderScreen == "band" || self.senderScreen == "onb"{
        searchNarrowView.isHidden = true
    } else {
        searchNarrowView.isHidden = false
    }
    ref.child("cityData").observeSingleEvent(of: .value, with: { (snapshot) in
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
            self.cityNameArray.append("All")
            self.cityNameArray.append("Current")
            for snap in snapshots{
                self.cityNameArray.append(snap.key)
            }
            
        }
    })
    
    //let tempCityDict = tempCityData.cityDict
    //ref.child("wantedAds").childByAutoId()
   /* var tempDict = [String:Any]()
    var tempArray = [[String:Any]]()
    for city in tempCityDict{
        var newCityDict = [String:Any]()
        var cityName = String()
        for (key, val) in city{
            if (key as String) == "city" || (key as String) == "longitude" || (key as String) == "latitude" || (key as String) == "state" {
                if (key as String) == "city"{
                    cityName = val as! String
                    cityNameArray.append(cityName)
                    
                }
                newCityDict[key] = val
            }
        }
        tempDict[cityName] = newCityDict
    }
    var uploadData = [String:Any]()
    uploadData["cityData"] = tempDict as [String:Any]
    self.ref.child("cityData").updateChildValues(tempDict)*/
    
   /* for (key, _) in cityDict{
        self.cityArray.append(key )
        
    }*/
    
        checkIfUserIsLoggedIn()
    tabBar.delegate = self
    self.postToBoardButton.layer.borderColor = ONBPink.cgColor
    self.postToBoardButton.layer.borderWidth = 2
    self.searchByInstrumentButton.layer.borderColor = ONBPink.cgColor
    self.searchByInstrumentButton.layer.borderWidth = 2
        noArtistsFoundLabel.isHidden = false
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        artistCollectionView.collectionViewLayout = layout
        InstrumentPicker.selectRow(menuText.count/2, inComponent: 0, animated: true)
    }
    var currentUser: String?
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleBack), with: nil, afterDelay: 0)
        } else {
            
            currentUser = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        if let dictionary = snap.value as? [String: AnyObject] {
                        let artist = Artist()
                        artist.setValuesForKeys(dictionary)
                        self.artistArray.append(artist)

                    }
                }
            }
                //self.artistCollectionView.gestureRecognizers?.first?.cancelsTouchesInView = false
                self.InstrumentPicker.delegate = self
                self.InstrumentPicker.dataSource = self
                self.distancePicker.delegate = self
                self.distancePicker.dataSource = self
                self.InstrumentPicker.selectRow(self.menuText.count/2, inComponent: 0, animated: false)
                
            }, withCancel: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return artistAfterDist.count
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCardCell", for: indexPath as IndexPath) as! ArtistCardCell
        cell.delegate = self
        
        
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        return cell

        
    }

    func configureCell(_ cell: ArtistCardCell, forIndexPath indexPath: NSIndexPath) {
        cell.artistCardCellBioTextView.text = artistAfterDist[indexPath.row].bio
        cell.artistCardCellNameLabel.text = artistAfterDist[indexPath.row].name
        
        cell.artistCardCellImageView.loadImageUsingCacheWithUrlString(artistAfterDist[indexPath.row].profileImageUrl.first!)
        cell.artistUID = artistAfterDist[indexPath.row].artistUID
        if self.bandType == "onb"{
            cell.artistCount = self.thisONBObject.onbArtists.count
            cell.bandName = self.thisONBObject.onbName
            cell.invitedBandID = self.thisONBObject.onbID
            cell.sessionDate = self.thisONBObject.onbDate
            
        } else {
            cell.artistCount = self.thisBandObject.bandMembers.count
            cell.bandName = self.thisBandObject.bandName!
            cell.invitedBandID = self.thisBandObject.bandID
            cell.sessionDate = "n/a"
            
        }
        
        cell.bandType = self.bandType
        
        cell.buttonName = self.instrumentPicked
        //cell.sessionDate = self.thisSessionObject.sessionDate
        
        self.ref.child("users").child(artistAfterDist[indexPath.row].artistUID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                        if snap.key == "long"{
                            self.tempLong = snap.value as? CLLocationDegrees
                            
                        }else{
                            self.tempLat = snap.value as? CLLocationDegrees
                        }
                    }
                
                self.coordinateUser2 = CLLocation(latitude: self.tempLat!, longitude: self.tempLong!)
                let userID = Auth.auth().currentUser?.uid
                self.ref.child("users").child(userID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        
                        for snap in snapshots{
                                if snap.key == "long"{
                                    self.tempLong = snap.value as? CLLocationDegrees
                                    
                                }else{
                                    self.tempLat = snap.value as? CLLocationDegrees
                                }
                            }
                        self.coordinateUser1 = CLLocation(latitude: self.tempLat!, longitude: self.tempLong!)
                        
                        self.distanceInMeters = self.coordinateUser1?.distance(from: self.coordinateUser2!) // result is in meters
                        
                        let distanceInMiles = Double(round(10*(self.distanceInMeters! * 0.000621371))/10)
                        

                        /*if((distanceInMeters! as Double) <= 1609){
                         // under 1 mile
                         }
                         else
                         {
                         // out of 1 mile
                         }*/
                    }
                })
            }
        })
        self.ref.child("users").child(artistAfterDist[indexPath.row].artistUID!).child("instruments").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    if snap.key == self.instrumentPicked{
                        cell.reputationLabel.text = "Lvl: \(self.playingLevelArray[(snap.value as! [Int])[0]])"
                        cell.distanceLabel.text = "Years: \(self.playingYearsArray[(snap.value as! [Int])[1]])"
                    }
                }
                
            }
        })
    }
    
    @available(iOS 2.0, *)
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items?[0]{
            
        } else if item == tabBar.items?[1]{
            performSegue(withIdentifier: "ArtistFinderToFindBand", sender: self)
            
        } else if item == tabBar.items?[2]{
            performSegue(withIdentifier: "ArtistFinderToProfile", sender: self)
        } else {
            performSegue(withIdentifier: "ArtistFinderToSessionFeed", sender: self)
        }
    }

    
    var artistCount = Int()
    var yearsArray = [String]()
    var playingYearsArray = ["1","2","3","4","5+","10+"]
    var playingLevelArray = ["beginner", "intermediate", "advanced", "expert"]
    var PFMChoiceSelected = Bool()

    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == self.distancePicker{
            return cityNameArray.count
        }else{
            return menuText.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == self.distancePicker{
            let titleData = self.cityNameArray[row]
            
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.black])
            return myTitle
        }else{
            let titleData = menuText[row]
            
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
            return myTitle

        }
    
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
    }
    func handleBack() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let sessTemp = SessionMakerViewController()
        present(sessTemp, animated: true, completion: nil)
    }

    
    
}



