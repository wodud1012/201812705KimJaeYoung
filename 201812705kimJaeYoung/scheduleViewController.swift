//
//  scheduleViewController.swift
//  201812705kimJaeYoung
//
//  Created by 김재영 on 2018. 12. 21..
//  Copyright © 2018년 JaeYoung. All rights reserved.
//

import UIKit
import CoreData

class scheduleViewController: UITableViewController {

    @IBOutlet weak var scheduleTitle: UITextField!//일정
    @IBOutlet weak var allDay: UISwitch!
    @IBOutlet weak var saveDay: UILabel!//저장할 날짜
    @IBOutlet weak var startTime: UILabel!//시작 날짜
    @IBOutlet weak var endTime: UILabel!//종료 날짜
    @IBOutlet weak var picker: UIDatePicker!//시간 선택
    
    var selecdate: String?//메인에서 선택 후 넘어 온 값.
    
    lazy var list: [NSManagedObject] = {// 데이터 소스 변수
        return self.fetch()
    }()
    
    func fetch() -> [NSManagedObject] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // 앱 델리게이트 객체 참조
        
        let context = appDelegate.persistentContainer.viewContext // 관리 객체 컨텍스트 참조
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ScheduleEntitiy") // 객체 생성
        
        let result = try! context.fetch(fetchRequest) //가져오기
        print(result)
        return result
    }
    
    @IBAction func changeAllDay(_ sender: UISwitch) {
        
        if allDay.isOn == true{//스위치가 켜져있으면
            picker.isEnabled = false//피커뷰 사용 못함
            startTime.text = "하루"
            endTime.text = "종일"
        }else{//스위치가 꺼져있으면
            picker.isEnabled = true
            self.startTime.text = " 00:00"
            self.endTime.text = " 23:59"
        }
    }
    @IBAction func saveSchedule(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "일정을 입력하세요.", preferredStyle: .alert)
        let alertadd = UIAlertController(title: nil, message: "추가 되었습니다.", preferredStyle: .alert)
        
        
        save(scheduleTitle: scheduleTitle.text!, saveDay: saveDay.text!, startTime: startTime.text!, endTime: endTime.text!)
        
        print("일정:\(scheduleTitle!)")
        
        if scheduleTitle.text == ""{//아무것도 입력안하고 추가 시 안됨
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: false, completion: nil)
        }else{
            alertadd.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alertadd, animated: false, completion: nil)
        }
    }
    
    func save(scheduleTitle: String, saveDay: String, startTime: String, endTime: String) -> Bool {
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // 앱 델리게이트 객체 참조
        
        let context = appDelegate.persistentContainer.viewContext // 관리 객체 컨텍스트 참조
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "ScheduleEntitiy", into: context)// 관리 객체 생성, 값을 설정
        object.setValue(scheduleTitle, forKey: "scheduleTitle")
        object.setValue(saveDay, forKey: "saveDay")
        object.setValue(startTime, forKey: "startTime")
        object.setValue(endTime, forKey: "endTime")
        
        do {// 저장소에 커밋 후 list 프로퍼티에 추가
            try context.save()
            //self.list.append(object)
            self.list.insert(object, at: 0)
            print(object)
            print("성공")
            return true
        } catch {
            context.rollback()
            print("실패")
            return false
        }
    }
    var TimeSelector: Bool = true//시작 시간 종료 시간 구분
    
    @objc func timeFormat() {//시작 시간과 종료 시간을 넣는 메서드
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateFormat = "a hh:mm"
        let startDate = dateFormatter.string(from: picker.date)
        
        if TimeSelector {//시작 시간이면
            self.startTime.text = startDate//시간
        }else{//종료시간이면
            self.endTime.text = startDate
        }
        
    }
    
    
    /*----------------------------------viewDidLoad----------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        /*-------------------------Table표시-------------------------*/
        self.allDay.isOn = false//하루종일 스위치
        self.saveDay.text = selecdate//일정을 저장할 날짜
        self.startTime.text = "미지정"//시작시간 레이블
        self.endTime.text = "미지정"//종료 시간 레이블
        
        if let Selecdate = selecdate{
            print("넘어온 값:\(Selecdate)")
        }else{
            print("값이 넘어오지 않음")
        }
        /*-------------------------Table표시-------------------------*/
    }
    
    /*----------------------------------viewDidLoad----------------------------------*/
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3{
            TimeSelector = true
            picker.addTarget(self, action: #selector(timeFormat), for: .valueChanged)
        }
        if indexPath.row == 4{
            TimeSelector = false
            picker.addTarget(self, action: #selector(timeFormat), for: .valueChanged)
        }
    }
}
