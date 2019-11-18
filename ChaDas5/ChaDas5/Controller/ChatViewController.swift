

import UIKit
import CloudKit
import MessageKit
import InputBarAccessoryView



class ChatViewController: MessagesViewController, UINavigationBarDelegate, MessagesProtocol {

    
    func messageSaved(with error: Error) {
        debugPrint("deu erro porra", error)
    }
    
    func messageSaved() {
        // mudar status da msg
        debugPrint("salvou bunitin")
    }
    
    
    func deleted() {
        
    }
    
    func deletedError(with: Error) {
        
    }
    

    var chatUserRequester: UserRequester!
    var activityView: UIActivityIndicatorView!
    private let channel: Channel?
    var channelRecord: CKRecord
    
    let dao = DAOManager.instance?.ckMessages
    var daoRef: Int?

    init(channel: CKRecord) {
        self.channelRecord = channel
        self.channel = Channel(from: channel, completion: { (channel, error) in
            if error != nil {
                debugPrint(#function, error)
            }
        })
        super.init(nibName: nil, bundle: nil)
        checkSubscription()
    }
    
    func checkSubscription() {
        let channelID = self.channelRecord.recordID.recordName
        DaoPushNotifications.instance.retrieveSubscription(on: channelID) { (exists) in
            if exists == nil {
                debugPrint("error getting subscription")
                return
            }
            if exists! == false {
                let predicate = NSPredicate(format: "onChannel = %@", channelID)
                DaoPushNotifications.instance.createSubscription(recordType: "Thread", predicate: predicate, option: CKQuerySubscription.Options.firesOnRecordCreation, on: channelID)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        debugPrint("error initializing chat")
        fatalError("init(coder:) has not been implemented")
    }

    static var lcount = 0
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let dao = dao else { return }
 
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        maintainPositionOnKeyboardFrameChanged = true
        configureNavigationBar()
        configureInputBar()
        configureActivityView()
        
        let myCollection = messagesCollectionView as UICollectionView
        myCollection.translatesAutoresizingMaskIntoConstraints = false
        //constraints
         NSLayoutConstraint.activate([
             myCollection.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
             myCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
             myCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
             myCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90)

             ])
        customReloadData()
        guard let currentChannel = self.channel else { return }
        dao.loadMessages(from: currentChannel, requester: self)
    }
    
    
//    @objc func teaAction(sender: UIButton!) {
//        let page = StoryScreen()
//        let user = channelRecord["fromStory"] as! String
//        page.selectedStory = channelRecord.
//        page.chatButton.isHidden = true
//        present(page, animated: true, completion: nil)
//
//    }

    
    @objc func buttonAction(sender: UIButton!) {
        DAOManager.instance?.ckChannels.updateOpenedBy(with: Date(), on: self.channelRecord.recordID.recordName)
        self.dismiss(animated: false, completion: nil)
    }


    @objc func complainAction(sender: UIButton!) {
        
        let alert = UIAlertController(title: "Deseja mesmo bloquear esse usuário?", message: "Vocês não verão postagens um do outro mais! Esse usuário também será mandado para análise.", preferredStyle: .alert)
        let bloquear = UIAlertAction(title: "Bloquear Usuário", style: .default, handler: { (action) -> Void in
            
        
            
            let channelID = self.channelRecord.recordID
            guard let channel = self.channel else { return }
            
            if MeUser.instance.email == channel.ownerID {
                DAOManager.instance?.ckUsers.block(channel.fromStory, requester: self)
                DAOManager.instance?.ckUsers.blockAnother(channel.fromStory, requester: self)
            }else{
                DAOManager.instance?.ckUsers.block(channel.ownerID, requester: self)
                DAOManager.instance?.ckUsers.blockAnother(channel.ownerID, requester: self)
            }
            
            self.dismiss(animated: false)
            
            DAOManager.instance?.ckChannels.deleteChannel(channelID: channelID, completion: { (completed) in
                if completed {
                   
                }
            })
            
        })
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel ) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(bloquear)
        alert.addAction(cancelar)
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonOrange
    }


