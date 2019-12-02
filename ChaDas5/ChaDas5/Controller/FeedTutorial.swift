//
//  Tutorial.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 22/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//
//

import UIKit


class FeedTutorial: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {


    var activityView:UIActivityIndicatorView!
    var xibCell:FeedTableViewCell?
    var selectedIndex:Int?
    let content = "Teste"
    private let refreshControl = UIRefreshControl()

    //outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var feedTableView: UITableView!

    @IBOutlet weak var arrow: UIImageView!
    
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!

    
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
        

        
 
        if #available(iOS 13.0, *) {
            activityView = UIActivityIndicatorView(style: .medium)
        } else {
            activityView = UIActivityIndicatorView(style: .gray)
        }
        activityView.color = UIColor.buttonOrange
        activityView.frame = CGRect(x: 0, y: 0, width: 300.0, height: 300.0)
        activityView.center = view.center
        activityView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
      
       searchLabel.layer.cornerRadius = 20
       searchLabel.clipsToBounds = true
        
        view.addSubview(activityView)
        
        activityView.startAnimating()

        feedTableView.reloadData()
        
        hideKeyboardWhenTappedAround()
        
        pulsate()
    
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        pulsate()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.activityView.stopAnimating()
        
        let feedCell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedTableViewCell
        
        
        feedCell.feedTableViewTextField.text = content
        feedCell.sensitiveView.isHidden = true
        
        if feedCell.feedTableViewTextField.text.count >= 149{
            
            feedCell.dots.isHidden = false
        }else{
            feedCell.dots.isHidden = true
        }
        
        feedCell.selectionStyle = .none
        return feedCell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
        if selectedCell.sensitiveView.isHidden == true{
            selectedCell.contentView.backgroundColor = UIColor.clear
            self.selectedIndex = 1
            goTo(identifier: "storyScreen")
        }
        else{}

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell
        selectedCell?.contentView.backgroundColor = UIColor.white
        
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 151.0

    }
    
  
    public func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 10
        pulse.fromValue = 0.985
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 200
        pulse.initialVelocity = 0.5
        pulse.damping = 0.2
        feedTableView.layer.add(pulse, forKey: "pulseAnimation")
    }


    func goTo(identifier: String) {
          DispatchQueue.main.async {
              self.performSegue(withIdentifier: identifier, sender: self)
          }
      }
    
    @objc private func refreshData(_ sender: Any) {
    
        self.refreshControl.endRefreshing()

    }

    
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
}
