//
//  CreateSubViewController.swift
//  HSE App
//
//  Created by Ян Мелоян on 19/04/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import UIKit

class UICreateSubViewController: UIViewController {
    
    @IBOutlet weak var sc: UIScrollView!
    
    @IBOutlet weak var formTitle: UILabel!
    @IBOutlet weak var formDesc: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        let form = session.listOfForms!.data![session.clickedForm!]
        
        session.SubFields = [:]
        formTitle.text = form.attributes.title
        formDesc.text = form.attributes.description
        
        var iy:Int = 15
        
        for field in form.attributes.fields ?? [] {
            let titleLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
            titleLabel.text = field.title
            titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            sc.addSubview(titleLabel)
            iy += 25
            let descLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 20))
            descLabel.text = field.description ?? " "
            descLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
            sc.addSubview(descLabel)
            iy += 30
            
            switch field.type {
            case "text" :
                let input = UITextField(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
                input.borderStyle = .roundedRect
                sc.addSubview(input)
                session.SubFields[field.name!] = input
                
                iy += 50
                break
            case "textarea" :
                let input = UITextField(frame: CGRect(x: 20, y: iy, width: 300, height: 60))
                input.borderStyle = .roundedRect
                sc.addSubview(input)
                session.SubFields[field.name!] = input

                iy += 80
                break
            case "radio" :
                let input = UITextField(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
                input.borderStyle = .roundedRect
                sc.addSubview(input)
                session.SubFields[field.name!] = input

                iy += 40
                let descLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 20))
                for option in field.meta?.options ?? [] {
                    descLabel.text =  (descLabel.text ?? " ") + option + ", "
                }
                descLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
                sc.addSubview(descLabel)
                iy += 40
                break
            case "select" :
                let input = UITextField(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
                input.borderStyle = .roundedRect
                sc.addSubview(input)
                session.SubFields[field.name!] = input

                iy += 40
                let descLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 20))
                for option in field.meta?.options ?? [] {
                    descLabel.text =  (descLabel.text ?? " ") + option + ", "
                }
                descLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
                sc.addSubview(descLabel)
                iy += 40
                break
            case "file" :
                let descLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 40))
                descLabel.numberOfLines = 2
                descLabel.text = "Загрузка файлов через приложение недоступна"
                descLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
                sc.addSubview(descLabel)
                iy += 50
                break
            default:
                break
            }
            
        }
        iy += 15
        let sendBut = UIButton(frame: CGRect(x: 20, y: iy, width: 300, height: 47))
       
        iy += 50
        sendBut.setTitle("Отправить",for: .normal)
        sendBut.setTitleColor(.white, for: .normal)
        sendBut.backgroundColor = UIColor(red: 48/255, green: 85/255, blue: 164/255, alpha: 1)
        sendBut.titleLabel!.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        sendBut.layer.cornerRadius = 8
        sendBut.addTarget(self, action: #selector(self.buttonAction(_:)), for: .touchUpInside)
        
        
        
        sc.addSubview(sendBut)
        
        let spaceLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
        spaceLabel.text = ""
        sc.addSubview(spaceLabel)

        var contentRect = CGRect.zero
        
        for view in sc.subviews {
            contentRect = contentRect.union(view.frame)
        }
    sc.contentSize = contentRect.size


    }
    
    @objc func buttonAction(_ sender:UIButton!) {
        session.PostSubmission(view: self)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sc.keyboardDismissMode = .onDrag
    }
    
}
