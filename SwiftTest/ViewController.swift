//
//  ViewController.swift
//  SwiftTest
//
//  Created by gavinxqguo on 2020/11/12.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.label.text = "Fuck";
        let ocView = OCView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        self.view.addSubview(ocView);
    }

    @IBOutlet weak var label: UILabel!
    
}

