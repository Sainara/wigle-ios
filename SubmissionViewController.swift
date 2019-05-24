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
    
    override func viewDidAppear(_ animated: Bool) {
        
        session.GetSubmission() { res in
            DispatchQueue.main.async {
                
                self.titleLabel.text = res.form.title
                self.statusLabel.text = "Статус: " + res.GetStatus()
                var iy:Int = 180
                
                for ans in res.answers ?? [] {
                    let titleLabel = UILabel(frame: CGRect(x: 23, y: iy, width: 360, height: 30))
                    iy += 30
                    let valueLabel = UILabel(frame: CGRect(x: 23, y: iy, width: 360, height: 30))
                    
                    titleLabel.text = res.form.fields.first(where: { $0.id == ans.field_id})?.title ?? " "
                    valueLabel.text = ans.value
                    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
                    self.view.addSubview(titleLabel)
                    self.view.addSubview(valueLabel)

                    iy += 40
                }
                if res.status == "new" {
                    let delBut = UIButton(frame: CGRect(x: 20, y: iy, width: 300, height: 47))
                    
                    iy += 50
                    delBut.setTitle("Удалить",for: .normal)
                    delBut.setTitleColor(.white, for: .normal)
                    delBut.backgroundColor = UIColor.red

                    delBut.titleLabel!.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                    delBut.layer.cornerRadius = 8
                    delBut.addTarget(self, action: #selector(self.buttonAction(_:)), for: .touchUpInside)
                    
                    self.view.addSubview(delBut)
                }
            }
        }
    }
    
    @objc func buttonAction(_ sender:UIButton!) {
        session.DeleteSubmission() { res in
            DispatchQueue.main.async {
                if res {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                    newViewController.modalTransitionStyle = .crossDissolve
                    self.present(newViewController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Ошибка", message: "Заявка не удалена", preferredStyle: UIAlertController.Style.alert)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}
