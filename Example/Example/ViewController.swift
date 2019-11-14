//
//  ViewController.swift
//  Example
//
//  Created by Lshiva on 07/08/2019.
//  Copyright © 2019 what3words. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var suggestionField : W3wTextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        suggestionField!.setAPIKey(APIKey: "<Secret API Key>")
        
        suggestionField?.didSelect(completion: { (words) in
            print(words)
        })
    }
}

