

import UIKit
import Firebase
import MessageKit
import FirebaseFirestore
import InputBarAccessoryView


class ChatViewController: MessagesViewController, MessagesProtocol, UINavigationBarDelegate {

    var activityView: UIActivityIndicatorView!
    private let user: User
    private let channel: Channel

    init(channel: Channel) {
        self.user = Auth.auth().currentUser!
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
    

        MessagesManager.instance.messages = []
        MessagesManager.instance.loadMessages(from: self.channel, requester: self)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.scrollToBottom()
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        configureNavigationBar()
        configureInputBar()
        configureActivityView()
  }

    func readedMessagesFromChannel(messages: [Message]) {
        self.messagesCollectionView.reloadData()
        activityView.stopAnimating()
        messagesCollectionView.scrollToBottom()
    }

    @objc func buttonAction(sender: UIButton!) {
        self.dismiss(animated: false, completion: nil)
    }
    

    
    @objc func complainAction(sender: UIButton!) {
        
        let alert = UIAlertController(title: "Deseja mesmo bloquear esse usuário?", message: "Vocês não verão postagens um do outro mais! Esse usuário também será mandado para análise.", preferredStyle: .alert)
        let bloquear = UIAlertAction(title: "Bloquear Usuário", style: .default, handler: { (action) -> Void in
            var firstUser: String?
            var secondUser: String?
            guard let id = self.channel.id else { return }
            let docRef = FBRef.channels.document(id)
            docRef.getDocument(source: .cache) { (document, error) in
                if let document = document {
                    firstUser = document.get("firstUser") as? String
                    secondUser  = document.get("secondUser") as? String
                    let firstUserRef = FBRef.users.document(firstUser!)
                    let secondUserRef = FBRef.users.document(secondUser!)
                    firstUserRef.collection("block").document(secondUser!).setData(["id" : secondUser!])
                    secondUserRef.collection("block").document(firstUser!).setData(["id" : firstUser!])
                    
                    if firstUser ==  UserManager.instance.currentUser {
                        FBRef.analise.document(secondUser!).setData(["id" : secondUser!])
                    } else {
                        FBRef.analise.document(firstUser!).setData(["id" : firstUser!])
                    }
                }
            }
            self.dismiss(animated: true)
        })
        let cancelar = UIAlertAction(title: "Cancelar", style: .default ) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(bloquear)
        alert.addAction(cancelar)
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonPink
    }
    
    


  // MARK: - Helpers

    private func save(_ message: String) {
        let messageRep = Message(content: message)
        self.channel.add(message: messageRep)
        self.messagesCollectionView.scrollToBottom()
        insertNewMessage(messageRep)
  }

    private func insertNewMessage(_ message: Message) {

        let isLatestMessage = MessagesManager.instance.messages.firstIndex(of: message) == (MessagesManager.instance.messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    // MARK: - Configure self layout
    
    func configureActivityView() {
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.color = UIColor.buttonPink
        activityView.frame = CGRect(x: 0, y: 0, width: 300.0, height: 300.0)
        activityView.center = view.center
        activityView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    func configureNavigationBar() {
        let bar = CustomNavigationBar()
        bar.frame = CGRect(x: 0.5, y: 0.5, width: 375, height: 100)
        bar.barTintColor = UIColor.basePink
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
        let dismissButton = UIButton(frame: CGRect(x: 30, y: 45, width: 65, height: 55))
        dismissButton.setImage(img , for: .normal)
        dismissButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        dismissButton.contentMode = .center
        self.view.addSubview(dismissButton)
        let complainButtonImg = UIImage(named: "complainIcon")
        let complainButton = UIButton(frame: CGRect(x: 375 - dismissButton.frame.maxX, y: 45, width: 65, height: 55))
        complainButton.setImage(complainButtonImg , for: .normal)
        complainButton.addTarget(self, action: #selector(complainAction), for: .touchUpInside)
        complainButton.contentMode = .center
        self.view.addSubview(complainButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        complainButton.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -112.5),
            dismissButton.widthAnchor.constraint(equalToConstant: 65),
            dismissButton.heightAnchor.constraint(equalToConstant: 55),
            
            complainButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            complainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 112.5),
            complainButton.widthAnchor.constraint(equalToConstant: 65),
            complainButton.heightAnchor.constraint(equalToConstant: 55)
            ])
    
    }
    
    func configureInputBar() {
        messageInputBar.inputTextView.tintColor = UIColor.basePink
        messageInputBar.sendButton.setTitleColor(UIColor.buttonPink, for: .normal)
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.image = UIImage(named: "sendIcon")
        messageInputBar.sendButton.contentMode = .scaleAspectFill
        messageInputBar.delegate = self
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.sendButton.title = "Enviar"
        messageInputBar.backgroundView.backgroundColor = UIColor.basePink
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
        return isFromCurrentSender(message: message) ? UIColor.basePink : UIColor.lightGray.withAlphaComponent(0.25)
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
        return MessagesManager.instance.messages.count
    }


    func currentSender() -> SenderType {
        return Sender(id: (UserManager.instance.currentUser) ?? "Error retrieving sender", displayName: AppSettings.displayName)
    }

    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return MessagesManager.instance.messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return MessagesManager.instance.messages[indexPath.row]
    }

}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        save(text)
        inputBar.inputTextView.text = ""
    }
    
}



