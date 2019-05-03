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
        
        if (session.loginSubmit(code: codeField.text ?? "")) {
            
    
            UserDefaults.standard.set(session.account.GetToken(), forKey: "Token")
            
            session = Session(token: session.account.GetToken())
            
            while (session.account.data == nil) {}
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Ошибка", message: "Неправильный код", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ОК", style: UIAlertAction.Style.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func BackClick(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "login")
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.prefersLargeTitles = true
        subMsg.text = "На вашу почту " + session.login + " было выслано письмо с кодом подтверждения. Введите его ниже."
        contBut.layer.cornerRadius = 8
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}
