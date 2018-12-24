//
//  ViewController.swift
//  201812705kimJaeYoung
//
//  Created by 김재영 on 2018. 12. 8..
//  Copyright © 2018년 Rio. All rights reserved.
//

import UIKit
import FSCalendar
import CoreData

class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var tableview: UITableView!
    
    var Day: String?//일정 추가시 들어갈 데이터
    var sub = [String]()
    
    lazy var list: [NSManagedObject] = {// 데이터 소스 변수
        return self.fetch()
    }()
    
    func fetch() -> [NSManagedObject] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // 앱 델리게이트 객체 참조
        let context = appDelegate.persistentContainer.viewContext // 관리 객체 컨텍스트 참조
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ScheduleEntitiy") // 3. 요청 객체 생성
        let result = try! context.fetch(fetchRequest) // 4. 데이터 가져오기
        print("fetch실행")
        return result
    }

    
    func delete(object: NSManagedObject) -> Bool{
        // 1. 앱 델리게이트 객체 참조
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // 2. 관리 객체 컨텍스트 참조
        let context = appDelegate.persistentContainer.viewContext
        
        // 3. 컨텍스트로부터 해당 객체 삭제
        context.delete(object)
        
        // 4. 영구 저장소에 커밋한다.
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func reloadData() -> [NSManagedObject] {//새로 고침
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ScheduleEntitiy")
        let context = appDelegate.persistentContainer.viewContext
        
        let result = try! context.fetch(fetchRequest)
        //print("result:\(result)")
        return result
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //--------------델리게이트, 데이터소스--------------//
        calendar.dataSource = self
        calendar.delegate = self
        
        tableview.delegate = self
        tableview.dataSource = self
        //--------------델리게이트, 데이터소스--------------//

        //------------------달력기본설정-----------------//
        calendar.appearance.borderRadius = 1 //날짜 배경 동그랗게
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0; //이전달 다음달 없애기
        calendar.appearance.headerDateFormat = "MMM. yyyy" // 헤더 날짜 형식
        //calendar.allowsMultipleSelection = true //여러날짜를 동시에 선택할 수 있도록
        calendar.clipsToBounds = false //달력 구분 선 제거
        //------------------달력기본설정-----------------//
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if Day == nil{//날짜가 nil이면
            let dateToday: Date = self.calendar.today!//오늘
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateTodayString = dateFormatter.string(from: dateToday)//string변환
            Day = dateTodayString
            print(dateTodayString)
        }
        fetch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let schedule = segue.destination as! scheduleViewController
        schedule.selecdate = Day
    }
    
    //-----------------------------------------------------------------Calendar-------------------------------------------------//

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {//데이터 선택시 이벤트
        let dateselecday: Date = self.calendar.selectedDate!//선택한 날짜로 됨
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: dateselecday)
        
        print(dateString)
        Day = dateString
        self.tableview.reloadData()

    }
    
    //-----------------------------------------------------------------Calendar-------------------------------------------------//
    //-----------------------------------------------------------------Table View-----------------------------------------------//=
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "일정 삭제", message: "일정을 삭제하면 다시 작성해야 합니다.\n 그래도 삭제하시겠습니까?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .default) {(_) in
            let object = self.list[indexPath.row]
            if self.delete(object: object) {
                // 코어 데이터에서 삭제되고 나면 배열 목록과 테이블 뷰의 행도 삭제한다.
                self.list.remove(at: indexPath.row)
                self.tableview.deleteRows(at: [indexPath], with: .fade)
            }
        })
        self.present(alert, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {//날짜에 해당하지 않는 데이터는 안보이게 처리
        let record = self.list[indexPath.row]
        let saveDay = record.value(forKey: "saveDay") as? String
        if saveDay == Day{
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "schedulecell", for: indexPath) as! scheduleCell
        
        let record = self.list[indexPath.row]
        let scheduleTitle = record.value(forKey: "scheduleTitle") as? String
        let saveDay = record.value(forKey: "saveDay") as? String
        let startTime = record.value(forKey: "startTime") as? String
        let endTime = record.value(forKey: "endTime") as? String
        
        if saveDay == Day{
        cell.scheduleTitle?.text = scheduleTitle
        cell.saveDay?.text = saveDay
        cell.startTime?.text = startTime
        cell.endTime?.text = endTime
        }
        return cell
    }
    //-----------------------------------------------------------------Table View-----------------------------------------------//
    
}

