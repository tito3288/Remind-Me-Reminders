//
//  MapViewController.swift
//  Re-Mind2
//
//  Created by Bryan Arambula on 2/28/22.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import CoreData
import GoogleMobileAds


class MapViewController: UIViewController {

    let map = MKMapView()
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    let request = MKLocalSearch.Request()
    var activateSearchField : UISearchBar? = nil
    var activateTextField : UITextField? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationTableView.delegate = self
        locationTableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .done, target: self, action: #selector(saveButtonPressed))
        locationTableView.layer.cornerRadius = 10
        titleTextFieldL.delegate = self
        
        bodyViewField.delegate = self
        bodyViewField.text = "Details"
        bodyViewField.textColor = UIColor.gray
        
        searchCompleter.delegate = self
        locationSearchBar.delegate = self
        locationSearchBar.showsCancelButton = true
        //        searchCompleter.region = map.region
        request.naturalLanguageQuery = "Restaurants"
        
        request.region = map.region
        
        bodyViewField.layer.cornerRadius = 5
        textViews.layer.cornerRadius = 8
        
        titleTextFieldL.attributedPlaceholder = NSAttributedString(
                string: "Title",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        titleTextFieldL.textColor = UIColor.gray
        
        navigationController?.navigationBar.tintColor = .link
        
        let paddedStackView = UIStackView(arrangedSubviews: [segmentedControl])
        paddedStackView.layoutMargins = .init(top: 2, left: 12, bottom: 6, right: 12)
        paddedStackView.isLayoutMarginsRelativeArrangement = true

        let stackView = UIStackView(arrangedSubviews: [
            paddedStackView, map
        ])
        
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height / 1.6))
        
        NSLayoutConstraint.activate(constraints)
        
       
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        let logoContainer = UIView(frame: CGRect(x: 0, y: -40, width: 200, height: 100))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: -40, width: 200, height: 100))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "Remind-Me")
        imageView.image = image
        logoContainer.addSubview(imageView)
        navigationItem.titleView = logoContainer
        
        adView.adUnitID = "ca-app-pub-4207914941473996/5067984499"
        adView.rootViewController = self
        adView.load(GADRequest())
        
    }
   
    
    @IBOutlet weak var locationTableView:UITableView!
    @IBOutlet weak var titleTextFieldL:UITextField!
    @IBOutlet weak var bodyViewField:UITextView!
    @IBOutlet weak var adView:GADBannerView!
    @IBOutlet weak var locationSearchBar:UISearchBar!
    @IBOutlet weak var textViews:UIView!
    
    
   @objc func keyboardWillChange(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if locationSearchBar.isFirstResponder {
                self.view.frame.origin.y = 55 - keyboardSize.height
            }
        }
   }

    
    @objc func keyboardWillHide(notification: NSNotification) {
      self.view.frame.origin.y = 0
    }
    
    let segmentedControl:UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Arriving", "Leaving"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = UIColor.secondarySystemBackground
//        sc.addTarget(self, action: #selector(handleSegmentControl), for: .valueChanged)
        return sc
    }()
    
    public var complationL: ((String,String,String,String)->Void)?
    
    @objc func saveButtonPressed(){
        
        if let titleText = titleTextFieldL.text, !titleText.isEmpty,
           let bodyText = bodyViewField.text, !bodyText.isEmpty,
           let searchText = locationSearchBar.text, !searchText.isEmpty{
            
            let uuidString = UUID().uuidString
            
            complationL?(titleText,bodyText,"\(segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!): \(searchText)",uuidString)
            
            if segmentedControl.selectedSegmentIndex == 0{
                if let center = defaults.coordinate(forKey: "cordinadas"){
                    let content = UNMutableNotificationContent()
                    content.title = titleText
                    content.body = bodyText
                    content.sound = .default
                    let entryIdentifier = UUID().uuidString
                    let region = CLCircularRegion(center: center, radius: 300.0, identifier: entryIdentifier)
                    region.notifyOnEntry = true
                    region.notifyOnExit = false
                    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                    let notificationRequest = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(notificationRequest) { error in
                        if error != nil{
                            print("Error providing Arriving notification")
                        }else{
                            print("Succesfully provided Arriving notification")
                        }
                    }
                }
            }else if segmentedControl.selectedSegmentIndex == 1{
                if let center = defaults.coordinate(forKey: "cordinadas"){
                    
                    let content = UNMutableNotificationContent()
                    content.title = titleText
                    content.body = bodyText
                    content.sound = .default
                    let exitIdentifier = UUID().uuidString
                    let region = CLCircularRegion(center: center, radius: 300.0, identifier: exitIdentifier)
                    region.notifyOnEntry = false
                    region.notifyOnExit = true
                    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                    let notificationRequest = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(notificationRequest) { error in
                        if error != nil{
                            print("Error providing Leaving notification")
                        }else{
                            print("Succesfully provided Leaving notification")
                        }
                    }
                }
            }
            
        }
        
    }
    
}

