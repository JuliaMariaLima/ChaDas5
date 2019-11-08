//
//  Messages.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit

class Messages: UIViewController, UITableViewDataSource, UITableViewDelegate, ChannelManagerProtocol{
    

    //outlets
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var noStoryLabel: UILabel!

    var messageIsEditing =  false
    var activityView:UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    let dao = DAOManager.instance?.ckChannels

    //actions
    @IBAction func editButton(_ sender: Any) {

        if !messageIsEditing {
            messageIsEditing = true
        } else {
            messageIsEditing = false
        }
        messagesTableView.reloadData()
    }

    override func viewDidLoad() {
        //table view setting
        self.messagesTableView.separatorStyle = .none
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        messagesTableView.allowsSelection = true
        let nib = UINib.init(nibName: "MessagesTableViewCell", bundle: nil)
        self.messagesTableView.register(nib, forCellReuseIdentifier: "MessagesCell")

        if #available(iOS 13.0, *) {
            activityView = UIActivityIndicatorView(style: .medium)
        } else {
            activityView = UIActivityIndicatorView(style: .gray)
        }
        activityView.color = UIColor.buttonOrange
        activityView.frame = CGRect(x: 0, y: 0, width: 300.0, height: 300.0)
        activityView.center = view.center
        activityView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)

        noStoryLabel.alpha = 0

        view.addSubview(activityView)

        activityView.startAnimating()

        messagesTableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.buttonOrange

        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        messageIsEditing =  false

        dao?.getChannels(requester: self)


    }
    
    func readedChannels(channels: [CKRecord]?, error: Error?) {
        if error != nil {
            debugPrint(error!)
        }
        DispatchQueue.main.async {
            self.messagesTableView.reloadData()
            self.activityView.stopAnimating()
        }
        if dao?.channels.count == 0 {
            DispatchQueue.main.async {
                self.noStoryLabel.alpha = 1
                self.noStoryLabel.text = "Você não possui conversas ainda..."
            }
        } else {
            DispatchQueue.main.async {
                self.noStoryLabel.alpha = 0
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dao?.channels.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messagesCell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell") as! MessagesTableViewCell
        messagesCell.deleteButton.alpha = messageIsEditing ? 1 : 0
        messagesCell.nonReadMessages.isHidden = true
            
        if messageIsEditing {
            messagesCell.shake()
        }
        
        if dao?.channels.isEmpty ?? true {
            return messagesCell
        } else {
            if dao?.channels.count ?? 0 < indexPath.row {
                return messagesCell
            }
            guard let currentChannel = dao?.channels[indexPath.row] else {
                return messagesCell
            }
            var username = ""
            guard let owner = currentChannel["owner"] as? String else { fatalError() }
            guard let lastMessageDate = currentChannel["lastMessageDate"] as? String else { fatalError() }
            
            if MeUser.instance.email == owner {
                // username vem da story
                guard let lastOpen = currentChannel["lastOpenByOwner"] as? String else { fatalError() }
                if lastMessageDate > lastOpen {
                    messagesCell.nonReadMessages.isHidden = false
                }
                let user = currentChannel["fromStory"] as! String
                DAOManager.instance?.ckUsers.retrieve(nameFrom: user, completion: { (retrievedUsername, error) in
                    if error == nil && retrievedUsername != nil {
                        username = retrievedUsername!
                        DispatchQueue.main.async {
                            let photo = UIImage.init(named: username)
                            messagesCell.messageTableViewLabel.text = username
                            messagesCell.messageTableViewImage.image = photo
                        }
                    }
                })
            } else {
                // username vem do ownerID
                guard let lastOpen = currentChannel["lastOpenByStoryAuthor"] as? String else { fatalError() }
                if lastMessageDate > lastOpen {
                    messagesCell.nonReadMessages.isHidden = false
                }
                DAOManager.instance?.ckUsers.retrieve(nameFrom: owner, completion: { (retrievedUsername, error) in
                    if error == nil && retrievedUsername != nil {
                        username = retrievedUsername!
                        DispatchQueue.main.async {
                            let photo = UIImage.init(named: username)
                            messagesCell.messageTableViewLabel.text = username
                            messagesCell.messageTableViewImage.image = photo
                        }
                    }
                })
            }
        }
        return messagesCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! MessagesTableViewCell
        selectedCell.contentView.backgroundColor = UIColor.clear
        guard let channel = dao?.channels[indexPath.row] else { return }
        let vc = ChatViewController(channel: channel)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }

    @objc private func refreshData(_ sender: Any) {
        dao?.getChannels(requester: self)
        self.refreshControl.endRefreshing()
        self.messagesTableView.reloadData()
    }

}
