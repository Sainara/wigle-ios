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
    
    @IBOutlet weak var load: UIActivityIndicatorView!
    @IBOutlet weak var formTitle: UILabel!
    @IBOutlet weak var formDesc: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        session.GetForm() { form in
            DispatchQueue.main.async {
                self.formTitle.text = form.title
                self.formDesc.text = form.description
                
                self.load.alpha = 0
                var iy:Int = 15
                
                session.SubFields = [:]
                
                for field in form.fields {
                    var titleLabel:UILabel
                    if field.title.count > 35 {
                        titleLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 50))
                        iy += 50
                        titleLabel.numberOfLines = 2
                    } else {
                        titleLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
                        iy += 30
                    }
                    if field.required {
                        titleLabel.text = field.title + "*"
                    } else {
                        titleLabel.text = field.title
                    }
                    titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                    self.sc.addSubview(titleLabel)
                    switch field.type {
                        case "text" :
                            if field.description != nil {
                                var descLabel:UILabel
                                if ( field.description!.count > 45) {
                                    descLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 40))
                                    iy += 50
                                    descLabel.numberOfLines = 2
                                } else {
                                    descLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 25))
                                    iy += 30
                                }
                                
                                descLabel.text = field.description
                                descLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
                                self.sc.addSubview(descLabel)
                                
                            }
                            let input = UITextField(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
                            input.borderStyle = .roundedRect
                            self.sc.addSubview(input)
                            let fld:[String:UITextField] = ["text":input]
                            session.SubFields[field.id] = fld
            
                            iy += 50
                            break
                        case "select" :
                            let input = UITextField(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
                            input.borderStyle = .roundedRect
                            
                            input.loadDropdownData(data: field.meta?.options ?? [])
                            
                            self.sc.addSubview(input)
                            let fld:[String:UITextField] = ["select":input]
                            session.SubFields[field.id] = fld
            
                            iy += 40
                            break
                        case "attachment" :
                            let descLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 40))
                            descLabel.numberOfLines = 2
                            descLabel.text = "Загрузка файлов через приложение недоступна"
                            descLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
                            self.sc.addSubview(descLabel)
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
            
                    self.sc.addSubview(sendBut)
                
                    let spaceLabel = UILabel(frame: CGRect(x: 20, y: iy, width: 300, height: 30))
                    spaceLabel.text = ""
                    self.sc.addSubview(spaceLabel)
                
                    var contentRect = CGRect.zero
                
                    for view in self.sc.subviews {
                        contentRect = contentRect.union(view.frame)
                    }
                    self.sc.contentSize = contentRect.size
            }
            
        }
    }
    
    @objc func buttonAction(_ sender:UIButton!) {
        session.PostSubmission() {res in
            DispatchQueue.main.async {
                if res {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                    newViewController.modalTransitionStyle = .crossDissolve
                    self.present(newViewController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Ошибка", message: "Заявка не была отправлена", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: UIAlertAction.Style.default, handler: { (action) in
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                        newViewController.modalTransitionStyle = .crossDissolve
                        self.present(newViewController, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func RegisterForKbNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func kbWillShow(_ notiffication:Notification) {
        var userInfo = notiffication.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.sc.contentInset
        contentInset.bottom = keyboardFrame.size.height
        sc.contentInset = contentInset
        
    }
    
    @objc func kbWillHide(_ notiffication:Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        sc.contentInset = contentInset
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //sc.keyboardDismissMode = .onDrag
        RegisterForKbNotify()
    }
    
}
