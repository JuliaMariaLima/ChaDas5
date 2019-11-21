//
//  TermsAndConditions.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 19/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//


import Foundation
import UIKit
import WebKit

class TermsAndConditions: UIViewController {
    
    @IBOutlet weak var web: WKWebView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "Termos de Serviço Chá das 5", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        
        web.load(request)
    }

}
