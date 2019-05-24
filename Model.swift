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
    
    let url = "https://wingle-api.krsq.me/api/v2/"
    
    var account:Account?
    var login:String = ""
    var ListOfSubmissions:SubsList = SubsList()
    var listOfForms:FormsList = FormsList()
    var clickedForm:Int?, clikedSub:Int?
    var sub:CreateSub?
    var SubFields:[Int : [ String : UITextField]] = [:]

    init() {
    }
    
    //////////////////////////
    /////// INIT WITH TOKEN
    func InitWithToken(token:String, completion: @escaping (Bool) -> Void) {
        
        let path = url + "user/me"
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {
                    completion(false)
                    return
                }
            }
            guard let data = data else {return}
            do {
                self.account = try JSONDecoder().decode(Account.self, from: data)
                self.account?.data.token = token
                completion(true)
                return
            } catch {
                print(error)
            }
         }.resume()
        completion(false)
        return
    }
    
    //////////////////////////
    /////// CHECK VALID LOGIN
    func loginExist(login:String, completion: @escaping (Bool) -> Void) {
        
        let parameters = ["email" : login]
        let path = url + "auth/email"
        
        var request = URLRequest(url: URL(string: path)!)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode == 204) {
                    completion(true)
                    return
                }
            }
            completion(false)
            return
        }.resume()
    }
    
    //////////////////////////
    /////// CONFIRM LOGIN
    func loginSubmit(code:String, completion: @escaping (Bool) -> Void) {
        
        let parameters = ["email" : login, "code" : code]
        let path = url + "auth/code"
        
        var request = URLRequest(url: URL(string: path)!)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                print(String(httpResponse.statusCode))
                if (httpResponse.statusCode == 200) {}
                guard let data = data else {return}
                do {
                    self.account = try JSONDecoder().decode(Account.self, from: data)
                    completion(true)
                    return
                } catch {
                    print(error)
                }
            }
            completion(false)
            return
        }.resume()
    }
    
    //////////////////////////
    /////// GET SUBS
    func GetSubmissions(completion: @escaping (Bool) -> Void) {

        let path = url + "submission"
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + account!.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {}
            }
            guard let data = data else {return}
            do {
                self.ListOfSubmissions = try JSONDecoder().decode(SubsList.self, from: data)
                completion(true)
                return
            } catch {
                print(error)
            }
        }.resume()
        completion(false)
        return
    }
    
    //////////////////////////
    /////// GET SUB
    func GetSubmission(completion: @escaping (SubmissionData) -> Void) {
        
        let path = url + "submission/" + String(clikedSub!)
        
        print(path)
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + account!.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                print(httpResponse.statusCode)
                if (httpResponse.statusCode != 200) {}
            }
            guard let data = data else {return}
            

            do {
                let data = try JSONDecoder().decode(Submission.self, from: data)
                completion(data.data)
                return
            } catch {
                print(error)
            }
        }.resume()
    }

    //////////////////////////
    /////// GET FACULTY NAME
    func GetFacultyName(completion: @escaping (String) -> Void) {

        let path = url + "course/" + String(account!.data.settings.default_course)
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + account!.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in

            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {
                }
            }
            guard let data = data else {return}
            do {
                let data = try JSONDecoder().decode(Fac.self, from: data)
                completion(data.data.title)
                return
            } catch {
                print(error)
            }
        }.resume()
        completion("Неизвестный факультет")
        return
    }

    //////////////////////////
    /////// GET FORMS
    func GetForms(completion: @escaping (Bool) -> Void) {
    
        let path = url + "form?course_id=" + account!.GetCourse()
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + account!.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {}
            }
            guard let data = data else {return}
            do {
                self.listOfForms = try JSONDecoder().decode(FormsList.self, from: data)
                completion(true)
                return
            } catch {
                print(error)
            }
        }.resume()
        completion(false)
        return
    }
    
    //////////////////////////
    /////// GET FORM
    func GetForm(completion: @escaping (FormData) -> Void) {
        
        let path = url + "form/" + String(clickedForm!)
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + account!.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                if (httpResponse.statusCode != 200) {}
            }
            guard let data = data else {return}
            print(String(data: data, encoding: .utf8))
            do {
                let data = try JSONDecoder().decode(Form.self, from: data)
                print(data.data)
                completion(data.data)
                return
            } catch {
                print(error)
            }
        }.resume()
    }
   
    //////////////////////////
    /////// POST SUBMISSION
    func PostSubmission(completion: @escaping (Bool) -> Void) {

        let path = url + "submission"
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "POST"
        request.setValue("Bearer " + account!.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        sub = CreateSub(formID: clickedForm!, fields: SubFields)

        let encoder = JSONEncoder()
        guard let httpBody = try? encoder.encode(sub!) else {return}
        request.httpBody = httpBody
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                print(httpResponse.statusCode)
                //print(String(data: data!, encoding: .utf8))
                if (httpResponse.statusCode == 200) {
                    completion(true)
                    return
                }
            }
            completion(false)
            return
        }.resume()
    }
    
    //////////////////////////
    /////// DELETE SUBMISSION
    func DeleteSubmission(completion: @escaping (Bool) -> Void) {
        
        let path = url + "submission/" + String(clikedSub!)
        
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "DELETE"
        request.setValue("Bearer " + account!.GetToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let s = URLSession.shared
        s.dataTask(with: request) { (data, res, error) in
            if let httpResponse = res as? HTTPURLResponse {
                print(httpResponse.statusCode)
                if (httpResponse.statusCode == 204) {
                    completion(true)
                    return
                }
            }
            completion(false)
            return
            }.resume()
    }

    //////////////////////////
    /////// LOG OUT
    func logOut() {
        account = nil
        ListOfSubmissions = SubsList()
        listOfForms = FormsList()
        login = ""
        UserDefaults.standard.removeObject(forKey: "Token")
    }
}

