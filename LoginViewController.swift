//
//  LoginViewController.swift
//  HSE App
//
//  Created by Ян Мелоян on 09/04/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var sc: UIScrollView!
    @IBOutlet weak var logBut: UIButton!
    
    @IBAction func onLogClick(_ sender: UIButton) {
        
        let loadAlert = UIAlertController(title: nil, message: "Загрузка...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadAlert.view.addSubview(loadingIndicator)
        present(loadAlert, animated: true, completion: nil)
        
        session.loginExist(login: login.text ?? "") { res in
            DispatchQueue.main.async{
                print(res)
                if res {
                    session.login = self.login.text!
                    
                    loadAlert.dismiss(animated: false, completion: nil)
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "SubmitLogin")
                    newViewController.modalTransitionStyle = .crossDissolve
                    self.present(newViewController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Ошибка", message: "Неправильно введена почта", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: UIAlertAction.Style.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    loadAlert.dismiss(animated: false) {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.string(forKey: "Token") != nil {
            
            let loadAlert = UIAlertController(title: nil, message: "Загрузка...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            
            loadAlert.view.addSubview(loadingIndicator)
            present(loadAlert, animated: true) {
                session.InitWithToken(token: UserDefaults.standard.string(forKey: "Token")!) { res in
                    DispatchQueue.main.async {
                        if res {
                            loadAlert.dismiss(animated: false, completion: nil)
                            
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                            newViewController.modalTransitionStyle = .crossDissolve
                            self.present(newViewController, animated: true, completion: nil)
                        } else {
                            loadAlert.dismiss(animated: false, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func RegisterForKbNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func kbWillShow(_ notiffication:Notification) {
        let UserInfo = notiffication.userInfo
        let kbFrameSize = (UserInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        sc.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)

    }
    
    @objc func kbWillHide(_ notiffication:Notification) {
        sc.contentOffset = CGPoint.zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        RegisterForKbNotify()
        logBut.layer.cornerRadius = 8
        
    }
}

class LoginScrollView : UIScrollView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
