//
//  Helper.swift
//  Goqii Task
//
//  Created by MacBook Pro on 14/12/24.
//

import Foundation


class Helper {
    
    static let shared = Helper()
    
    func getMinimumDate(dateString1: String, dateString2: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Match your date string format
       // dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date1 = dateFormatter.date(from: dateString1),
              let date2 = dateFormatter.date(from: dateString2) else {
            print("Invalid date format")
            return nil
        }
        
        // Compare dates and return the earlier one as a string
        let minimumDate = date1 < date2 ? dateString1 : dateString2
        return minimumDate
    }
    
    func getWeek(for dateString: String) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let selectedDate = dateFormatter.date(from: dateString) else {
            print("Invalid date format")
            return []
        }
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        
        var weekDates: [String] = []

        // Find the start of the week (Monday)
        var startOfWeek: Date?
        if calendar.component(.weekday, from: selectedDate) != 2 {
            startOfWeek = calendar.nextDate(after: selectedDate, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime, direction: .backward)
        } else {
            startOfWeek = selectedDate
        }
        
        // Adjust startOfWeek to previous Monday if it's not
        if let startOfWeek = startOfWeek {
            // Add each day of the week to the array
            for day in 0..<7 {
                if let weekDate = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                  //  let updatetedDate =  Calendar.current.date(byAdding: .day, value: 1, to: weekDate)!
                    let formattedDate = dateFormatter.string(from: weekDate)
                    weekDates.append(formattedDate)
                }
            }
        }
        
        return weekDates
    }
    func getDayName(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE" // "EEE" gives short day name, "EEEE" gives full day name
        let dayName = dateFormatter.string(from: date)
        return dayName
    }
    
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // "hh" for 12-hour format, "a" for AM/PM
        let currentTime = dateFormatter.string(from: Date())
        return currentTime
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
}
