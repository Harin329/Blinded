//
//  PrivacyViewController.swift
//  Blinded-SK
//
//  Created by Harin Wu on 2020-12-23.
//  Copyright © 2021 Hao Wu. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func privacyURL(_ sender: UIButton) {
        openUrl(urlStr: "https://sites.google.com/view/take5-privacy-policy/home")
    }
    
    func openUrl(urlStr:String!) {
        
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
