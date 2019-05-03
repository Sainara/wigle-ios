//
//  Settings.swift
//  HSE App
//
//  Created by Ян Мелоян on 17/01/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var mainName: UILabel!
    @IBOutlet weak var middleName: UILabel!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    func InitUserData(){
        mainName.text = session.account.GetLastName() + " " + session.account.GetFistName()
        middleName.text = session.account.GetMiddleName()
        grade.text = session.account.GetRole()
        email.text = session.account.GetEmail()
        phone.text = "Бакалавриат группа БПИ174-2017"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        InitUserData()
    }
}

class SettingTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if (indexPath.row == 2) {
            session.logOut()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.present(newViewController, animated: true, completion: nil)
        } else {
            if let link = URL(string: "https://www.google.com/") {
                UIApplication.shared.open(link)
            }
        }
    }
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
}
