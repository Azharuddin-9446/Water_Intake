//
//  AppDelegate.swift
//  Goqii Task
//
//  Created by MacBook Pro on 13/12/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                 if granted {
                     print("Notification permission granted.")
                 } else if let error = error {
                     print("Notification permission denied: \(error.localizedDescription)")
                 }
             }
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when the app is in the foreground
        completionHandler([.alert, .sound, .badge])
    }

    // Handle notification when user interacts with it
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification action
        print("User interacted with the notification")
        completionHandler()
    }

    
    // MARK: - Core Data stack

        lazy var persistentContainer: NSPersistentContainer = {
            /*
             The persistent container for the application. This implementation
             creates and returns a container, having loaded the store for the
             application to it. This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
            */
            let container = NSPersistentContainer(name: "waterLog")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                     
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()

        // MARK: - Core Data Saving support

        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }

    }



//
//
//import UIKit
//import FSCalendar
//import Charts
//
//
//
//class ViewController: UIViewController {
//    
//    
//    //MARK: -------------------- Outlet --------------------
//    
//    @IBOutlet weak var calendar: FSCalendar!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var chartView: MarkerView!
//    
//    //MARK: -------------------- Class Variable --------------------
//    
//    fileprivate lazy var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd"
//        return formatter
//    }()
//    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
//        [unowned self] in
//        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
//        panGesture.delegate = self
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.maximumNumberOfTouches = 2
//        return panGesture
//    }()
//    
//    //MARK: -------------------- Life Cycle Method --------------------
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        calendar.delegate = self
//        calendar.dataSource = self
//        tableView.delegate = self
//        tableView.dataSource = self
//       
//        configureUI()
//        
//        customizeCalendarAppearance()
//    
//    }
//    deinit {
//        print("\(#function)")
//    }
//    
//    //MARK: -------------------- Custom Methods --------------------
//    
//    @MainActor
//    func configureUI() {
//        
//        if UIDevice.current.model.hasPrefix("iPad") {
//            self.calendarHeightConstraint.constant = 400
//        }
//        
//        self.calendar.select(Date())
//        
//        self.view.addGestureRecognizer(self.scopeGesture)
//        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
//        self.calendar.scope = .week
//        
//        // For UITest
//        self.calendar.accessibilityIdentifier = "calendar"
//        calendar.scope = .week
//        calendar.tintColor = UIColor.black
//        
//    }
//    
//    func customizeCalendarAppearance() {
//        // Customize font size
//        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16)
//        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
//        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18)
//        
//        // Customize spacing
//        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
//        calendar.appearance.titleDefaultColor = .black
//        calendar.appearance.weekdayTextColor = .darkGray
//        
//        // Set event dot color and offset
//        calendar.appearance.eventDefaultColor = .blue
//        calendar.appearance.eventOffset = CGPoint(x: 0, y: 2)
//        
//        // Set header title and weekday text colors
//        calendar.appearance.headerTitleColor = .black
//        calendar.appearance.weekdayTextColor = .black
//        
//        // Set today and selection color
//        calendar.appearance.todayColor = .black
//        calendar.appearance.selectionColor = .blue
//    }
//    
//    private func setCalendarHeight(height: CGFloat) {
//        if let heightConstraint = calendar.constraints.first(where: { $0.firstAttribute == .height }) {
//            heightConstraint.constant = height
//        } else {
//            // Add height constraint programmatically if not set in storyboard
//            calendar.heightAnchor.constraint(equalToConstant: height).isActive = true
//        }
//    }
//    
//    
//}
//
//extension ViewController : FSCalendarDelegate,FSCalendarDataSource,UIGestureRecognizerDelegate{
//    
//    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
//        if shouldBegin {
//            let velocity = self.scopeGesture.velocity(in: self.view)
//            switch self.calendar.scope {
//            case .month:
//                return velocity.y < 0
//            case .week:
//                return velocity.y > 0
//            }
//        }
//        return shouldBegin
//    }
//    
//    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
//        self.calendarHeightConstraint.constant = bounds.height
//        self.view.layoutIfNeeded()
//    }
//    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        print("did select date \(self.dateFormatter.string(from: date))")
//        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
//        print("selected dates is \(selectedDates)")
//        if monthPosition == .next || monthPosition == .previous {
//            calendar.setCurrentPage(date, animated: true)
//        }
//    }
//
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//        print("\(self.dateFormatter.string(from: calendar.currentPage))")
//    }
//    
//    
//}
//
//extension ViewController : UITableViewDelegate,UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
//        return cell
//        
//    }
//    
//    
    
    
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if indexPath.section == 0 {
//            let scope: FSCalendarScope = (indexPath.row == 0) ? .month : .week
//           // self.calendar.setScope(scope, animated: self.animationSwitch.isOn)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10
//    }
//
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return [2,20][section]
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let identifier = ["cell_month", "cell_week"][indexPath.row]
//            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
//            return cell
//        }
//    }
//}
