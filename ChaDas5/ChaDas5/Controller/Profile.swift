//
//  Profile.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit

// MARK: -  Declaration
class Profile: UIViewController {

    // MARK: -  Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var noStoriesImage: UIImageView!
    @IBOutlet weak var pickYouTeaButton: UIButton!
    @IBOutlet weak var imageCircle: UIButton!
    @IBOutlet weak var storiesAndChannelsLabel: UILabel!
    
    var activityView:UIActivityIndicatorView!
    var segmentedControl: CustomSegmentedContrl!
    var selectedIndex:Int?
    var currentSegment:Int = 0
    private let refreshControl = UIRefreshControl()
    var userRequester: UserRequester!
    var meUser: MeUser!
    let dao = DAOManager.instance?.ckMyStories
    let dao2 = DAOManager.instance?.ckChannels
    var timer = Timer()
    
    // MARK: -  View Configurations
    override func viewDidLoad() {
        
        //segmented control customization
        segmentedControl = CustomSegmentedContrl.init(frame: CGRect.init(x: 0, y: 440, width: self.view.frame.width, height: 45))
        segmentedControl.backgroundColor = .baseOrange
        segmentedControl.commaSeperatedButtonTitles = "Relatos atuais, Relatos passados"
        segmentedControl.addTarget(self, action: #selector(onChangeOfSegment(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(segmentedControl)
        
        // Add constraints
        setUpSegmentedControlConstraints()
        
        //table view setting
        self.profileTableView.separatorStyle = .none
        profileTableView.dataSource = self
        profileTableView.delegate = self
        let nib = UINib.init(nibName: "ProfileTableViewCell", bundle: nil)
        self.profileTableView.register(nib, forCellReuseIdentifier: "ProfileCell")
        
        
        if #available(iOS 13.0, *) {
            activityView = UIActivityIndicatorView(style: .medium)
        } else {
            activityView = UIActivityIndicatorView(style: .gray)
        }
        activityView.color = UIColor.buttonOrange
        activityView.frame = CGRect(x: 0, y: 0, width: 300.0, height: 300.0)
        activityView.center = profileTableView.center
        activityView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        noStoriesImage.alpha = 0
        view.addSubview(activityView)
        activityView.startAnimating()
        do {
            try MeUser.instance.load()
            meUser = MeUser.instance
            let storiesCount = dao!.activeStories.count + dao!.nonActiveStories.count
            if storiesCount == 0 || storiesCount == 1 {
                storiesAndChannelsLabel.text = "\(storiesCount) Relato"
            } else {
                
                storiesAndChannelsLabel.text = "\(storiesCount) Relatos"
            }
        } catch {
            print("nao carregou mesmo nao")
        }
        
        userRequester = self
        dao?.loadMyStories(requester: self)
        self.currentSegment = 0
        self.profileTableView.isUserInteractionEnabled = true
        profileTableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.buttonOrange
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
                  try MeUser.instance.load()
                  meUser = MeUser.instance
              } catch {
                  print("nao carregou mesmo nao")
              }


        nameLabel.text = meUser.name
        let storiesCount = dao!.activeStories.count + dao!.nonActiveStories.count
         if storiesCount == 0 || storiesCount == 1{
             storiesAndChannelsLabel.text = "\(storiesCount) Relato"
         }else{

             storiesAndChannelsLabel.text = "\(storiesCount) Relatos"
         }
        profileImage.image = UIImage(named: meUser.name )
        profileImage.contentMode =  UIView.ContentMode.scaleAspectFit
        
