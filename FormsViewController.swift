//
//  FormsViewController.swift
//  HSE App
//
//  Created by Ян Мелоян on 16/01/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import UIKit

class FormsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var ListOfForms: UITableView!
    @IBOutlet weak var facultyLbl: UILabel!
    @IBOutlet weak var load: UIActivityIndicatorView!
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.listOfForms.data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormCell", for: indexPath)
        
        cell.textLabel?.text = (session.listOfForms.data[indexPath.row].title) 
        cell.detailTextLabel?.text = (session.listOfForms.data[indexPath.row].description) 
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        session.clickedForm = session.listOfForms.data[indexPath.row].id
    }
    
    override func viewDidLoad() {
        ListOfForms.tableFooterView = UIView()
        ListOfForms.backgroundColor = .groupTableViewBackground
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session.GetFacultyName() { res in
            DispatchQueue.main.async{
                self.facultyLbl.text = res
            }
        }
        session.GetForms() { res in
            DispatchQueue.main.async{
                if res {
                    self.load.alpha = 0
                    self.ListOfForms.reloadData()
                    
                    print(session.listOfForms)
                }
            }
        }
    }

}
