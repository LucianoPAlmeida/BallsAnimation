//
//  ViewController.swift
//  TestBallsPulse
//
//  Created by Luciano Almeida on 28/08/18.
//  Copyright © 2018 Luciano Almeida. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var pulseView: BallsPulseLoadingIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func actionToggle(_ sender: Any) {
        if pulseView.isAnimating {
            pulseView.stopAnimating()
        } else {
            pulseView.startAnimating()
        }
    }

}
