//
//  MyAlarm.swift
//  TwoMinuteWarning
//
//  Created by Zach Zhong on 06/10/2017.
//  Copyright © 2017 Rob Fitzgerald, Inc. All rights reserved.
//

import UIKit
import UserNotifications

class MyAlarm {
    // Current date
    let year = Calendar.current.component(.year, from: Date())
    let month = Calendar.current.component(.month, from: Date())
    let day = Calendar.current.component(.day, from: Date())
    let regularSchedule: [Int: String] = [0: "8:30", 1: "9:22", 2: "10:18", 3: "11:14", 4: "12:10", 5: "13:41", 6: "14:37", 7: "15:33"]
    let lateStartSchedule: [Int: String] = [0: "9:50", 1: "10:24", 2: "11:02", 3: "11:40", 4: "12:18", 5: "13:31", 6: "14:09", 7: "14:47"]
    let extendedLunchSchedule: [Int: String] = [0: "8:30", 1: "9:18", 2: "10:10", 3: "11:02", 4: "11:54", 5: "13:49", 6: "14:41", 7: "15:33"]
    let finalExamScheduleFirstDay: [Int: String] = [0: "8:30", 1: "10:30", 2: "11:19", 3: "11:58", 4: "12:37", 5: "13:51", 6: "14:30", 7: "15:09"]
    let rallySchedule: [Int: String] = [0: "8:30", 1: "9:15", 2: "10:04", 3: "10:53", 4: "12:31", 5: "13:55", 6: "14:44", 7: "15:33"]
    let minimumSchedule: [Int: String] = [0: "8:30", 1: "9:00", 2: "9:34", 3: "10:08", 4: "10:52", 5: "11:26", 6: "12:00", 7: "12:34"]

