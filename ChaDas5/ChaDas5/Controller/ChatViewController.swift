

import UIKit
import CloudKit
import MessageKit
import InputBarAccessoryView



class ChatViewController: MessagesViewController, UINavigationBarDelegate, MessagesProtocol {
    


    var activityView: UIActivityIndicatorView!
//    private let user: User
    private let channel: Channel
    
    let dao = DAOManager.instance?.ckMessages

    init(channel: Channel) {
//        self.user = nil
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static var lcount = 0
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()


        guard channel.id != nil else {
            self.dismiss(animated: true)
            return
        }
        guard let dao = dao else { return }

        dao.messages = []
        dao.loadMessages(from: self.channel, requester: self)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        updateCollectionContentInset()
        scrollToBottom()
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        configureNavigationBar()
        configureInputBar()
        configureActivityView()
  }

    @objc func buttonAction(sender: UIButton!) {
        self.dismiss(animated: false, completion: nil)
    }
    

    
    @objc func complainAction(sender: UIButton!) {
        
        let alert = UIAlertController(title: "Deseja mesmo bloquear esse usuário?", message: "Vocês não verão postagens um do outro mais! Esse usuário também será mandado para análise.", preferredStyle: .alert)
//        let bloquear = UIAlertAction(title: "Bloquear Usuário", style: .default, handler: { (action) -> Void in
//            var firstUser: String?
//            var secondUser: String?
//            guard let id = self.channel.id else { return }
//            self.dismiss(animated: true)
//        })
        let cancelar = UIAlertAction(title: "Cancelar", style: .default ) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
//        alert.addAction(bloquear)
        alert.addAction(cancelar)
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonOrange
    }


  // MARK: - Helpers

    private func save(_ message: String) {
        guard let channelID = self.channel.id else {
            return
        }
        let messageRep = Message(content: message, on: channelID)
        dao?.save(message: messageRep, completion: { (record, error) in
            if record != nil {
                self.insertNewMessage(messageRep)
            }
            if error != nil {
                debugPrint(error.debugDescription, #function)
            }
        })
  }

    private func insertNewMessage(_ message: Message) {
        
        guard let messages = dao?.messages else {
            return
        }
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.updateCollectionContentInset()
                self.scrollToBottom()
            }
        }
        dao?.loadMessages(from: channel, requester: self)
    }
    
    
    func readedMessagesFromChannel(messages: [Message]?, error: Error?) {
        if messages != nil {
            DispatchQueue.main.sync {
                self.messagesCollectionView.reloadData()
                activityView.stopAnimating()
                updateCollectionContentInset()
                scrollToBottom()
            }
        }
    }
    
    
    // MARK: - Configure self layout
    
    func configureActivityView() {
        activityView = UIActivityIndicatorView(style: .medium)
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
//        let navbarFont = UIFont(name: "SFCompactDisplay-Ultralight", size: 17) ?? UIFont.systemFont(ofSize: 17)
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
        let dismissButton = UIButton(frame: CGRect(x: 30, y: 45, width: 45, height: 35))
        dismissButton.setImage(img , for: .normal)
        dismissButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        dismissButton.contentMode = .center
        dismissButton.imageView?.contentMode = .scaleAspectFit
        
        
        self.view.addSubview(dismissButton)
        let complainButtonImg = UIImage(named: "complainIcon")
        let complainButton = UIButton(frame: CGRect(x: 375 - dismissButton.frame.maxX, y: 45, width: 65, height: 55))
        complainButton.setImage(complainButtonImg , for: .normal)
        complainButton.addTarget(self, action: #selector(complainAction), for: .touchUpInside)
        complainButton.contentMode = .center
        complainButton.imageView?.contentMode = .scaleAspectFit
        
        self.view.addSubview(complainButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        complainButton.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -112.5),
            dismissButton.widthAnchor.constraint(equalToConstant: 65),
            dismissButton.heightAnchor.constraint(equalToConstant: 55),
            
            complainButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            complainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 112.5),
            complainButton.widthAnchor.constraint(equalToConstant: 65),
            complainButton.heightAnchor.constraint(equalToConstant: 55)
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
        messageInputBar.isTranslucent = true
        messageInputBar.inputTextView.placeholderLabel.text = "Nova mensagem"
        messageInputBar.inputTextView.placeholderLabel.font = UIFont(name: "SFCompactDisplay-Ultralight", size: 18)
        messageInputBar.inputTextView.placeholderLabel.textColor = UIColor.gray
        messageInputBar.inputTextView.backgroundColor = UIColor.white
        messageInputBar.inputTextView.layer.cornerRadius = 15
        messageInputBar.inputTextView.font = UIFont(name: "SFCompactDisplay-Ultralight", size: 18)
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
    
    func updateCollectionContentInset() {
        let contentSize = messagesCollectionView.collectionViewLayout.collectionViewContentSize
        var contentInsetTop = messagesCollectionView.bounds.size.height

            contentInsetTop -= contentSize.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
        }
        messagesCollectionView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
    }
    
    func scrollToBottom() {
        guard let dao = dao else { return }
        guard !dao.messages.isEmpty else { return }

        let lastIndex = dao.messages.count - 1

        messagesCollectionView.scrollToItem(at: IndexPath(item: lastIndex, section: 0), at: .centeredVertically, animated: true)
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
        return Sender(id: "no_user_logged" , displayName: "no_user_logged")
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

}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        save(text)
        inputBar.inputTextView.text = ""
    }
    
}



