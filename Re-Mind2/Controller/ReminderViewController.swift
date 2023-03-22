//
//  ReminderViewController.swift
//  Re-Mind2
//
//  Created by Bryan Arambula on 2/23/22.
//

import UIKit
import CoreLocation
import UserNotifications
import CoreData
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class ReminderViewController: UIViewController,CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    

    var reminder = [Reminder]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    DispatchQueue.main.async {
                        self.requestNotifications()
                        //                            self.AdView.load(GADRequest())
                    }
                })
            } else {
                self.requestNotifications()
                //                    self.AdView.load(GADRequest())
            }
        }
        
        loadedData()
        reminderTableV.delegate = self
        reminderTableV.dataSource = self
        
        let logoContainer = UIView(frame: CGRect(x: 0, y: -40, width: 200, height: 100))

        let imageView = UIImageView(frame: CGRect(x: 0, y: -40, width: 200, height: 100))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "title")
        imageView.image = image
        logoContainer.addSubview(imageView)
        navigationItem.titleView = logoContainer
  
        reminderTableV.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: "reminderCell")
        
        
        AdView.adUnitID = "ca-app-pub-4207914941473996/5067984499"
        AdView.rootViewController = self
        AdView.load(GADRequest())
        


    }
    

    
    @IBOutlet weak var reminderTableV:UITableView!
    @IBOutlet weak var AdView: GADBannerView!
    
    func requestNotifications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success {
                // schedule test
                print("Granted permission for notificatons")
            }
            else if error != nil {
                print("error occurred")
            }
        })
        
        UNUserNotificationCenter.current().delegate = self
    }
    

    func saveData(){
        do{
            try context.save()
        }catch{
            print("Error saving data to core data. \(error.localizedDescription)")
        }
        reminderTableV.reloadData()
    }
    
    
    func loadedData(){
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        do{
            reminder = try context.fetch(request)
        }catch{
            print("Error loading data from core data. \(error.localizedDescription)")
        }
        
        reminderTableV.reloadData()
    }
    
    
    
    @IBAction func locationReminder(_ sender:UIButton){
        
        guard let locationVc = storyboard?.instantiateViewController(withIdentifier: "locationVc") as? MapViewController else {
            return
        }
        
        locationVc.complationL = {titleText,bodyText,searchText,uuidString in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let newLocation = Reminder(context: self.context)
                newLocation.title = titleText
                newLocation.body = bodyText
                newLocation.detailsLocation = searchText
                newLocation.identifier = uuidString
                newLocation.detailsBool = true
                self.reminder.append(newLocation)
                self.saveData()
            }
        }
        navigationController?.pushViewController(locationVc, animated: true)
    }
    
    @IBAction func dateReminder(){
        
        guard let dateVc = storyboard?.instantiateViewController(withIdentifier: "dateVc") as? DateViewController else {
            return
        }
        dateVc.completion = {title,body,date,uuidString in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = Reminder(context: self.context)
                new.title = title 
                new.body = body
                new.identifier = uuidString
                new.detailsDate = date
                new.detailsBool = false
                self.reminder.append(new)
                self.saveData()
                
            }
            
        }
        
        navigationController?.pushViewController(dateVc, animated: true)
        
    }
    
}

extension ReminderViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
        
        if reminder[indexPath.row].detailsBool == true{
            cell.titleLabel.text = reminder[indexPath.row].title 
            cell.bodyLabel.text = reminder[indexPath.row].body
            cell.detailsLabel.text = reminder[indexPath.row].detailsLocation
        }else if reminder[indexPath.row].detailsBool == false{
            cell.titleLabel.text = reminder[indexPath.row].title
            cell.bodyLabel.text = reminder[indexPath.row].body
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            cell.detailsLabel.text = formatter.string(for: reminder[indexPath.row].detailsDate)
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let completedReminder = storyboard?.instantiateViewController(withIdentifier: "completedR") as? CompletedReminderViewController else {
            return
        }
        completedReminder.completedTitle = reminder[indexPath.row].title
        completedReminder.completedBodyTextView = reminder[indexPath.row].body
        
        if reminder[indexPath.row].detailsBool == true{
            completedReminder.detailsLocation = reminder[indexPath.row].detailsLocation
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            completedReminder.detailsDate = formatter.string(for: reminder[indexPath.row].detailsDate)
        }
        
        navigationController?.pushViewController(completedReminder, animated: true)
        
    }
    
    
  
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        

        if editingStyle == .delete{
            tableView.beginUpdates()
            
            let removedIdentifier = reminder[indexPath.row].identifier ?? ""
            context.delete(reminder[indexPath.row])
            reminder.remove(at: indexPath.row)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [removedIdentifier])
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            saveData()
            
        }
    }
 }


