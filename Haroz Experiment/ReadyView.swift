//
//  ReadyView.swift
//  Haroz Experiment
//
//  Created by 寿 斌 on 21/10/2016.
//  Copyright © 2016 Engyokun. All rights reserved.
//

import UIKit

class ReadyView: UIViewController {

    @IBOutlet weak var targetColor: UIView!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progress: UIView!
    
    var chosenColor: UIColor? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1,
                       animations: {self.progress.frame.size.width = self.progressBar.frame.size.width},
                       completion: {finished in self.dismiss(animated: false, completion: nil)})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tColor = chosenColor {
            targetColor.backgroundColor = tColor
        } else {
            targetColor.backgroundColor = self.view.backgroundColor
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
