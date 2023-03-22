//
//  DateViewController.swift
//  Re-Mind2
//
//  Created by Bryan Arambula on 2/22/22.
//

import UIKit
import UserNotifications
import GoogleMobileAds

class DateViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .done, target: self, action: #selector(tapSaveButton))
        
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.shadowColor = UIColor.gray.cgColor
        titleTextField.layer.shadowOpacity = 1
        titleTextField.layer.shadowOffset = CGSize(width: 10, height: 5)
        
        bodyViewShadow.layer.cornerRadius = 10
        bodyViewShadow.layer.shadowColor = UIColor.gray.cgColor
        bodyViewShadow.layer.shadowOpacity = 1
        bodyViewShadow.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        datePicker.layer.cornerRadius = 10
        datePicker.layer.shadowColor = UIColor.gray.cgColor
        datePicker.layer.shadowOpacity = 1
        datePicker.layer.shadowOffset = CGSize(width: 10, height: 5)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.overrideUserInterfaceStyle = .light
        
        titleTextField.delegate = self
        
        bodyViewField.delegate = self
        bodyViewField.layer.cornerRadius = 10
        bodyViewField.text = "Details"
        bodyViewField.textColor = UIColor.gray
        
        let logoContainer = UIView(frame: CGRect(x: 0, y: -40, width: 200, height: 100))

        let imageView = UIImageView(frame: CGRect(x: 0, y: -40, width: 200, height: 100))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "Remind-Me")
        imageView.image = image
        logoContainer.addSubview(imageView)
        navigationItem.titleView = logoContainer
        
        hideKeyboardWhenTappedAround()
        
        titleTextField.attributedPlaceholder = NSAttributedString(
                string: "Title",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        navigationController?.navigationBar.tintColor = .white
        
        adView.adUnitID = "ca-app-pub-4207914941473996/5067984499"
        adView.rootViewController = self
        adView.load(GADRequest())


    }
    
    
    public var completion: ((String,String,Date,String)->Void)?
    
    @IBOutlet weak var titleTextField:UITextField!
    @IBOutlet weak var bodyViewField:UITextView!
    @IBOutlet weak var datePicker:UIDatePicker!
    @IBOutlet weak var bodyViewShadow:UIView!
    @IBOutlet weak var adView:GADBannerView!
    
    @objc func tapSaveButton(){
        if let titleField = titleTextField.text, !titleField.isEmpty, let bodyField = bodyViewField.text, !bodyField.isEmpty{
            let targetDate = datePicker.date
            let uuidString = UUID().uuidString

            completion?(titleField,bodyField,targetDate,uuidString)
            
            let content = UNMutableNotificationContent()
            content.title = titleField
            content.body = bodyField
            content.sound = .default
            
            let dateSelected = targetDate
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour , .minute , .second], from: dateSelected), repeats: false)
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let e = error{
                    print("An error occured. \(e)")
                }
            }
        }
    }
    
}

extension DateViewController:UITextFieldDelegate,UITextViewDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField{
            bodyViewField.becomeFirstResponder()
        }
//        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = nil
        }
        
        if titleTextField.text == ""{
            titleTextField.text = "Remind-Me"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = ""
            textView.textColor = UIColor.gray
        }
    }
    

    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)//This code dismisses the keyboard when user taps in any part of the screen
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)//Dismiss screen Selector
    }
}

    

    
    

