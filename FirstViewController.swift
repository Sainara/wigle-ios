//
//  FirstViewController.swift
//  HSE App
//
//  Created by Ян Мелоян on 16/01/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import UIKit

class SubmissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var ListOfSubmissions: UITableView!
    @IBOutlet weak var NoSubMsg: UILabel!
    @IBOutlet weak var load: UIActivityIndicatorView!
    
    var refreshControl = UIRefreshControl()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.ListOfSubmissions.data?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissCell", for: indexPath)
        for include in session.ListOfSubmissions.included ?? [] {
            if (include.id == session.ListOfSubmissions.data?[indexPath.row].relationships?.form?.data?.id) {
                cell.textLabel?.text = include.attributes.title
            }
        }
        cell.detailTextLabel?.text = "Статус: " + (session.ListOfSubmissions.data?[indexPath.row].GetStatus() ?? " ")
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        session.clikedSub = indexPath.row
    }
    
    @objc func refresh(_ sender:AnyObject) {
         session.GetSubmissions(view: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ListOfSubmissions.tableFooterView = UIView()
        ListOfSubmissions.backgroundColor = .groupTableViewBackground
        
        session.GetSubmissions(view: self)
       // refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        ListOfSubmissions.addSubview(refreshControl)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.setNeedsLayout()  
        session.GetSubmissions(view: self)
    }
}

