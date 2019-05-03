//
//  Model.swift
//  HSE App
//
//  Created by Ян Мелоян on 23/03/2019.
//  Copyright © 2019 tommywayss. All rights reserved.
//

import Foundation
import UIKit

var session = Session()

class Session {
    
    let url = "https://wingle-api.krsq.me/api/v1/"
    
    var account:Account = Account()
    var login:String = ""
    var ListOfSubmissions:Submission = Submission()
    var listOfForms:Forms?
    var categories:Categories = Categories()
    var clickedForm:Int?, clikedSub:Int?
    var sub:CreateSub?
    var SubFields:[String : UITextField] = [:]
    var request = URLRequest(url: URL(string: "https://wingle-api.krsq.me/api/v1/")!)
    
    
    init() {
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept")
    }
    //////////////////////////
    /////// INIT WITH TOKEN
    init(token:String) {
        
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept")
        
        let path = url + "me"
        request.url = URL(string: path)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {
                    self.logOut()
                }
            }
            guard let data = data else {return}
            do {
                self.account = try JSONDecoder().decode(Account.self, from: data)
                self.account.meta = Token(token: token)
                self.GetPrimaryFaculty()
            } catch {
                print(error)
            }
        }.resume()
    }
    
    //////////////////////////
    /////// CHECK VALID LOGIN
    func loginExist(login:String) -> Bool {
        if (login == "") {return false}
        
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        let parameters = ["email" : login]
        let path = url + "auth/email"
        
        var request = URLRequest(url: URL(string: path)!)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return false}
        request.httpBody = httpBody
        request.httpMethod = "POST"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode == 204) {
                    result = true
                }
            }
            semaphore.signal()
            
            guard let data = data else {return}
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        }.resume()
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    //////////////////////////
    /////// CONFIRM LOGIN
    func loginSubmit(code:String) -> Bool {
        if (code == "") {return false}
        
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        let parameters = ["email" : login, "code" : code]
        let path = url + "auth/code"
        
        request.url = URL(string: path)!
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return false}
        request.httpBody = httpBody
        request.httpMethod = "POST"
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    result = true
                    guard let data = data else {return}
                    do {
                        self.account = try JSONDecoder().decode(Account.self, from: data)
                    } catch {
                        print(error)
                    }
                    semaphore.signal()
                }
            }

            }.resume()
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
    //////////////////////////
    /////// GET SUBS
    func GetSubmissions(view:SubmissionsViewController) {
        
        let path = url + "users/" + account.GetID() + "/submissions?include=form"
        request.url = URL(string: path)!
        request.httpMethod = "GET"
        request.setValue("Bearer " + account.GetToken(), forHTTPHeaderField: "Authorization")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {}
            }
            guard let data = data else {return}
            do {
                self.ListOfSubmissions = try JSONDecoder().decode(Submission.self, from: data)
                DispatchQueue.main.async{
                    view.ListOfSubmissions.reloadData()
                    if ((view.ListOfSubmissions.numberOfRows(inSection: 0)) == 0) {
                        view.NoSubMsg.alpha = 1
                    }
                    view.load.alpha = 0
                    view.refreshControl.endRefreshing()
                 //   view.activityIndicatorView.stopAnimating()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    //////////////////////////
    /////// GET SUBS
    func GetSubmissions() {
        
        let path = url + "users/" + account.GetID() + "/submissions?include=form"
        request.url = URL(string: path)!
        request.httpMethod = "GET"
        request.setValue("Bearer " + account.GetToken(), forHTTPHeaderField: "Authorization")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {}
            }
            guard let data = data else {return}
            do {
                self.ListOfSubmissions = try JSONDecoder().decode(Submission.self, from: data)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    //////////////////////////
    /////// GET FACULTY
    func GetPrimaryFaculty() {
        
        let path = url + "me/getDefaultCourse"
        request.url = URL(string: path)!
        request.httpMethod = "GET"
        request.setValue("Bearer " + account.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept")

        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {
                }
            }
            guard let data = data else {return}
            do {
                self.account.primaryFaculty = try JSONDecoder().decode(PrimaryFaculty.self, from: data)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    //////////////////////////
    /////// GET CATEGORIES
    func GetCategories(view:FormsViewController) {
        
        while (account.primaryFaculty == nil) {}
        let path = url + "courses/" + account.primaryFaculty!.data.id + "/categories"
        request.url = URL(string: path)!
        request.httpMethod = "GET"
        request.setValue("Bearer " + account.GetToken(), forHTTPHeaderField: "Authorization")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {}
            }
            guard let data = data else {return}
            do {
                self.categories = try JSONDecoder().decode(Categories.self, from: data)
                self.categories.count = self.categories.data?.count
                self.categories.isLoaded = true
                self.GetForms(view: view)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    //////////////////////////
    /////// GET FORMS
    func GetForms(view:FormsViewController) {
        
        var cur:Int = 0
        
        request.setValue("Bearer " + account.GetToken(), forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        for category in categories.data ?? [] {
            
            let path = url + "categories/" + category.id + "/forms"
            request.url = URL(string: path)!
            
            let s = URLSession.shared
            s.dataTask(with: request) { (data, res, error) in
                if let httpResponse = res as? HTTPURLResponse {
                    if (httpResponse.statusCode != 200) {}
                }
                guard let data = data else {return}
                do {
                    let get = try JSONDecoder().decode(Forms.self, from: data)
                    if (self.listOfForms == nil) {
                        self.listOfForms = get
                    } else {
                        for form in get.data ?? [] {
                            self.listOfForms?.data?.append(form)
                        }
                    }
                    cur += 1
                    if (cur == self.categories.count) {
                        self.listOfForms?.isLoaded = true
                    }
                    DispatchQueue.main.async{
                        view.ListOfForms.reloadData()
                        view.load.alpha = 0
                    }
                } catch {
                    print(error)
                }
            }.resume()
        }
        
    }

    func PostSubmission(view:UICreateSubViewController) {
        
        let path = url + "submissions?include=form"
        request.url = URL(string: path)!
        request.httpMethod = "POST"
        request.setValue("Bearer " + account.GetToken(), forHTTPHeaderField: "Authorization")
        
        sub = CreateSub(formID: listOfForms!.data![session.clickedForm!].id, fields: SubFields)
        
        let encoder = JSONEncoder()
        guard let httpBody = try? encoder.encode(sub!) else {return}
        request.httpBody = httpBody
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode == 201) {
                    
                    do {
                        let sub = try JSONDecoder().decode(CreatedSubmission.self, from: data!)
                        self.clikedSub = self.ListOfSubmissions.data!.count
                        self.ListOfSubmissions.data?.append(sub.data!)
                    } catch {
                        
                    }
                    
                    DispatchQueue.main.async{
                        //view.performSegue(withIdentifier: "subView", sender: nil)
                        //[self.storyboard performseguewithidentifier:@"toSub"];

                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "subView2")
                        newViewController.modalTransitionStyle = .crossDissolve
                        //
                        //view.present(newViewController, animated: true, completion: nil)
                        view.navigationController?.pushViewController(newViewController, animated: true)
                    }
                }
            }
        }.resume()
    }
    
    //////////////////////////
    /////// LOG OUT
    func logOut() {
        account = Account()
        ListOfSubmissions = Submission()
        listOfForms = nil
        login = ""
        UserDefaults.standard.removeObject(forKey: "Token")
    }
    
    func GetSession() -> Session {
        return self
    }

}

////////////////////////////////////////
//    ACCOUNT STRUCT
////////////////////////////////////////
struct Account : Decodable {
    
    var data:AccountData?, meta:Token?, primaryFaculty:PrimaryFaculty?
    
    func GetID() -> String {return (data?.id)!}
    func GetToken() -> String {return (meta?.token)!}
    func GetLastName() -> String {return data?.attributes?.last_name ?? " "}
    func GetFistName() -> String {return data?.attributes?.first_name ?? " "}
    func GetMiddleName() -> String {return data?.attributes?.middle_name ?? " "}
    func GetEmail() -> String {return data?.attributes?.email ?? " "}
    func GetPhone() -> String {return data?.attributes?.phone ?? " "}
    func GetRole() -> String {
        switch data?.attributes?.role {
        case "staff":
            return "Сотрудник УО"
        case "student":
            return "Студент"
        case "teacher":
            return "Преподаватель"
        case "applicant":
            return "Абитуриент"
        case "parent":
            return "Родитель"
        default:
            return "Неизвестно"
        }
    }
}
struct Token : Decodable {
    var token:String?
}
struct AccountData : Decodable {
    var type:String?, id:String?
    var attributes:AccountAttributies?
}
struct AccountAttributies : Decodable {
    var first_name:String?, middle_name:String?, last_name:String?,
    email:String?, phone:String?, role:String?
}

////////////////////////////////////////
//    SUBMISSION STRUCT
////////////////////////////////////////
struct Submission : Decodable {
    var data:[SubData]?, included:[FormData]?
}
struct CreatedSubmission : Decodable {
    var data:SubData?, included:[FormData]?
}
struct SubData : Decodable {
    var id:String, attributes:SubmissionAttributies, relationships:RelationsData?
    
    func GetStatus() -> String {
        switch attributes.status {
        case "new":
            return "Новая"
        default:
            return "Неопределено"
        }
    }
}
struct SubmissionAttributies : Decodable {
    var status:String, data:[String:SubDatas]?, created_at:String
}
struct RelationsData : Decodable {
    var form:RelForm?
}
struct RelForm : Decodable {
    var data:RelFormData?
}
struct RelFormData : Decodable {
    var id:String, type:String
}
enum SubDatas: Decodable, CustomStringConvertible {
    
    var description : String {
        switch self {

        case .int(let value): return String(value)
        case .string(let value): return String(value)
        case .array(let value):
            var result:String = ""
            for val in value {
                result += val + ", "
            }
            return result
        }
    }
    
    case int(Int)
    case string(String)
    case array(Array<String>)
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()
        
        do {
            let doubleVal = try container.decode(Int.self)
            self = .int(doubleVal)
        } catch DecodingError.typeMismatch {
            do {
                let arrayVal = try container.decode(Array<String>.self)
                self = .array(arrayVal)
            } catch DecodingError.typeMismatch {
                let stringVal = try container.decode(String.self)
                self = .string(stringVal)
            }
        }
    }
}


////////////////////////////////////////
//    FORM STRUCT
////////////////////////////////////////
struct Forms : Decodable {
    var data:[FormData]?, isLoaded:Bool? = false
}
struct FormData : Decodable {
    var id:String, attributes:FormAttributies
}
struct FormAttributies : Decodable {
    var title:String, description:String, fields:[FormField]?
}
struct FormField : Decodable {
    var name:String?, type:String, title:String?, description:String?, meta:FieldMeta?
}
struct FieldMeta : Decodable {
    var options:[String]?
}

////////////////////////////////////////
//    PRIMARYFACULTY STRUCT
////////////////////////////////////////
struct PrimaryFaculty : Decodable {
    var data:FacultyData
}
struct FacultyData : Decodable {
    var id:String, attributes:FacultyAttr
}
struct FacultyAttr : Decodable {
    var title:String
}

////////////////////////////////////////
//    CATEGORIES STRUCT
////////////////////////////////////////
struct Categories : Decodable {
    var data:[Category]?, count:Int? = 0, isLoaded:Bool? = false
}
struct Category : Decodable {
    var id:String, attributes:CategoryAttributies
}
struct CategoryAttributies : Decodable {
    var title:String
}

////////////////////////////////////////
//    CREATESUB STRUCT
////////////////////////////////////////
struct CreateSub : Encodable {
    var data:CreateSubData
    
    init(formID:String, fields:[String : UITextField]?) {
        let form = CreateSubRel(form: CreateSubRelData(data: CreateRelFormData(id: formID, type: "forms")))
        data = CreateSubData(type: "submissions", attributes: CreateSubAttr(data: [:]), relationships: form)
        for field in fields! {
            data.attributes!.data![field.key] = field.value.text
        }
        print(data.attributes!.data!)
    }
}
struct CreateSubData : Encodable {
    var type:String, attributes:CreateSubAttr?, relationships:CreateSubRel?
}
struct CreateSubAttr : Encodable {
    var data:[String:String]?
}
struct CreateSubRel : Encodable {
    var form:CreateSubRelData?
}
struct CreateSubRelData : Encodable{
    var data:CreateRelFormData?
}
struct CreateRelFormData : Encodable {
    var id:String, type:String
}
