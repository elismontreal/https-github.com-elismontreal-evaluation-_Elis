//
//  GradeController.swift
//  Evaluation+
//  Created by eleves on 17-11-24.
//  Copyright © 2017 eleves. All rights reserved.
//

import UIKit

class GradeController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var courseGradeTabView: UITableView!
    @IBOutlet weak var selectedStudentNameLb: UILabel!
    @IBOutlet weak var courseNameTxt: UITextField!
    @IBOutlet weak var courseGradeTxt: UITextField!
    @IBOutlet weak var averageLb: UILabel!

    
    typealias studentName = String
    typealias course = String
    typealias grade = Double
    
    let studentsObj = UserDefaultsManager()
    var studentGrades: [studentName: [course: grade]]!
    var arrOfCourses: [course]!
    var arrOfGrades: [grade]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        selectedStudentNameLb.text = studentsObj.getValue(theKey: "selectedStudentName") as? String
        loadStudentDefaults()
        fillUpArrays()
        
        if arrOfCourses.isEmpty{
             averageLb.text = "Average:"
        }else{
            averageLb.text = verifAverage(dictDeNotes: moienne(), regleDe3:{ $0 * 100.0 / $1})
        }
        
    }
    
    func fillUpArrays () {
        let name = selectedStudentNameLb.text
        let coursesAndGrades = studentGrades[name!] // il retourne la valeur de la cle
        arrOfCourses = [course](coursesAndGrades!.keys)
        arrOfGrades = [grade](coursesAndGrades!.values)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = courseGradeTabView.dequeueReusableCell(withIdentifier: "proto")!
        if let aCourse = cell.viewWithTag(100) as! UILabel! {
            aCourse.text = arrOfCourses[indexPath.row]
        }
        if let aGrade = cell.viewWithTag(101) as! UILabel! {
            aGrade.text = String(arrOfGrades[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let name = selectedStudentNameLb.text!
            var coursesGrades = studentGrades[name]!
            let toDelete = [course](coursesGrades.keys)[indexPath.row]
            coursesGrades[toDelete] = nil
            studentGrades[name] = coursesGrades
            studentsObj.setKey(theValue: studentGrades as AnyObject, theKey: "grades")
            fillUpArrays()
            courseGradeTabView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            if arrOfCourses.isEmpty{
                averageLb.text = "Average:"
            }else{
                averageLb.text = verifAverage(dictDeNotes: moienne(), regleDe3:{ $0 * 100.0 / $1})
            }
        }
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    func loadStudentDefaults() {
        if studentsObj.doesKeyExist(theKey: "grades") {
            studentGrades = studentsObj.getValue(theKey: "grades") as! [studentName: [course: grade]]
        } else {
            studentGrades = [studentName: [course: grade]]()
        }
    }
    
    @IBAction func addCourseAndGrades (_ sender: UIButton) {
        let name = selectedStudentNameLb.text!
        if name != " " {
            var studentCourses = studentGrades[name]!
            studentCourses[courseNameTxt.text!] = Double(courseGradeTxt.text!)
            studentGrades[name] = studentCourses
            studentsObj.setKey(theValue: studentGrades as AnyObject, theKey: "grades")
            fillUpArrays()
            courseGradeTabView.reloadData()
            courseNameTxt.text = ""
            courseGradeTxt.text = ""
        }
        if arrOfCourses.isEmpty{
            averageLb.text = "Average:"
        }else{
            averageLb.text = verifAverage(dictDeNotes: moienne(), regleDe3:{ $0 * 100.0 / $1})
        }
    }
    
    func verifAverage(dictDeNotes: [Double: Double], regleDe3: (_ somme: Double, _ sur: Double) -> Double) -> String{
      
        let sommeNotes = [Double](dictDeNotes.keys).reduce(0, +)
        let sommesur = [Double](dictDeNotes.values).reduce(0, +)
        let conversion = regleDe3(sommeNotes, sommesur)
        return String(format: "Average = %0.1f/%0.1f or %0.1f/100%%", sommeNotes, sommesur, conversion)
        
    }
    
    func moienne () ->  [Double: Double] {
        let average = arrOfGrades.reduce(0, +)
        let somme = arrOfGrades.count
        let moienne = Double(average/Double(somme))
        let dictNotes = [moienne: 10.0]
        return dictNotes
    }
    
}
