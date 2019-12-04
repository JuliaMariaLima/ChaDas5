//
//  ChatBotViewController.swift
//  ChaDas5
//
//  Created by Julia Rocha on 27/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit
import ApiAI
import MessageKit
import InputBarAccessoryView

// MARK: -  Declaration
class ChatBotViewController: MessagesViewController, AnalysisLogProtocol {
    

    let doneView = UIView()
    var doneLabel = UILabel()
    var doneButton = UIButton()
    
    var answer1 = UIButton()
    var answer2 = UIButton()
    var answer3 = UIButton()
    var answer4 = UIButton()
    
    var labelBefore = UILabel()
    
    var userAnswers = [0, 0, 0]
    var indexTrack = 0
    
    // MARK: -  Outlets
    @IBOutlet weak var insertText: UITextField!
    var consersationData:[Message] = []
    let endOfConversationTriggerA = "É, eu acho bem difícil saber o que se passa na cabeça das pessoas… Nossa, não consigo nem terminar de contar a história! Enfim, ele só cortou a conversa e começou a tentar me agarrar, me senti 100% constrangida… Minha sorte foi uma amiga que queria ir embora e chegou bem na hora me chamando pra ir com ela. Senti bastante medo dele, não sei o que teria acontecido se ela não tivesse aparecido."
    let endOfConversationTriggerB = "Realmente queria conseguir saber o que se passa na cabeça das pessoas… Nossa, não consigo nem terminar de contar a história! Enfim, ele só cortou a conversa e começou a tentar me agarrar, me senti 100% constrangida… Minha sorte foi uma amiga que queria ir embora e chegou bem na hora me chamando pra ir com ela. Senti bastante medo dele, não sei o que teria acontecido se ela não tivesse aparecido."
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        debugPrint("error initializing chatbot")
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  View Configurations
    override func viewDidLoad() {
        super.viewDidLoad()
   
        doneView.frame.size = CGSize(width: 100, height: 200)
        doneView.backgroundColor = .middleOrange
        doneView.layer.cornerRadius = 20
        doneView.layer.shadowOffset = CGSize(width: 0, height: 0)
        doneView.layer.shadowColor = UIColor.black.cgColor
        doneView.layer.shadowOpacity = 0.23
        doneView.layer.shadowRadius = 4
        
        doneButton = UIButton(frame: CGRect(x: 30, y: 45, width: 254, height: 71))
        doneButton.layer.cornerRadius = 10
        doneButton.backgroundColor = .buttonOrange
        doneButton.setTitle("Vamos lá!", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        //answer1.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        doneButton.contentMode = .center
        
        doneLabel.textColor = .black
        doneLabel.text = "Você chegou ao fim do tutorial. Seja bem-vinda ao Chá das 5! Esperamos que faça a diferença para você."
        doneLabel.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        doneLabel.textAlignment = .center
        doneLabel.numberOfLines = 5
        
        labelBefore.textColor = .black
        labelBefore.text = "Pergunte mais sobre o relato e compartilhe suas experiências."
        labelBefore.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        labelBefore.textAlignment = .center
        labelBefore.numberOfLines = 3
        
        view.addSubview(labelBefore)
        doneView.addSubview(doneLabel)
        doneView.addSubview(doneButton)
        view.addSubview(doneView)
        
        doneView.isHidden = true
        
        configureAnswersButtons()
        
        messageInputBar.isHidden = true
    
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        
        let myCollection = messagesCollectionView as UICollectionView
        
        myCollection.translatesAutoresizingMaskIntoConstraints = false
        labelBefore.translatesAutoresizingMaskIntoConstraints = false
        doneView.translatesAutoresizingMaskIntoConstraints = false
        doneLabel.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        NSLayoutConstraint.activate([
            myCollection.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            myCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
            myCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            myCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            labelBefore.topAnchor.constraint(equalTo: myCollection.topAnchor, constant: 200),
            labelBefore.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelBefore.widthAnchor.constraint(equalToConstant: 305),
            labelBefore.heightAnchor.constraint(equalToConstant: 100),
            
            doneView.topAnchor.constraint(equalTo: view.topAnchor, constant: 500),
            doneView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneView.widthAnchor.constraint(equalToConstant: 300),
            doneView.heightAnchor.constraint(equalToConstant: 250),
            
            doneLabel.topAnchor.constraint(equalTo: doneView.topAnchor, constant: 20),
            doneLabel.centerXAnchor.constraint(equalTo: doneView.centerXAnchor),
            doneLabel.widthAnchor.constraint(equalToConstant: 250),
            doneLabel.heightAnchor.constraint(equalToConstant: 100),
            
            doneButton.topAnchor.constraint(equalTo: doneView.topAnchor, constant: 160),
            doneButton.centerXAnchor.constraint(equalTo: doneView.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 150),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
            
            
        ])
        
        configureNavigationBar()
        configureInputBar()
        view.bringSubviewToFront(labelBefore)
        view.bringSubviewToFront(doneView)
    }
    
    
    
    func configureAnswersButtons(){
        
        answer1 = UIButton(frame: CGRect(x: 30, y: 45, width: 254, height: 71))
        answer1.layer.cornerRadius = 10
        answer1.backgroundColor = .buttonOrange
        answer1.setTitle("Resposta 1", for: .normal)
        answer1.setTitleColor(.black, for: .normal)
        answer1.titleLabel?.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        //answer1.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        answer1.contentMode = .center
        
        answer2 = UIButton(frame: CGRect(x: 30, y: 45, width: 254, height: 71))
        answer2.layer.cornerRadius = 10
        answer2.backgroundColor = .buttonOrange
        answer2.setTitle("Resposta 2", for: .normal)
        answer2.setTitleColor(.black, for: .normal)
        answer2.titleLabel?.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        //answer1.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        answer2.contentMode = .center
        
        answer3 = UIButton(frame: CGRect(x: 30, y: 45, width: 254, height: 71))
        answer3.layer.cornerRadius = 10
        answer3.backgroundColor = .buttonOrange
        answer3.setTitle("Resposta 3", for: .normal)
        answer3.setTitleColor(.black, for: .normal)
        answer3.titleLabel?.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        //answer1.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        answer3.contentMode = .center
        
        answer4 = UIButton(frame: CGRect(x: 30, y: 45, width: 254, height: 71))
        answer4.layer.cornerRadius = 10
        answer4.backgroundColor = .buttonOrange
        answer4.setTitle("Resposta 4", for: .normal)
        answer4.setTitleColor(.black, for: .normal)
        answer4.titleLabel?.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        //answer1.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        answer3.contentMode = .center
        
        self.view.addSubview(answer1)
        self.view.addSubview(answer2)
        self.view.addSubview(answer3)
        self.view.addSubview(answer4)
        
        answer1.translatesAutoresizingMaskIntoConstraints = false
        answer2.translatesAutoresizingMaskIntoConstraints = false
        answer3.translatesAutoresizingMaskIntoConstraints = false
        answer4.translatesAutoresizingMaskIntoConstraints = false
 
        //constraints
        NSLayoutConstraint.activate([
            answer1.topAnchor.constraint(equalTo: view.topAnchor, constant: 600),
            answer1.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            answer1.widthAnchor.constraint(equalToConstant: 150),
            answer1.heightAnchor.constraint(equalToConstant: 60),
            
            answer2.topAnchor.constraint(equalTo: view.topAnchor, constant: 600),
            answer2.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80),
            answer2.widthAnchor.constraint(equalToConstant: 150),
            answer2.heightAnchor.constraint(equalToConstant: 60),
            
            answer3.topAnchor.constraint(equalTo: view.topAnchor, constant: 688),
            answer3.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            answer3.widthAnchor.constraint(equalToConstant: 150),
            answer3.heightAnchor.constraint(equalToConstant: 60),
            
            answer4.topAnchor.constraint(equalTo: view.topAnchor, constant: 688),
            answer4.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80),
            answer4.widthAnchor.constraint(equalToConstant: 150),
            answer4.heightAnchor.constraint(equalToConstant: 60)
            
        ])

        
    }
    
    
    
    
    
    
    // MARK: -  Actions
    @IBAction func sendForAPI(_ sender: Any) {
        talkToBot(with: insertText.text ?? "")
    }
    
    
    func talkToBot(with text:String) {
        save(text)
        self.saveInAnalysisLog()
        let request = ApiAI.shared().textRequest()
        if text != "" {
            request?.query = text
        } else { return }
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            
            // check
            if let textResponse = response.result.fulfillment.messages.first {
                guard let messageTextFromBot = textResponse["speech"] as? String else { return }
                print(messageTextFromBot)
            
                if messageTextFromBot == self.endOfConversationTriggerA || messageTextFromBot == self.endOfConversationTriggerB {
                    // end bot
//                    self.consersationData.append(Message(content: messageTextFromBot, on: "chatbot"))
//                    self.customReloadData()
//                    debugPrint("end of bot")
//                    debugPrint(self.userAnswers)
//                    self.saveInAnalysisLog()
                    
                } else {
//                    self.consersationData.append(Message(content: messageTextFromBot, on: "chatbot"))
//
//                    // correspond answers
//                    self.indexTrack += 1
//                    self.correspondAnswers(with: text, index: self.indexTrack - 1)
//                    self.customReloadData()
                }
            }
        }, failure: { (request, error) in
            print(error!)
        })
        ApiAI.shared().enqueue(request)
        // esvaziar caixa de resposta
        //        insertText.text = ""
    }
    
    private func insertNewMessage(_ message: Message) {
        let isLatestMessage = self.consersationData.firstIndex(of: message) == (consersationData.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.customReloadData()
            }
        }
    }
    
    
    // MARK: -  Database Helpers
    private func save(_ message: String) {
        //        let channelID = self.channelRecord.recordID.recordName
        let messageRep = Message(content: message, on: "")
        self.consersationData.append(messageRep)
        self.customReloadData()
    }
    
    func correspondAnswers(with text:String, index: Int) {
        debugPrint(text, index)
        if text == "Nossa, totalmente, sempre percebo isso." || text == "Sempre, sou quase a confidente de todo mundo." || text == "Nunca consigo, também acho difícil isso…" {
            debugPrint("saving answer: 4")
            userAnswers[index] = 4
        } else if text == "Até que noto, sim, mas não sempre." || text == "Olha, até acontece mas não é frequente." || text == "É bem raro eu conseguir." {
            debugPrint("saving answer: 3")
            userAnswers[index] = 3
        } else if text == "Quase nunca percebo." || text == "Quase nunca acontece comigo." || text == "Consigo, mas não é sempre." {
            debugPrint("saving answer: 2")
            userAnswers[index] = 2
        } else if text == "Não mesmo, acho muito difícil." || text == "Não, não consigo conversar com eles assim." || text == "Não acho difícil, sempre consigo entender." {
            debugPrint("saving answer: 1")
            userAnswers[index] = 1
        } else if index > 2 {
            debugPrint("saiu")
//            saveInAnalysisLog()
        }
        
    }
    
    func saveInAnalysisLog() {
        debugPrint("saving...")
        let dao = DAOManager.instance?.ckAnalysisLog
        dao?.retrieveAnalysisLog(with: self)
    }
    
    
    func createdAnalysisLog() {
        
    }
    
    func retrievedAnalysisLog(with analysisLog: AnalysisLog) {
        let currentAnswers = analysisLog.empathyAnswers
        let new = currentAnswers + userAnswers
        DAOManager.instance?.ckAnalysisLog.updateEmpathyAnswers(new: new, on: analysisLog.asCKRecord, with: self, hasCompletion: true)
        DAOManager.instance?.ckAnalysisLog.calculateEmpathy(on: analysisLog.asCKRecord, with: self)
    }
    
    func updatedAnalysisLog() {
        debugPrint("saved")
    }
    
    func createdAnalysisLog(with error: Error) {
        
    }
    
    func retrievedAnalysisLog(with error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    func updatedAnalysisLog(with error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    
}
// MARK: -  Extensions

// MARK: -  MessagesProtocol extension
extension ChatBotViewController: MessagesDisplayDelegate {
    
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

// MARK: - MessagesLayoutDelegate extension
extension ChatBotViewController: MessagesLayoutDelegate {
    
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
        return CGSize(width: self.view.bounds.width, height: 170)
    }
    
    
}

// MARK: - MessagesDataSource extension
extension ChatBotViewController: MessagesDataSource {
    
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.consersationData.count
    }
    
    
    func currentSender() -> SenderType {
        return Sender(id: "" , displayName: "")
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.consersationData.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.consersationData[indexPath.row]
    }
    
    
    func customReloadData() {
        // FIXME: - Scroll to bottom not working
        messagesCollectionView.reloadDataAndKeepOffset()
        let view = messagesCollectionView as UICollectionView
        let lastSection = view.numberOfSections - 1
        let lastRow = view.numberOfItems(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        view.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
        
    }
    
}

// MARK: -  self layout extension
extension ChatBotViewController: InputBarAccessoryViewDelegate {
    
    
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
        //        dismissButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        dismissButton.contentMode = .center
        dismissButton.imageView?.contentMode = .scaleAspectFit
        dismissButton.isEnabled = false
        
        
        self.view.addSubview(dismissButton)
        let complainButtonImg = UIImage(named: "blockIcon")
        let complainButton = UIButton(frame: CGRect(x: 375 - dismissButton.frame.maxX, y: 45, width: 40, height: 40))
        complainButton.setImage(complainButtonImg , for: .normal)
        //        complainButton.addTarget(self, action: #selector(complainAction), for: .touchUpInside)
        complainButton.contentMode = .center
        complainButton.imageView?.contentMode = .scaleAspectFit
        complainButton.isEnabled = true
        complainButton.isEnabled = false
        
        self.view.addSubview(complainButton)
        
        let backgroudCircle = UIImageView(frame: CGRect(x: 45, y:45, width: 45, height: 45))
        backgroudCircle.image = UIImage(named: "backgroundCircle")
        backgroudCircle.contentMode = .scaleAspectFill
        self.view.addSubview(backgroudCircle)
        
        
        let teaButton = UIButton(frame: CGRect(x: 30, y: 45, width: 45, height: 35))
        //        teaButton.addTarget(self, action: #selector(teaAction), for: .touchUpInside)
        let teaName = UILabel(frame: CGRect(x: 45, y:45, width: 45, height: 45))
        teaName.contentMode = .scaleAspectFill
        teaName.textAlignment = .center
        teaName.center.y = backgroudCircle.center.y
        teaName.font = UIFont(name: "SFCompactDisplay-Regular", size: 17)
        
        self.view.addSubview(teaName)
        let photo = UIImage.init(named: "Camomila")
        teaName.text = "Camomila"
        teaButton.setImage(photo , for: .normal)
        teaButton.isEnabled = false
        
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
            backgroudCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            backgroudCircle.widthAnchor.constraint(equalToConstant: 80),
            backgroudCircle.heightAnchor.constraint(equalToConstant: 80),
            
            teaButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 47),
            teaButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            teaButton.widthAnchor.constraint(equalToConstant: 70),
            teaButton.heightAnchor.constraint(equalToConstant: 70),
            
            teaName.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            teaName.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            teaName.widthAnchor.constraint(equalToConstant: 300),
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
        messageInputBar.inputTextView.font = UIFont.systemFont(ofSize: 18)
        messageInputBar.setLeftStackViewWidthConstant(to: 10, animated: false)
        
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        talkToBot(with: text)
        inputBar.inputTextView.text = ""
    }
}
