//
//  StoryScreen.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit


protocol ChannelCreationObserver {
    func created(channel: Channel)
}


class StoryScreen: UIViewController, ChannelManagerProtocol, ChannelCreationObserver {

    var selectedStory:CKRecord?
    
    let dao = DAOManager.instance?.ckChannels

    // Outlets
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!

    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBOutlet weak var storyTextView: UITextView!

    @IBAction func chatButton(_ sender: Any) {
        guard let channelStory = selectedStory else { return }
        dao?.createChannel(withStory: channelStory, completion: { (record, error) in
            if error != nil {
                debugPrint("error creating channel")
                return
            } else {
                guard let channelRecord = record,
                      let channel = Channel(from: channelRecord) else {
                    debugPrint("no channel created")
                    return
                }
                self.created(channel: channel)
            }
        })
        
    }

    func created(channel: Channel) {
        let vc = ChatViewController(channel: channel)

        self.present(vc, animated: true, completion: nil)
    }

    func readedChannels(channels: [Channel]?, error: Error?) {
        
    }

    @IBAction func archiveButton(_ sender: Any) {
        guard let status = selectedStory?.object(forKey: "status") as? String else {
            debugPrint("error retrieving story status", #function)
            return
        }
        if status == "archived" {
            let alert = UIAlertController(title: "Deseja mesmo desarquivar esse relato?", message: "Esse relato voltará a aparecer para outras pessoa no Feed.", preferredStyle: .alert)

            let desarquivar = UIAlertAction(title: "Desarquivar relato", style: .default, handler: { (action) -> Void in
                    self.selectedStory?.setValue("active", forKey: "status")
                    self.dismiss(animated: true)
            })
            let cancelar = UIAlertAction(title: "Cancelar", style: .default ) { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(desarquivar)
            alert.addAction(cancelar)
            self.present(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor.buttonOrange
        } else {
            let alert = UIAlertController(
                title: "Deseja mesmo arquivar esse relato?",
                message: "Seus relatos arquivados só aparecem no seu perfil e não aparecerão mais para outras pessoas.",
                preferredStyle: .alert
            )

            let arquivar = UIAlertAction(
                title: "Arquivar relato",
                style: .default,
                handler: { (action) -> Void in
                    self.selectedStory?.setValue("archived", forKey: "status")
                    self.dismiss(animated: true)
            })
            let cancelar = UIAlertAction(
            title: "Cancelar",
            style: .default) { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            }

            alert.addAction(arquivar)
            alert.addAction(cancelar)
            self.present(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor.buttonOrange

        }
    }

    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        guard let contentToView = self.selectedStory?["content"] as? String else {
            debugPrint("error retrieving content of story", #function)
            return
        }
        guard let storyAuthor = self.selectedStory?.object(forKey: "author") as? String else {
            debugPrint("error retrieving author of story", #function)
            return
        }
        self.storyTextView.text = contentToView

//        if storyAuthor == MeUser.instance.email {
//            chatButton.isEnabled = false
//        } else {
//            archiveButton.isEnabled = false
//        }
        storyTextView.isEditable = false
    }
}
