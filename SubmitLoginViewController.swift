//
//  SubmitLoginViewController.swift
//  HSE App
//
//  Created by Ян Мелоян on 19/04/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import UIKit

class SubmitLoginViewController: UIViewController {

    @IBOutlet weak var contBut: UIButton!
    @IBOutlet weak var subMsg: UILabel!
    @IBOutlet weak var codeField: UITextField!
    
    @IBAction func codeSubmit(_ sender: Any) {
        
        let loadAlert = UIAlertController(title: nil, message: "Загрузка...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadAlert.view.addSubview(loadingIndicator)
        present(loadAlert, animated: true, completion: nil)
        
        session.loginSubmit(code: codeField.text ?? "") { res in
            DispatchQueue.main.async{
                if res {
                    UserDefaults.standard.set(session.account!.data.token, forKey: "Token")
                    
                    loadAlert.dismiss(animated: false, completion: nil)
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                    newViewController.modalTransitionStyle = .crossDissolve
                    self.present(newViewController, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Ошибка", message: "Неправильный код", preferredStyle: UIAlertController.Style.alert)
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
    @IBAction func BackClick(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "login")
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        subMsg.text = "На вашу почту " + session.login + " было выслано письмо с кодом подтверждения. Введите его ниже."
        contBut.layer.cornerRadius = 8
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}
