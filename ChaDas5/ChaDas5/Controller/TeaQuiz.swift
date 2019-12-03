//
//  TeaQuiz.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 27/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit

class TeaQuiz: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    var pickerView = UIPickerView()
    let toolBar = UIToolbar()
    let oldText = String()
    
    @IBOutlet weak var answerField: UITextField!
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var numberLabel: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    
    
    var teaName:String = "Default"
    var answers = ["---","Discordo fortemente","Discordo", "Concordo", "Concordo Fortemente"]
    var usersAnswers:[Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var currentQuestion = 18
    var finished = false
    
    @objc func answersLabelTarget1(textField: UITextField) {
        pickerView.isHidden = false
        pickerView.autoresizingMask = .flexibleWidth
        answerField.text = oldText
    }
    
    @objc func doneTapped(button: UIBarButtonItem) {
        answerField.endEditing(true)
        if answerField.text != "---" && answerField.text != nil{
            setNextButton(enabled: true)
        } else {
            setNextButton(enabled: false)
        }
        
    }
    
    
    @objc func cancelTapped(button: UIBarButtonItem) {
        setNextButton(enabled: false)
        answerField.endEditing(true)
        answerField.text = oldText
        
    }
    
    // - MARK: Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return answers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return answers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        answerField.text = answers[row]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        pickerView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        
        pickerView = UIPickerView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: 220.0)))
        view.addSubview(pickerView)
        pickerView.isHidden = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        answerField.addTarget(self, action: #selector(answersLabelTarget1), for: .allTouchEvents)
        answerField.allowsEditingTextAttributes = false
        
        questionField.text = getQuestionContent(on: currentQuestion)
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 59/255, green: 61/255, blue: 66/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelTapped))
        cancelButton.tintColor =  .buttonOrange
        doneButton.tintColor = .buttonOrange
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        answerField.inputView = pickerView
        answerField.inputAccessoryView = toolBar
        
        setNextButton(enabled: false)
        nextButton.setTitle("Próxima", for: .normal)
        
    }
    
    func calculate(){
        var sum = 0.0
        let invert = [3, 4, 5, 7]
        for value in invert {
            let answer = self.usersAnswers[value]
            switch answer {
            case 4:
                self.usersAnswers[value] = 1
            case 3:
                self.usersAnswers[value] = 2
            case 2:
                self.usersAnswers[value] = 3
            case 1:
                self.usersAnswers[value] = 4
            default:
                self.usersAnswers[value] = self.usersAnswers[value]
            }
        }
        for value in self.usersAnswers {
            sum += Double(value)
        }
        let result = sum/19
        
        if 0 < result && result < 1 {
            self.teaName = "Chá Preto"
        } else if 1 < result && result < 2 {
            self.teaName = "Capim Limão"
        } else if 2 < result && result < 3 {
            self.teaName = "Hibisco"
        } else if 3.1 < result && result < 3.4 {
            self.teaName = "Frutas Vermelhas"
        } else if 3.4 < result && result < 3.7 {
            self.teaName = "Erva Doce"
        } else {
            self.teaName = "Camomila"
        }
        performSegue(withIdentifier: "yourTea", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "yourTea" {
            debugPrint("go to Story")
            if let destinationVC = segue.destination as? YourTea {
                destinationVC.yourTeaName = self.teaName
            }
        }
        
    }
    
    
    // TODO: - Check if all answered
    @IBAction func nextButtonAction(_ sender: Any) {
        self.usersAnswers[currentQuestion - 1] = getAnswer(with: answerField.text ?? "")
        if finished {
            let analysisLog = AnalysisLog()
            analysisLog.empathyAnswers = self.usersAnswers
//            DAOManager.instance?.ckAnalysisLog.save(analysis: analysisLog, with: self)
            calculate()
        } else {
            print(currentQuestion)
            setNextButton(enabled: false)
            nextButton.setTitle("Próxima", for: .normal)
            handleQuestions()
            print(usersAnswers)
            print(currentQuestion)
        }
        
        
        
        
    }
    
    func handleQuestions() {
        
        currentQuestion += 1
        self.questionField.text = getQuestionContent(on: currentQuestion)
//        self.numberLabel = currentQuestion
        if currentQuestion == questions.count {
            nextButton.setTitle("Pronto", for: .normal)
            self.finished = true
        }
        answerField.endEditing(true)
        answerField.text = oldText
        print(currentQuestion)
        
    }
    
    
    
    
    func setNextButton(enabled:Bool) {
        if enabled {
            nextButton.alpha = 1.0
            nextButton.isEnabled = true
        } else {
            nextButton.alpha = 0.5
            nextButton.isEnabled = false
        }
    }
    
    func getQuestionContent(on index:Int) -> String {
        return questions[index - 1]
    }
    
    func getAnswer(with string:String) -> Int {
        switch string {
        case "Discordo fortemente":
            return 1
        case "Discordo":
            return 2
        case "Concordo":
            return 3
        case "Concordo fortemente":
            return 4
        default:
            return 0
        }
    }
    
    let questions = [
        "Eu consigo perceber facilmente se alguém está querendo entrar em uma conversa.",
        "Eu realmente gosto de cuidar de outras pessoas.",
        "Eu acho difícil saber o que fazer em uma situação/evento social.",
        "Frequentemente, eu tenho dificuldades em julgar se alguma coisa é grosseira ou educada.",
        "Em uma conversa, eu tendo a me focar em meus próprios pensamentos em vez de me focar no que a outra pessoa possa estar pensando.",
        "Eu consigo perceber rapidamente quando alguém fala uma coisa, mas quer dizer outra.",
        "Para mim, é difícil perceber porque algumas coisas incomodam tanto as pessoas.",
        "Eu tenho facilidade de me colocar no lugar dos outros.",
        "Eu sou bom em antecipar como as pessoas irão se sentir.",
        "Eu percebo rapidamente quando alguém em um grupo está se sentindo envergonhado ou desconfortável.",
        "Eu não costumo achar confusas as situações sociais.",
        "As pessoas me dizem que sou bom em entender como elas se sentem e o que elas estão pensando.",
        "Eu consigo perceber se estou incomodando, mesmo que a outra pessoa não me fale.",
        "Frequentemente, as pessoas me dizem que sou insensível, embora nem sempre eu saiba o porquê.",
        "Eu consigo me sintonizar, de modo rápido e intuitivo, com o que os outros sentem.",
        "Eu consigo me dar conta facilmente sobre o que uma pessoa possa estar querendo falar.",
        "Eu consigo dizer se alguém está disfarçando seus verdadeiros sentimentos.",
        "Eu sou bom em antecipar o que alguém irá fazer.",
        "Eu costumo me envolver emocionalmente com os problemas dos meus amigos."
    ]
}

extension TeaQuiz: AnalysisLogProtocol {
    
    func createdAnalysisLog() {
        debugPrint("created")
        
    }
    
    func retrievedAnalysisLog(with analysisLog: AnalysisLog) {
        
    }
    
    func updatedAnalysisLog() {
        
    }
    
    func createdAnalysisLog(with error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    func retrievedAnalysisLog(with error: Error) {
        
    }
    
    func updatedAnalysisLog(with error: Error) {
        
    }
    
}
