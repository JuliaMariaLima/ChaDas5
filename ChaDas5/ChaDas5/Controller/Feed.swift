//
//  Feed.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit

// MARK: -  Declaration
class Feed: UIViewController, UITextFieldDelegate, StoryManagerProtocol {

    // MARK: -  Outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var noStoryImage: UIImageView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    
    var activityView:UIActivityIndicatorView!
    var xibCell:FeedTableViewCell?
    var selectedIndex:Int?
    private let refreshControl = UIRefreshControl()
    var filterByName:Bool { return (searchField.text?.count ?? 0) > 2}
    var filterByNameString:String {return searchField.text?.lowercased() ?? ""}
    var timer = Timer()
    let dao = DAOManager.instance?.ckStories
    var dataSource:[CKRecord] {
        let doc = dao!.stories
        if filterByName {
            var filteredData:[CKRecord] = []
            for i in 0..<doc.count{
                if let content = doc[i].object(forKey: "content") as? String {
                    if content.lowercased().contains(filterByNameString){
                        filteredData.append(doc[i])
                    }
                }
            }
            return filteredData
        } // else
        return doc
    }
    
    // MARK: -  View Configurations
    override func viewDidLoad() {
        //table view setting
        self.feedTableView.separatorStyle = .none
        
        feedTableView.dataSource = self
        feedTableView.delegate = self
        feedTableView.allowsSelection = true
        
        feedTableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.middleOrange
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        let nib = UINib.init(nibName: "FeedTableViewCell", bundle: nil)
        self.feedTableView.register(nib, forCellReuseIdentifier: "FeedCell")
        
        
        // add button shadows
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.23
        addButton.layer.shadowRadius = 4
        
        //search bar settings
        searchField.addTarget(self, action: #selector(uptadeSearchBar), for: .editingChanged)
        searchField.delegate = self
        searchLabel.layer.cornerRadius = 20
        searchLabel.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            activityView = UIActivityIndicatorView(style: .medium)
        } else {
            activityView = UIActivityIndicatorView(style: .gray)
        }
        activityView.color = UIColor.buttonOrange
        activityView.frame = CGRect(x: 0, y: 0, width: 300.0, height: 300.0)
        activityView.center = view.center
        activityView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityView)
        activityView.startAnimating()
        if let dao = dao {
            dao.getStories(requester: self, blocks: [])
        } else {
            debugPrint("error getting connection with dao")
        }
        feedTableView.reloadData()
        noStoryImage.alpha = 0
        uptadeSearchBar()
        hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scheduledTimerWithTimeInterval()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    // MARK: -  Actions
    @IBAction func exitButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Deseja mesmo sair?", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Sim, desejo sair", style: .default, handler: { (action) -> Void in
            MeUser.instance.delete()
            DaoPushNotifications.instance.delete()
            self.goTo(identifier: "main")
            
        })
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel ) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        alert.addAction(cancelar)
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonOrange
    }
    
    // MARK: -  Search Bar
       @objc func uptadeSearchBar(){
           feedTableView.reloadData()
           emptyLabelStatus()
       }
       

       func textFieldShouldClear(_ textField: UITextField) -> Bool {
           uptadeSearchBar()
           noStoryImage.alpha = 0
           return true
       }
       
       func emptyLabelStatus() {
           if filterByName && dataSource.count == 0{
               self.noStoryImage.image = UIImage(named:"emptySearch")
               self.noStoryImage.alpha = 0.5
           }else{
               self.noStoryImage.alpha = 0
           }
       }
       
       // MARK: -  Timer
       func scheduledTimerWithTimeInterval() {
           // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
           timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
       }

       @objc func updateCounting() {
           guard let dao = dao else { return }
           dao.getStories(requester: self, blocks: [])
       }
       
       
       // MARK: -  Callback from request
       func readedStories(stories:[CKRecord]?, error: Error?) {
           if error == nil {
               DispatchQueue.main.async {
                   self.feedTableView.reloadData()
                   self.activityView.stopAnimating()
               }
               if DAOManager.instance?.ckStories.stories.count == 0 {
                   DispatchQueue.main.async {
                       self.noStoryImage.image = UIImage(named:"noStories")
                       self.noStoryImage.alpha = 0.5
                   }
               }
           } else {
               debugPrint("error querying stories", error.debugDescription, #function)
           }
       }
       
       func readedStories(stories: [Story]?, error: Error?) {
           
       }
       
       func readedMyStories(stories: [[CKRecord]]) {
           
       }
       
       func saved(reportRecord: CKRecord?, reportError: Error?) {
           
       }
       
       // MARK: -  Segue
       func goTo(identifier: String) {
             DispatchQueue.main.async {
                 self.performSegue(withIdentifier: identifier, sender: self)
             }
         }
       
          
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "storyScreen" {
               debugPrint("go to Story")
               if let destinationVC = segue.destination as? StoryScreen {
                   if let index = selectedIndex {
                       destinationVC.selectedStory = DAOManager.instance?.ckStories.stories[index]
                   }
               }
           }
           
       }
       
       @objc private func refreshData(_ sender: Any) {
           DAOManager.instance?.ckStories.getStories(requester: self, blocks: [])
           self.refreshControl.endRefreshing()

       }

}

// MARK: -  Extentions

// MARK: -  UITableViewDelegate and UITableViewDataSource extentions
extension Feed: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
         if dao != nil {
              return dataSource.count
         }
         return 0
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedCell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedTableViewCell
        guard let dao = dao else {
            debugPrint("error reaching for Story Manager")
            return feedCell
        }
        if !dao.stories.isEmpty {
            
            let doc = dataSource[indexPath.row]
            
            if let content = doc.object(forKey: "content") as? String {
                feedCell.feedTableViewTextField.text = content
            }
            guard let author = doc.object(forKey: "author") as? String else {
                fatalError()
            }
            
            guard let flag = doc.object(forKey: "flag") as? Int else {
                fatalError()
            }
            
            if flag >= 5 {
                feedCell.sensitiveView.isHidden = false
                
            } else if flag < 5 {
                feedCell.sensitiveView.isHidden = true
            }
            
            if MeUser.instance.email == author {
                feedCell.sensitiveView.isHidden = true
            }
            
            if feedCell.feedTableViewTextField.text.count >= 149 {
                
                feedCell.dots.isHidden = false
            } else {
                feedCell.dots.isHidden = true
            }
            
            feedCell.selectionStyle = .none
        }
         return feedCell
     }
     

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let selectedCell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
         if selectedCell.sensitiveView.isHidden == true {
             selectedCell.contentView.backgroundColor = UIColor.clear
             self.selectedIndex = indexPath.row
             self.performSegue(withIdentifier: "storyScreen", sender: nil)
         }
     }
     
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         let selectedCell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell
         selectedCell?.contentView.backgroundColor = UIColor.white
         
     }
     

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 151.0

     }
}

