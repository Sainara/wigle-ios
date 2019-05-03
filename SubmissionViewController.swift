//
//  SubmissionViewController.swift
//  HSE App
//
//  Created by Ян Мелоян on 22/04/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import UIKit

class SubmissionViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        var relForm:FormData?
        for include in session.ListOfSubmissions.included ?? [] {
            if (include.id == session.ListOfSubmissions.data?[session.clikedSub!].relationships?.form?.data?.id) {
               relForm = include
            }
        }
        titleLabel.text = relForm!.attributes.title
        statusLabel.text = "Статус: " + session.ListOfSubmissions.data![session.clikedSub!].GetStatus()
        var iy:Int = 200
        var skip:Bool?, isTextArea:Bool?
        
        for key in session.ListOfSubmissions.data![session.clikedSub!].attributes.data!.keys {
            var lb:String?
            skip = false
            isTextArea = false
            for form in relForm!.attributes.fields! {
                if (form.name! == key) {
                    lb = form.title
                    if (form.type == "file") {
                        skip = true
                    }
                    if (form.type == "textarea") {
                        isTextArea = true
                    }
                }
            }
            if (skip!) {
                continue
            }
            let titleLabel = UILabel(frame: CGRect(x: 23, y: iy, width: 360, height: 30))
            let valueLabel:UILabel?
            if (!isTextArea!) {
                iy += 30
                valueLabel = UILabel(frame: CGRect(x: 23, y: iy, width: 360, height: 30))
            } else {
                iy += 30
                valueLabel = UILabel(frame: CGRect(x: 23, y: iy, width: 360, height: 60))
                valueLabel?.numberOfLines = 2
                iy += 30
            }
            titleLabel.text = lb
            valueLabel!.text = session.ListOfSubmissions.data![session.clikedSub!].attributes.data![key]?.description
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            self.view.addSubview(titleLabel)
            self.view.addSubview(valueLabel!)

            iy += 50
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}