        scheduledTimerWithTimeInterval()

    }

    
    // MARK: -  Segemented Control Adjustments
    @objc func onChangeOfSegment(_ sender: CustomSegmentedContrl) {
        self.currentSegment = sender.selectedSegmentIndex
        profileTableView.reloadData()
        image()
        
    }
    
    private func setUpSegmentedControlConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 70),
            segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: profileTableView.topAnchor, constant: -40),
            segmentedControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 45)
        ])
    }
    
    func image() {
        let imagesNames = [UIImage(named: "noActiveStories"), UIImage(named: "noArchiveStories")]
        self.noStoriesImage.image = imagesNames[self.currentSegment]
        if currentSegment == 0 && dao?.activeStories.count == 0 {
            self.noStoriesImage.alpha = 0.75
        } else if currentSegment == 1  && dao?.nonActiveStories.count == 0 {
            self.noStoriesImage.alpha = 0.75
        }
        else {
            self.noStoriesImage.alpha = 0
        }
    }
    
    func scheduledTimerWithTimeInterval() {
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }

    @objc func updateCounting() {
        guard let dao = dao else { return }
        dao.loadMyStories(requester: self)
    }

    @objc private func refreshData(_ sender: Any) {
        dao?.loadMyStories(requester: self)
        profileTableView.reloadData()
        let storiesCount = dao!.activeStories.count + dao!.nonActiveStories.count
         if storiesCount == 0 || storiesCount == 1{
             storiesAndChannelsLabel.text = "\(storiesCount) Relato"
         }else{

             storiesAndChannelsLabel.text = "\(storiesCount) Relatos"
         }
        self.refreshControl.endRefreshing()
        image()

    }

    // MARK: -  Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStory" {
            if let destinationVC = segue.destination as? StoryScreen{
                guard let selected = self.selectedIndex else {
                    return
                }
                if currentSegment == 0 {
                    destinationVC.selectedStory = dao?.activeStories[selected]
                } else {
                    destinationVC.selectedStory = dao?.nonActiveStories[selected]
                }

            }
        }
    }


}

// MARK: -  Extentions

// MARK: -  StoryManagerProtocol extentions
extension Profile:  StoryManagerProtocol {
    
    func readedStories(stories: [CKRecord]?, error: Error?) {
        
    }
    
    func readedMyStories(stories: [[CKRecord]]) {
        DispatchQueue.main.async {
            self.profileTableView.reloadData()
            self.activityView.stopAnimating()
            self.image()
            let storiesCount = self.dao!.activeStories.count + self.dao!.nonActiveStories.count
            if storiesCount == 0 || storiesCount == 1 {
                self.storiesAndChannelsLabel.text = "\(storiesCount) Relato"
            } else {
                
                self.storiesAndChannelsLabel.text = "\(storiesCount) Relatos"
            }
        }
    }

    func saved(reportRecord: CKRecord?, reportError: Error?) {

    }
}

// MARK: -  UITableViewDataSource and  UITableViewDelegate extentions
extension Profile: UITableViewDataSource, UITableViewDelegate {
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           self.selectedIndex = indexPath.row
           performSegue(withIdentifier: "showStory", sender: nil)
       }

       //table view setting
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           if currentSegment == 0 {
               return dao?.activeStories.count ?? 0
           } else {
               return dao?.nonActiveStories.count ?? 0
           }

       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTableViewCell
    
           var story : CKRecord
           guard let dao = dao else {
               return profileCell
           }
           if currentSegment == 0 {
               story = dao.activeStories[indexPath.row]
           } else {
               story = dao.nonActiveStories[indexPath.row]
           }
           profileCell.profileCellTextField.text = story["content"] as? String ?? ""
           profileCell.isUserInteractionEnabled = true
           
           if profileCell.profileCellTextField.text.count >= 149{
               
               profileCell.dots.isHidden = false
           }else{
               profileCell.dots.isHidden = true
           }
           
           return profileCell
       }

       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 151.0
       }
    
    
}

// MARK: -  UserRequester extentions
extension Profile: UserRequester {
    // pra editar
    func saved(userRecord: CKRecord?, userError: Error?) {
        if userRecord != nil {
            print("user novo salvou")
            do{
                try meUser.save()
                print("salvouuuuuuuuuuuuu")
            } catch {
                let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("erro ao salvar local nova conta")
            }
        }
    }

    func retrieved(user: User?, userError: Error?) {}

    func retrieved(userArray: [User]?, userError: Error?) {}

    func retrieved(meUser: MeUser?, meUserError: Error?) {}

    func retrieved(user: User?, fromIndex: Int, userError: Error?) {}
}
