//
//  Feed.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit


class Feed: UIViewController, UITableViewDataSource, UITableViewDelegate, StoryManagerProtocol {


    var activityView:UIActivityIndicatorView!
    var xibCell:FeedTableViewCell?
    var selectedIndex:Int?
    private let refreshControl = UIRefreshControl()

    //outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var noStoryLabel: UILabel!
    
    let dao = DAOManager.instance?.ckStories

    
    
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
        noStoryLabel.alpha = 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dao = dao {
            return dao.stories.count
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
            let doc = dao.stories[indexPath.row]
            if let content = doc.object(forKey: "content") as? String {
                feedCell.feedTableViewTextField.text = content
            }
//            if let date = doc.object(forKey: "date") as? String {
//                feedCell.dateLabel.text = doc["date"]
//            }
            feedCell.selectionStyle = .none
        }
        return feedCell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
        selectedCell.contentView.backgroundColor = UIColor.clear
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "storyScreen", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell
        selectedCell?.contentView.backgroundColor = UIColor.white
        
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0

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

    func readedStories(stories:[CKRecord]?, error: Error?) {
        if error == nil {
            debugPrint("got stories")
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
                self.activityView.stopAnimating()
            }
            if DAOManager.instance?.ckStories.stories.count == 0 {
                self.noStoryLabel.alpha = 1
                self.noStoryLabel.text = "Ainda não temos relatos postados..."
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
    
    func goTo(identifier: String) {
          DispatchQueue.main.async {
              self.performSegue(withIdentifier: identifier, sender: self)
          }
      }
    
    @objc private func refreshData(_ sender: Any) {
        DAOManager.instance?.ckStories.getStories(requester: self, blocks: [])
        self.refreshControl.endRefreshing()

    }
    
    
    
    
    
    
    
    
    @IBAction func exitButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Deseja mesmo sair?", message: "", preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Sim, desejo sair", style: .default, handler: { (action) -> Void in
                            
                MeUser.instance.delete()
                DaoPushNotifications.instance.delete()
                self.goTo(identifier: "main")
            
        })
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .default ) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(ok)
        alert.addAction(cancelar)
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonOrange

        
    }
}