extension MapViewController:UITextFieldDelegate,UITextViewDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == titleTextFieldL{
            bodyViewField.becomeFirstResponder()
        }
//        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Details" {
            textView.text = nil
        }
        
        
        if titleTextFieldL.text == ""{
            titleTextFieldL.text = "Remind-Me"
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = ""
            textView.textColor = UIColor.gray
        }

    }
    
    
    
}


extension MapViewController:UITableViewDelegate,UITableViewDataSource{

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let image = UIImage(systemName: "paperplane.circle.fill")
//        var button = UIButton.Configuration.filled()
////        button.title = "Current Location"
//        button.image = image
////        button.subtitle = defaults.string(forKey: "lname")
//        button.baseBackgroundColor = UIColor.secondarySystemBackground
//        button.baseForegroundColor = UIColor.link
//        button.imagePadding = 5
//        let completedButton = UIButton(configuration: button, primaryAction: nil)
//        completedButton.addTarget(self, action: #selector(currentLocationButton), for: .touchUpInside)
//
//
//        return completedButton
//    }
    
//    @objc func currentLocationButton(){
//        locationSearchBar.text = ""
//        locationManager.requestLocation()
//    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row].title
        cell.detailTextLabel?.text = searchResults[indexPath.row].subtitle
        return cell
    }
}

extension MapViewController:CLLocationManagerDelegate{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        map.isHidden = false
        segmentedControl.isHidden = false
        tableView.deselectRow(at: indexPath , animated: true)
        locationSearchBar.endEditing(true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            
//            let subtitle = response?.mapItems[0].placemark.subtitle
//            print(subtitle as Any)
            if let coordinate = response?.mapItems[0].placemark.coordinate, let names = response?.mapItems[0].name{
                //                print(String(describing: coordinate))//we are printing the coordinates
                //                print(searchRequest)
                
                self.locationSearchBar.text = names
                
                let coordinates = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
                self.defaults.set(coordinate, forKey: "cordinadas")
                                
                self.locationManager(self.locationManager, didUpdateLocations: [coordinates])
                
                
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let pin = MKPointAnnotation()
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
           let overlayRadious = MKCircle(center: center, radius: 300.0)
            
            map.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
            map.delegate = self
            pin.coordinate = center
            map.addAnnotation(pin)
            map.addOverlay(overlayRadious)
            
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)//This code is necessary when using method didUpdateLocations or app will crash
    }

    
    
}


extension MapViewController:MKLocalSearchCompleterDelegate,MKMapViewDelegate{
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        locationTableView.reloadData()
        
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var radiousCircle = MKCircleRenderer()
        if let overlay = overlay as? MKCircle{
            radiousCircle = MKCircleRenderer(circle: overlay)
            radiousCircle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
            radiousCircle.strokeColor = .link.withAlphaComponent(0.5)
            radiousCircle.lineWidth = 1.3
        }
        return radiousCircle
    }
    
}

extension MapViewController:UISearchBarDelegate,UISearchTextFieldDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.locationSearchBar.endEditing(true)
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if searchBar.text == ""{
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        if bodyViewField.text == "Details"{
            bodyViewField.text = ""
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.locationSearchBar.endEditing(true)
    }
    
}

extension UserDefaults {
    func coordinate(forKey defaultName: String ) -> CLLocationCoordinate2D? {
        guard let value = dictionary(forKey: defaultName) as? [String:CLLocationDegrees],
              let lat = value["lat"], let lng = value["lng"] else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    func set(_ value: CLLocationCoordinate2D, forKey defaultName: String) {
        set(["lat": value.latitude, "lng": value.longitude], forKey: defaultName)
    }
    
}