////////////////////////////////////////
//    ACCOUNT STRUCT
////////////////////////////////////////
struct Account : Decodable {
    
    var data:User

    func GetCourse() -> String {return String(data.settings.default_course)}
    func GetToken() -> String {return data.token!}
    func GetRole() -> String {
        switch data.user.type {
        case "staff":
            return "Сотрудник УО"
        case "student":
            return "Студент"
        default:
            return "Неизвестно"
        }
    }
}
struct User : Decodable {
    var user:UserData, token:String?, settings:UserSettings
}
struct UserData : Decodable {
    var id:String, uns:String, externalId:String, type:String, fio:String, info:String
}
struct UserSettings : Decodable {
    var default_course:Int
}


////////////////////////////////////////
//    LIST OF FORM STRUCT
////////////////////////////////////////
struct FormsList : Decodable {
    var data:[FormFromList] = []
}
struct FormFromList : Decodable {
    var id:Int, title:String = "", description:String? = ""
}

////////////////////////////////////////
//    LIST OF SUBS STRUCT
////////////////////////////////////////
struct SubsList : Decodable {
    var data:[SubFromList] = []
}
struct SubFromList : Decodable {
    var id:Int, form_id:Int, status:String = "", form:FormFromList
    
    func GetStatus() -> String {
        switch status {
        case "new":
            return "Новая"
        case "in_progress":
            return "В процессе"
        case "proceeded":
            return "Выполнен"
        case "rejected":
            return "Отклонён"
        case "cancelled":
            return "Отменён"
        default:
            return "Неопределено"
        }
    }
}

////////////////////////////////////////
//    FACULTY NAME
////////////////////////////////////////
struct Fac : Decodable {
    var data:FacData
}
struct FacData : Decodable  {
    var title:String
}

////////////////////////////////////////
//    FORM STRUCT
////////////////////////////////////////
struct Form : Decodable {
    var data:FormData
}
struct FormData : Decodable {
    var id:Int, title:String, description:String? = "", fields:[Field]
}

////////////////////////////////////////
//    SUBMISSION STRUCT
////////////////////////////////////////
struct Submission : Decodable{
    var data:SubmissionData
}
struct SubmissionData : Decodable {
    var id:Int, form_id:Int, status:String, form:FormData, answers:[Answer]?
    
    func GetStatus() -> String {
        switch status {
        case "new":
            return "Новая"
        case "in_progress":
            return "В процессе"
        case "proceeded":
            return "Выполнен"
        case "rejected":
            return "Отклонён"
        case "cancelled":
            return "Отменён"
        default:
            return "Неопределено"
        }
    }
}

////////////////////////////////////////
//    CREATESUB STRUCT
////////////////////////////////////////
struct CreateSub : Encodable {
    var form_id:Int, answers:[SendAnswer] = []

    init(formID:Int, fields:[Int : [ String : UITextField]]?) {
        form_id = formID
        
        for field in fields ?? [:] {
            for type in field.value {
                if type.key == "text" {
                    if (type.value.text != "") {
                        answers.append(SendAnswer.string(value: type.value.text!, field_id: field.key))
                    }
                } else {
                    var data:[String] = []
                    data.append(type.value.text ?? "")
                    answers.append(SendAnswer.array(value: data, field_id: field.key))
                }
            }
        }
    }
}

////////////////////////////////////////
//    HELPER STRUCTS
////////////////////////////////////////
struct Answer : Decodable {
    var field_id:Int, submission_id:Int?, value:String
}

enum SendAnswer : Encodable {
    
    private enum CodingKeys: String, CodingKey {
        case field_id, value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let value, let id):
            try container.encode(id, forKey: .field_id)
            try container.encode(value, forKey: .value)
        case .array(let value, let id):
            try container.encode(id, forKey: .field_id)
            try container.encode(value, forKey: .value)
        }
    }
    
    case string(value: String, field_id:Int)
    case array(value: Array<String>, field_id:Int)
}


struct Field : Decodable {
    var id:Int, title:String, description:String? = "", type:String, form_id:Int, required:Bool, meta:FieldMeta?
}
struct FieldMeta : Decodable {
    var options:[String]?, multiple:Bool?
}

////////////////////////////////////////
//    CUSTOM SELECT
////////////////////////////////////////
extension UITextField {
    func loadDropdownData(data: [String]) {
        self.inputView = MyPickerView(pickerData: data, dropdownField: self)
    }
}

class MyPickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    var pickerData : [String]!
    var pickerTextField : UITextField!
    
    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: .zero)
        
        self.pickerData = pickerData
        self.pickerTextField = dropdownField

        self.delegate = self
        self.dataSource = self
        
        
        if pickerData.count > 0 {
            self.pickerTextField.text = self.pickerData[0]
            self.pickerTextField.isEnabled = true
        } else {
            self.pickerTextField.text = nil
            self.pickerTextField.isEnabled = false
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]
    }
}
