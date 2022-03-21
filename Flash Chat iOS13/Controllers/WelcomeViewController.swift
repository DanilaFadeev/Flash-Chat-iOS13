//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runTitleAnimation()
    }
    
    func runTitleAnimation() {
        let initialTitle = titleLabel.text!
        titleLabel.text = ""

        for (index, letter) in initialTitle.enumerated() {
            let interval = Double(index) * 0.1
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
        }
    }

}
