//
//  CustomSegmentedContrl.swift
//  CustomSEgmentedControl
//
//  Created by Leela Prasad on 18/01/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit

// MARK: -  Declaration
@IBDesignable
class CustomSegmentedContrl: UIControl {
    
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex = 0
    
    // MARK: -  View configurations
    @IBInspectable var borderWidth: CGFloat = 0 {
        
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    
    @IBInspectable var borderColor: UIColor = .clear {
        
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var commaSeperatedButtonTitles: String = "" {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var textColor: UIColor = .lightGray {
        
        didSet {
            updateView()
        }
    }
    
    
    @IBInspectable var selectorColor: UIColor = .buttonOrange {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var selectorTextColor: UIColor = .buttonOrange {
        
        didSet {
            updateView()
        }
    }
    
    // MARK: -  Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }
    
    
    convenience init(parent:UIView, verticalPosition:CGFloat = 25, segmentsCommaSeparated:String, action: Selector) {
        self.init(frame: CGRect.init(x: 0, y: verticalPosition, width: parent.frame.width, height: 45))
        self.backgroundColor = .clear
        self.commaSeperatedButtonTitles = segmentsCommaSeparated
        self.addTarget(self, action: action, for: .valueChanged)
        
        parent.addSubview(self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateView() {
        
        buttons.removeAll()
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        let buttonTitles = commaSeperatedButtonTitles.components(separatedBy: ",")
        for buttonTitle in buttonTitles {
            let button = UIButton.init(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
            //            button.setTitleColor(button.isSelected ? UIColor.gray : selectorTextColor, for: .normal)
        }
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        
        let y =    (self.frame.maxY - self.frame.minY) - 3.0
        
        selector = UIView.init(frame: CGRect.init(x: 0, y: y, width: selectorWidth, height: 3.0))
        //selector.layer.cornerRadius = frame.height/2
        selector.backgroundColor = selectorColor
        addSubview(selector)
        
        // Create a StackView
        
        let stackView = UIStackView.init(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // Drawing code
        
        // layer.cornerRadius = frame.height/2
        
    }
    
    // MARK: -  Action
    @objc func buttonTapped(button: UIButton) {
        
        for (buttonIndex,btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == button {
                selectedSegmentIndex = buttonIndex
                let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = selectorStartPosition
                })
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
    
    
    func updateSegmentedControlSegs(index: Int) {
        for btn in buttons {
            btn.setTitleColor(textColor, for: .normal)
        }
        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
        UIView.animate(withDuration: 0.3, animations: {
            
            self.selector.frame.origin.x = selectorStartPosition
        })
        buttons[index].setTitleColor(selectorTextColor, for: .normal)
    }
    
    
    
    //    override func sendActions(for controlEvents: UIControlEvents) {
    //
    //        super.sendActions(for: controlEvents)
    //
    //        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(selectedSegmentIndex)
    //
    //        UIView.animate(withDuration: 0.3, animations: {
    //
    //            self.selector.frame.origin.x = selectorStartPosition
    //        })
    //
    //        buttons[selectedSegmentIndex].setTitleColor(selectorTextColor, for: .normal)
    //
    //    }
    
    
    
}
