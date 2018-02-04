//
//  MainEntryViewController.swift
//  final_project
//
//  Created by Hitesh Bhatia on 12/4/17.
//  Copyright © 2017 Hitesh Bhatia. All rights reserved.
//

import UIKit

class MainEntryViewController: UIViewController {

    @IBOutlet weak var mainScreenButton: UIButton!
    var shouldStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "main.jpg")!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mainScreenButtonClicked(_ sender: Any) {
            performSegue(withIdentifier: "mainScreen", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldStart = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldStart = false
    }
    
    func start(){
        mainScreenButton.alpha = 1.0
        UIView.animate(withDuration: 1.0, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            self.mainScreenButton.alpha = 0.0
        }, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
