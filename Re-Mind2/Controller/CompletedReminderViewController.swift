//
//  CompletedReminderViewController.swift
//  Re-Mind2
//
//  Created by Bryan Arambula on 3/11/22.
//

import UIKit
import GoogleMobileAds
import StoreKit

class CompletedReminderViewController: UIViewController,UITextViewDelegate {
    
    var completedTitle:String?
    var completedBodyTextView:String?
    var detailsLocation:String?
    var detailsDate:String?
    var dismissAlert:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completedLabel.text = completedTitle
        bodyTextView.text = completedBodyTextView
        bodyTextView.isEditable = false
        navigationItem.hidesBackButton = true
        detailsLabel.text = detailsLocation ?? detailsDate
        detailsLabel.layer.cornerRadius = detailsLabel.frame.height / 2
        detailsLabel.layer.masksToBounds = true
        navigationController?.navigationBar.tintColor = .white
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.sizeToFit()
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        adView.adUnitID = "ca-app-pub-4207914941473996/5067984499"
        adView.rootViewController = self
        adView.load(GADRequest())
        
        
    }
    
    
    @IBOutlet weak var completedLabel:UILabel!
    @IBOutlet weak var bodyTextView:UITextView!
    @IBOutlet weak var detailsLabel:UILabel!
    @IBOutlet weak var adView:GADBannerView!

    @objc func backButtonPressed(){
        
        let disalert: Bool = UserDefaults.standard.bool(forKey: "disalert")
        
        if disalert{
            navigationController?.popToRootViewController(animated: true)
            print("shown already")
        }else{
            
            let alerted = UIAlertController(title: "Enjoying Remind-Me?", message: "If you are, Tap that you love it to rate us in the App store, tell us what you enjoy or tap how to improve and let us know how we can do better", preferredStyle: .alert)
            
            alerted.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                

                self.navigationController?.popToRootViewController(animated: true)
               
            }))
            
            alerted.addAction(UIAlertAction(title: "I love it!", style: .default, handler: { [weak self]_ in
                
   
                UserDefaults.standard.set(true, forKey: "disalert")
                
                guard let scene = self?.view.window?.windowScene else {
                    print("There is no scene")
                    return
                }
    
                SKStoreReviewController.requestReview(in: scene)
                
//                guard let writeReviewURL = URL(string: "https://apps.apple.com/us/app/remind-me-reminders/id1617564386")
//                else { fatalError("Expected a valid URL") }
//                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
//                self?.navigationController?.popToRootViewController(animated: true)
                
            }))
            
            alerted.addAction(UIAlertAction(title: "How to improve", style: .default, handler: { action in
                
                UserDefaults.standard.set(true, forKey: "disalert")
                
                guard let url = NSURL(string: "mailto:arambula722@gmail.com") else {
                    return
                }
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }))
            
            present(alerted, animated: true)

        }
        
    }
    
}


    