    let userCalender = Calendar.current
    // data.append(ScheduleModel(scheduleName: "Rally", period0: "7:45-8:37", period1: "8:42-9:34", period2: "9:39-10:31", period3: "10:31", breakPeriod: "10:31-10:41", period4: "10:46-11:38", period5: "11:43-12:35", lunch: "12:35-1:10", period6: "1:15-2:07", period7: "2:12-3:04", date: "My Date"))

    
    func setNotification(for scheduleNamed:String) {
        
        // Get the current year, month, and day
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // Create var to hold the the scheduele
        var regularSchedule: ScheduleModel!
        var rallySchedule: ScheduleModel!
        var lateStartSchedule: ScheduleModel!
        
        // Loop through the data to extract the schedule
        for schedule in Data.getData() {
            
            switch schedule.scheduleName {
                
            case "Regular":
                
                regularSchedule = schedule
                
            case "Rally":
                
                rallySchedule = schedule
                
            case "Late Start":
                
                lateStartSchedule = schedule
                
            default:
                
                print("\(schedule.scheduleName) not found")
            }
        }
        
        switch scheduleNamed {
        case "Regular":
            // Set Regular Schedule Notifications
            for (period, time) in regularSchedule.currentSchedule {
                
                createNotif(year: year, month: month, day: day, hour: time.hour!, minute: time.minute!, identifier: "\(period)\(time)", content: "Period \(period) of \(regularSchedule.scheduleName) is about to end in 2 minutes")
            }
            print("Regular Schedule Set")
        case "Rally":
            // Loop through each dictionaries of schedule in the scheduleModel
            for (period, time) in rallySchedule.currentSchedule {
                
                createNotif(year: year, month: month, day: day, hour: time.hour!, minute: time.minute!, identifier: "\(period)\(time)", content: "Period \(period) of \(rallySchedule.scheduleName) is about to end in 2 minutes")
            }
            print("Rally Schedule Set")
        case "Late Start":
            // Loop theough each dictionaries of schedule in the scheduleModel
            for (period, time) in lateStartSchedule.currentSchedule {
                createNotif(year: year, month: month, day: day, hour: time.hour!, minute: time.minute!, identifier: "\(period)\(time)", content: "Period \(period) of \(lateStartSchedule.scheduleName) is about to end in 2 minutes")
            }
            print("Late Start Schedule Set")
        case "Minimum":
            // Set Regular Schedule Notifications
            print("Minimum Schedule Set")
        case "Final Exam":
            // Set Regular Schedule Notifications
            print("Final Exam (Day 1) Schedule Set")
        case "Extended Lunch":
            // Set Regular Schedule Notifications
            print("Extended Lunch Schedule Set")
        default:
            print("this is the default setting")
        }
    }
    func createNotif(year: Int, month: Int, day: Int, hour: Int, minute: Int, identifier: String, content: String) {

        // Set up dates
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        dateComponent.hour = hour
        dateComponent.minute = minute - 3

        // Set up triger, content, id
        let myAlarmTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let myAlarmID = identifier
        let myAlarmContent = UNMutableNotificationContent()
        myAlarmContent.body = content
        myAlarmContent.sound = UNNotificationSound.default()
        

        let request = UNNotificationRequest(identifier: myAlarmID, content: myAlarmContent, trigger: myAlarmTrigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                // TODO: Handle the error
            }
        })
    }

    func getDifferenceInSeconds(from date: DateComponents, to date2: DateComponents) -> Int {

        return date.seconds(from: date2)
    }

    func clearNotification() {

        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }

    // This turn the schedule into the right format so it can be easier when we set up the notification
    func turnDatesIntoDateComponet(scheduleDictionary: [Int: String]) -> [Int: DateComponents] {

        var result = [Int: DateComponents]()
        for (period, date) in scheduleDictionary {

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "H:mm"
            let formattedDate = dateFormatter.date(from: date)
            let calenderComponet = userCalender.dateComponents([.hour, .minute], from: formattedDate!)
            result[period] = calenderComponet
        }
        return result
    }

    func getDateComponentsInOrder(scheduleDictionary: [Int: String]) -> [DateComponents] {
        var result = [DateComponents]()
        for (_, date) in scheduleDictionary {

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "H:mm"
            let formattedDate = dateFormatter.date(from: date)
            let calenderComponet = userCalender.dateComponents([.hour, .minute, .calendar], from: formattedDate!)

            let finalDateComponent = setDateComponentToToday(date: calenderComponet)

            if finalDateComponent.date!.timeIntervalSinceNow.isLessThanOrEqualTo(0) {

            } else {

                result.append(finalDateComponent)
            }
        }

        result = result.sorted(by: { $0.date!.timeIntervalSinceNow < $1.date!.timeIntervalSinceNow })

        return result
    }

    func getTimeUntilNextPeriod(schedule: String) -> TimeInterval {

        var timeInt = TimeInterval()

        // Set up the formatter to read dates like 15:03
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"

        switch schedule {

        case "Regular":

            timeInt = getTimeUntilNextPeriod(scheduleDictionary: regularSchedule)

        case "Late Start":

            timeInt = getTimeUntilNextPeriod(scheduleDictionary: lateStartSchedule)

        case "Extended Lunch":

            timeInt = getTimeUntilNextPeriod(scheduleDictionary: extendedLunchSchedule)

        case "Final Exam":

            timeInt = getTimeUntilNextPeriod(scheduleDictionary: finalExamScheduleFirstDay)

        case "Rally":

            timeInt = getTimeUntilNextPeriod(scheduleDictionary: rallySchedule)

        case "Minimum Day":

            timeInt = getTimeUntilNextPeriod(scheduleDictionary: minimumSchedule)

        default:
            print("\(schedule) is not a valid schedule")
        }

        return timeInt
    }

    func setDateComponentToToday(date: DateComponents) -> DateComponents {

        var newDate = date
        newDate.day = day
        newDate.month = month
        newDate.year = year

        return newDate
    }

    private func getTimeUntilNextPeriod(scheduleDictionary: [Int: String]) -> TimeInterval {
        
        // Create time component
        let componentsArray = getDateComponentsInOrder(scheduleDictionary: scheduleDictionary)
        
        // Sort the array so the least time remaining will appear first
        let newArray = componentsArray.sorted(by: { $0.date!.timeIntervalSinceNow < $1.date!.timeIntervalSinceNow })

        if newArray.count == 0 {

            return 0
        }
        // The first one in the array will be next period
        return newArray[0].date!.timeIntervalSinceNow
    }


    func getScheduleFrom(name: String) -> ScheduleModel?{
        
        
        // Loop through the data to extract the schedule
        for schedule in Data.getData() {
            
            if schedule.scheduleName == name{
            return schedule
                
            }
    }
        
        
        return nil;
    }


}

// Returns the difference between two date
extension DateComponents {

    func seconds(from date: DateComponents) -> Int {
        return abs(Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0)
    }
}

