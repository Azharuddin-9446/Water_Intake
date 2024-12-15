//
//  ViewController.swift
//  Goqii Task
//
//  Created by MacBook Pro on 13/12/24.
//

import UIKit
import FSCalendar
import Charts
import CoreData


class ViewController: UIViewController {
    
    
    //MARK: -------------------- Outlet --------------------
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var btn200Ml: UIButton!
    
    //MARK: -------------------- Class Variable --------------------
    
    var posToday = 0
    let months = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var unitsSold = [0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    var selectedDate = Date()
    var mlArr = [String]()
    var timeArr = [String]()
    var totalLiter = 0.0
    var todayTotalLiter = 0.0
    var minimumDate = Date()
    var defaultGoal = 3.0
    
    //MARK: -------------------- Life Cycle Method --------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        configureUI()
       customizeCalendarAppearance()
        setBarChart(dataPoints: months, values: unitsSold)
        updateDate(date: selectedDate)
        fetchCoreData(dateLog: selectedDate)
        
        if todayTotalLiter < defaultGoal {
            scheduleRepeatingNotification()
        }
        
        let today = Date()
        calendar.deselect(today)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //  adjustScrollViewContentSize()
    }
    
    //MARK: -------------------- Core Data --------------------
    
    func createCoreData(){
        let date = selectedDate // Example: current date
        let dateString = Helper().formatDate(date)
        mlArr = []
        timeArr = []
        totalLiter = 0.0
        updateDate(date: selectedDate)
        
        unitsSold[posToday] = totalLiter
        setBarChart(dataPoints: months, values: unitsSold)
        tableView.reloadData()
        
        let dict: [String: [String]] = ["mlArray": [], "timeArr": []]
        
        // Convert dictionary to JSON data
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
            // Convert JSON data to JSON string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("jsonString")
                let data = ["logDate":dateString,"record":jsonString] as [String : Any]
                
                CoreDataHelper.shared.createData(data: [data])
            }
        }
        
    }
    
    func fetchCoreData(dateLog:Date) {
        let logs = CoreDataHelper.shared.retrieveData()
        if logs.isEmpty {
            //            let data = insertData()
            createCoreData()
            
        }else{
            let date = dateLog // Example: current date
            let dateString = Helper().formatDate(date)
            var isDataAvailable = false
            
            var dict = ""
            manageChart(logs: logs)
            var leastDate = ""
            for log in logs {
                if let logDate = log.value(forKey: "logDate") as? String,
                   let record = log.value(forKey: "record") as? String {
                    
                    
                    
                    if leastDate == "" {
                        leastDate = logDate
                    }else{
                        let lD = Helper().getMinimumDate(dateString1: leastDate, dateString2: logDate)
                        leastDate = lD!
                    }
                    
                    if logDate == dateString {
                        isDataAvailable = true
                        dict = record
                        print("Log Date: \(logDate), Record: \(record)")
                    }
                }
            }
            
            let dateString1 = leastDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Match the format of the input string
            let minDate = dateFormatter.date(from: dateString1)!
            
            minimumDate = minDate
            calendar.reloadData()
            
            
            
            if isDataAvailable {
                if let jsonData = dict.data(using: .utf8) {
                    do {
                        // Convert JSON data to dictionary
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String]] {
                            print(jsonDict) // Output: ["mlArray": ["item1", "item2", "item3"], "timeArr": ["time1", "time2", "time3"]]
                            
                            mlArr = jsonDict["mlArray"] ?? []
                            timeArr = jsonDict["timeArr"] ?? []
                            
                            totalLiter = 0.0
                            
                            for ml in mlArr {
                                let litr = ml.replacingOccurrences(of: " ML", with: "")
                                let inte = Double(litr) ?? 0.0
                                let point = inte/1000
                                
                                totalLiter = totalLiter + point
                            }
                            updateDate(date: selectedDate)
                            
                            let calendar = Calendar.current
                            
                            let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                            let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                            
                            if selectedDateComponents.year == currentDateComponents.year &&
                                selectedDateComponents.month == currentDateComponents.month &&
                                selectedDateComponents.day == currentDateComponents.day {
                                todayTotalLiter = totalLiter
                            }
                            
                            unitsSold[posToday] = totalLiter
                            setBarChart(dataPoints: months, values: unitsSold)
                            tableView.reloadData()
                        }
                    } catch {
                        print("Failed to convert JSON string to dictionary: \(error.localizedDescription)")
                    }
                }
            }else{
                createCoreData()
            }
        }
    }
    
    
    func updateCoreData(logDate:Date) {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: logDate)
        
        let dict: [String: [String]] = ["mlArray": mlArr, "timeArr": timeArr]
        
        // Convert dictionary to JSON data
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
            // Convert JSON data to JSON string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                
                let data = ["logDate":dateString,"record":jsonString] as [String : Any]
                let logs = CoreDataHelper.shared.retrieveData()
                if logs.isEmpty {
                    let data = insertData()
                    CoreDataHelper.shared.createData(data: [data])
                }else{
                    CoreDataHelper.shared.updateData(logDate: dateString, updatedFields: data)
                }
                
                let log1 = CoreDataHelper.shared.retrieveData()
                manageChart(logs: log1)
            }
        }
        
    }
    
    
    //MARK: -------------------- Chart --------------------
    
    func manageChart(logs:[NSManagedObject]){
        
        let date = selectedDate // Example: current date
        let todayDate = Helper().formatDate(date)
        
        let week = Helper().getWeek(for: todayDate)
        print(week)
        var arrDate = [String]()
        
        for log in logs {
            if let logDate = log.value(forKey: "logDate") as? String {
                arrDate.append(logDate)
            }
        }
        
        for log in logs {
            if let logDate = log.value(forKey: "logDate") as? String,
               let record = log.value(forKey: "record") as? String {
                
                var totalLiter = 0.0
                for aDay in week {
                    if arrDate.contains(aDay){
                        if (aDay == logDate) {
                            
                            do {
                                // Convert JSON data to dictionary
                                if let jsonDict = try JSONSerialization.jsonObject(with: record.data(using: .utf8)!, options: []) as? [String: [String]] {
                                    print(jsonDict)
                                    
                                    let mlArr = jsonDict["mlArray"] ?? []
                                    
                                    totalLiter = 0.0
                                    
                                    for ml in mlArr {
                                        let litr = ml.replacingOccurrences(of: " ML", with: "")
                                        let inte = Double(litr) ?? 0.0
                                        let point = inte/1000
                                        
                                        totalLiter = totalLiter + point
                                    }
                                    
                                    let dateString = aDay
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd" // Match the format of the input string
                                    
                                    let date = dateFormatter.date(from: dateString)!
                                    
                                    updateDate(date: date)
                                    
                                    unitsSold[posToday] = totalLiter
                                    
                                }
                            } catch {
                                print("Failed to convert JSON string to dictionary: \(error.localizedDescription)")
                            }
                            
                        }
                    }else{
                        let dateString = aDay
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd" // Match the format of the input string
                        
                        let date = dateFormatter.date(from: dateString)!
                        
                        updateDate(date: date)
                        
                        unitsSold[posToday] = 0.0
                    }
                }
                
            }
        }
        
        setBarChart(dataPoints: months, values: unitsSold)
        
    }
    
    func setBarChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        
        // Customization
        // chartView.chartDescription.text = "Sales Data"
        let customColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        chartDataSet.colors = [customColor]
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    
    //MARK: -------------------- Custom Methods --------------------
    
    @MainActor
    func configureUI() {
        
        calendar.scope = .week
        calendar.firstWeekday = 2
        calendar.tintColor = UIColor.black
        
    }
    
    
    func updateDate (date:Date) {
        
        let today = Helper().getDayName(from: date)
        switch today {
        case "Mon":
            posToday = 0
        case "Tue":
            posToday = 1
        case "Wed":
            posToday = 2
        case "Thu":
            posToday = 3
        case "Fri":
            posToday = 4
        case "Sat":
            posToday = 5
        case "Sun":
            posToday = 6
        default:
            posToday = 0
        }
    }
    
    func insertData() -> [String : Any] {
        
        let date = selectedDate // Example: current date
        let dateString = Helper().formatDate(date)
        
        let dict: [String: [String]] = ["mlArray": mlArr, "timeArr": timeArr]
        
        // Convert dictionary to JSON data
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
            // Convert JSON data to JSON string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("jsonString")
                let data = ["logDate":dateString,"record":jsonString] as [String : Any]
                
                return data
            }
        }
        let data = ["logDate":dateString,"record":"\(dict)"] as [String : Any]
        
        return data
    }
    
    
    
    func scheduleRepeatingNotification() {
        
        
        let remaingIntak = defaultGoal - todayTotalLiter
        
        let formattedValue = String(format: "%.2f", remaingIntak)
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "you are \(formattedValue)Ltrs behind your set goal"
        content.sound = .default
        
        // Create a trigger to fire the notification every 10 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "repeatingReminder", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Repeating notification scheduled successfully.")
            }
        }
    }
    
    //MARK: -------------------- Action Methods --------------------
    
    
    @IBAction func Ml200Btn(_ sender: UIButton) {
        
        var currentML = unitsSold[posToday]
        currentML = currentML + 0.2
        
        unitsSold[posToday] = currentML
        setBarChart(dataPoints: months, values: unitsSold)
        mlArr.append("200 ML")
        timeArr.append(Helper().getCurrentTime())
        updateCoreData(logDate: selectedDate)
        tableView.reloadData()
        
    }
    
    @IBAction func Ml500Btn(_ sender: UIButton) {
        
        var currentML = unitsSold[posToday]
        currentML = currentML + 0.5
        
        unitsSold[posToday] = currentML
        setBarChart(dataPoints: months, values: unitsSold)
        mlArr.append("500 ML")
        timeArr.append(Helper().getCurrentTime())
        updateCoreData(logDate: selectedDate)
        tableView.reloadData()
        
    }
    
    @IBAction func Ml750Btn(_ sender: UIButton) {
        
        var currentML = unitsSold[posToday]
        currentML = currentML + 0.75
        
        unitsSold[posToday] = currentML
        setBarChart(dataPoints: months, values: unitsSold)
        mlArr.append("750 ML")
        timeArr.append(Helper().getCurrentTime())
        updateCoreData(logDate: selectedDate)
        tableView.reloadData()
        
    }
    
    @IBAction func l1Btn(_ sender: UIButton) {
        
        var currentML = unitsSold[posToday]
        currentML = currentML + 1.0
        
        unitsSold[posToday] = currentML
        setBarChart(dataPoints: months, values: unitsSold)
        mlArr.append("1000 ML")
        timeArr.append(Helper().getCurrentTime())
        updateCoreData(logDate: selectedDate)
        tableView.reloadData()
    }
    
}

