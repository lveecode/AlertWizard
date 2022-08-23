//
//  ViewController.swift
//  AlertWizard
//
//  Created by LVeecode on 07/10/2019.
//  Copyright (c) 2019 LVeecode. All rights reserved.
//

import UIKit
import AlertWizard

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //
    // MARK: - Actions
    //
    @IBAction func alertButtonAction() {
        AlertWizard.displayAlertController(forReason: 0, title: "Test title", message: "Test message", actionTitles: ["test1", "test2"], cancelTitle: "test cancel", destrTitle: "test destr", textFieldPlaceholders: ["place1", "place2"], delegate: self)
        //AlertWizard.displayAlertController(forReason: AlertCodes.TestAlert.rawValue, delegate: self)
    }

}

extension ViewController: AlertDisplayerDelegate {
    
    func didUseAction(atIndex index: Int, alertDisplayer displayer: AlertDisplayer, reason: Int) {
        print("action at index ", index)
        print("text field content: ", displayer.textFields?.first?.text ?? "none")
    }
    
    func didUseCancelActionOfAlert(withReason reason: Int) {
        print("cancel action")
    }
    
    func didUseDestructiveActionOfAlert(withReason reason: Int) {
        print("destructive action")
    }
    
}

