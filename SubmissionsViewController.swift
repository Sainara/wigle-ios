//
//  SubmissionsViewControllerswift
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
        return session.ListOfSubmissions.data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissCell", for: indexPath)
        let sub = session.ListOfSubmissions.data[indexPath.row]

        cell.textLabel?.text = sub.form.title
        cell.detailTextLabel?.text = "Статус: " + (sub.GetStatus())
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        session.clikedSub = session.ListOfSubmissions.data[indexPath.row].id
    }
    
    @objc func refresh(_ sender:AnyObject) {
        session.GetSubmissions() { res in
            DispatchQueue.main.async{
                if res {
                    self.load.alpha = 0
                    self.ListOfSubmissions.reloadData()
                    if (session.ListOfSubmissions.data.count == 0) {
                        self.NoSubMsg.alpha = 1
                    }
                }
                self.refreshControl.endRefreshing()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ListOfSubmissions.tableFooterView = UIView()
        ListOfSubmissions.backgroundColor = .groupTableViewBackground
        
        session.GetSubmissions() { res in
            DispatchQueue.main.async{
                if res {
                    self.load.alpha = 0
                    self.ListOfSubmissions.reloadData()
                    if (session.ListOfSubmissions.data.count == 0) {
                        self.NoSubMsg.alpha = 1
                    }
                }
            }
        }
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        ListOfSubmissions.addSubview(refreshControl)
    }
}