//MARK: -------------------- Extension Calendar --------------------


extension ViewController : FSCalendarDelegate,FSCalendarDataSource,UIGestureRecognizerDelegate{
    
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return minimumDate//Calendar.current.date(byAdding: .month, value: -1, to: Date())! // set the minimum date you want
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: Date())!//Date() // set the maximum date you want
    }
    
    // FSCalendarDelegate methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Selected date: \(date)")
        selectedDate = date
        updateDate(date: selectedDate)
        fetchCoreData(dateLog: selectedDate)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func customizeCalendarAppearance() {
        // Customize font size
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18)
        
        // Customize spacing
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.weekdayTextColor = .darkGray
        
        // Set event dot color and offset
        calendar.appearance.eventDefaultColor = .blue
        calendar.appearance.eventOffset = CGPoint(x: 0, y: 2)
        
        // Set header title and weekday text colors
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        
        // Set today and selection color
       // calendar.appearance.todayColor = .clear
        let customColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        calendar.appearance.selectionColor = customColor
    }
    
    private func setCalendarHeight(height: CGFloat) {
        if let heightConstraint = calendar.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = height
        } else {
            // Add height constraint programmatically if not set in storyboard
            calendar.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

//MARK: -------------------- Extension TableView --------------------

extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mlArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordDataCell", for: indexPath) as! RecordDataCell
        
        cell.lblML.text = mlArr.reversed()[indexPath.row]
        cell.lblTime.text = timeArr.reversed()[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from the data source
            mlArr.remove(at: indexPath.row)
            timeArr.remove(at: indexPath.row)
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateCoreData(logDate: selectedDate)
        }
    }
}