  // MARK: -  Database Helpers

    private func save(_ message: String) {
        let channelID = self.channelRecord.recordID.recordName
        let messageRep = Message(content: message, on: channelID)
        dao?.save(message: messageRep, to: self)
        self.customReloadData()
    }

    private func insertNewMessage(_ message: Message) {
        
        guard let messages = dao?.messages else {
            return
        }
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.customReloadData()
            }
        }
    }
    
    
    func readedMessagesFromChannel(messages: [Message]?, error: Error?) {
        if messages != nil {
            DispatchQueue.main.async {
                self.customReloadData()
                self.activityView.stopAnimating()
            }
        }
        DispatchQueue.main.async {
            self.activityView.stopAnimating()
        }
    }
    
    
    // MARK: - Configure self layout
    
    func configureActivityView() {
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
    }
    
    func configureNavigationBar() {
        let bar = CustomNavigationBar()
        bar.frame = CGRect(x: 0.5, y: 0.5, width: 375, height: 100)
        bar.barTintColor = UIColor.middleOrange
        bar.isTranslucent = true
//        let navbarFont = UIFont(name: "SFCompactDisplay-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        self.view.addSubview(bar)
        configureButtons()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor),
            bar.leftAnchor.constraint(equalTo: view.leftAnchor),
            bar.rightAnchor.constraint(equalTo: view.rightAnchor)
            
            ])
        
    }
    
    

    
    func configureButtons() {
        let img = UIImage(named: "dismissIcon")
        let dismissButton = UIButton(frame: CGRect(x: 30, y: 45, width: 40, height: 40))
        dismissButton.setImage(img , for: .normal)
        dismissButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        dismissButton.contentMode = .center
        dismissButton.imageView?.contentMode = .scaleAspectFit
        
        
        self.view.addSubview(dismissButton)
        let complainButtonImg = UIImage(named: "blockIcon")
        let complainButton = UIButton(frame: CGRect(x: 375 - dismissButton.frame.maxX, y: 45, width: 40, height: 40))
        complainButton.setImage(complainButtonImg , for: .normal)
        complainButton.addTarget(self, action: #selector(complainAction), for: .touchUpInside)
        complainButton.contentMode = .center
        complainButton.imageView?.contentMode = .scaleAspectFit
        complainButton.isEnabled = true
        self.view.addSubview(complainButton)
        
        let backgroudCircle = UIImageView(frame: CGRect(x: 45, y:45, width: 45, height: 45))
        backgroudCircle.image = UIImage(named: "backgroundCircle")
        backgroudCircle.contentMode = .scaleAspectFill
        self.view.addSubview(backgroudCircle)
        
        
        let teaButton = UIButton(frame: CGRect(x: 30, y: 45, width: 45, height: 35))
        let teaName = UILabel(frame: CGRect(x: 45, y:45, width: 45, height: 45))
        teaName.contentMode = .center
        teaName.textAlignment = .center
        teaName.center.y = backgroudCircle.center.y
        teaName.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        
        self.view.addSubview(teaName)
        
        
        var username = ""

        if MeUser.instance.email == channel?.ownerID {
            // username vem da story
            let user = channelRecord["fromStory"] as! String
            DAOManager.instance?.ckUsers.retrieve(nameFrom: user, completion: { (retrievedUsername, error) in
                if error == nil && retrievedUsername != nil {
                    username = retrievedUsername!
                    DispatchQueue.main.async {
                        let photo = UIImage.init(named: username)
                        teaName.text = username
                        teaButton.setImage(photo , for: .normal)
                    }
                }
            })
        } else {
           // username vem do ownerID
      
            DAOManager.instance?.ckUsers.retrieve(nameFrom: channel!.ownerID, completion: { (retrievedUsername, error) in
               if error == nil && retrievedUsername != nil {
                   username = retrievedUsername!
                   DispatchQueue.main.async {
                       let photo = UIImage.init(named: username)
                       teaName.text = username
                       teaButton.setImage(photo , for: .normal)
                   }
               }
           })
       }
        
        
       // teaButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        teaButton.contentMode = .center
        teaButton.imageView?.contentMode = .scaleAspectFit
        self.view.addSubview(teaButton)

        
       
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        complainButton.translatesAutoresizingMaskIntoConstraints = false
        backgroudCircle.translatesAutoresizingMaskIntoConstraints = false
        teaButton.translatesAutoresizingMaskIntoConstraints = false
        teaName.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -150),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            
            complainButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            complainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 150),
            complainButton.widthAnchor.constraint(equalToConstant: 40),
            complainButton.heightAnchor.constraint(equalToConstant: 40),
            
            backgroudCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            backgroudCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 12),
            backgroudCircle.widthAnchor.constraint(equalToConstant: 80),
            backgroudCircle.heightAnchor.constraint(equalToConstant: 80),
            
            teaButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 47),
            teaButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 14),
            teaButton.widthAnchor.constraint(equalToConstant: 70),
            teaButton.heightAnchor.constraint(equalToConstant: 70),
            
            teaName.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            teaName.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 12),
            teaName.widthAnchor.constraint(equalToConstant: 100),
            teaName.heightAnchor.constraint(equalToConstant: 30)
            ])
    
    }
    
    func configureInputBar() {
        messageInputBar.inputTextView.tintColor = UIColor.middleOrange
        messageInputBar.sendButton.setTitleColor(UIColor.buttonOrange, for: .normal)
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.image = UIImage(named: "sendIcon")
        messageInputBar.sendButton.contentMode = .scaleAspectFill
        messageInputBar.delegate = self
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.sendButton.title = "Enviar"
        messageInputBar.backgroundView.backgroundColor = UIColor.middleOrange
      //  messageInputBar.backgroundView.frame = CGRect(x: 50, y: 50, width: view.frame.width, height: 10)
        messageInputBar.isTranslucent = true
        messageInputBar.inputTextView.placeholderLabel.text = "Nova mensagem"
        messageInputBar.inputTextView.placeholderLabel.font = UIFont(name: "SFCompactDisplay-Regular", size: 18)
        messageInputBar.inputTextView.placeholderLabel.textColor = UIColor.gray
        messageInputBar.inputTextView.backgroundColor = UIColor.white
        messageInputBar.inputTextView.layer.cornerRadius = 15
        messageInputBar.inputTextView.font = UIFont(name: "SFCompactDisplay-Regular", size: 18)
        messageInputBar.setLeftStackViewWidthConstant(to: 10, animated: false)

    
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.middleOrange : UIColor.lightGray.withAlphaComponent(0.25)
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return true
    }
    
    func messageStyle(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.removeFromSuperview()
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {

    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func footerViewSize(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }

    func textColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.black : UIColor.black
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 120)
    }


}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }

    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        guard let dao = dao else {
            fatalError()
        }
        return dao.messages.count
    }


    func currentSender() -> SenderType {
        return Sender(id: MeUser.instance.email , displayName: MeUser.instance.name)
    }

    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        guard let dao = dao else {
            fatalError()
        }
        return dao.messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let dao = dao else {
            fatalError()
        }
        return dao.messages[indexPath.row]
    }
    
    
    func customReloadData() {
        // FIXME: - Scroll to bottom not working
        messagesCollectionView.reloadData()
        let view = messagesCollectionView as UICollectionView
        
        let lastSection = view.numberOfSections - 1
        let lastRow = view.numberOfItems(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        view.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)

    }

}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        save(text)
        inputBar.inputTextView.text = ""
    }
    
}
extension ChatViewController: UserRequester {
    func saved(userRecord: CKRecord?, userError: Error?) {}
    
    func retrieved(user: User?, userError: Error?) {}
    
    func retrieved(userArray: [User]?, userError: Error?) {}
    
    func retrieved(meUser: MeUser?, meUserError: Error?) {}
    
    func retrieved(user: User?, fromIndex: Int, userError: Error?) {}
     
}



