import Foundation
import UserNotifications
import SwiftUI

class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for reminder: ReminderTask) {
        // Don't schedule if date is in the past
        guard reminder.reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.priorityName
        content.sound = .default
        
        // Add the urgency color as a tag in the notification for visual indication
        content.userInfo = ["urgencyLevel": reminder.reminderUrgency.rawValue]
        
        // Create a unique identifier for the notification using the reminder's ID
        let identifier = reminder.id.uuidString
        
        // Create date components for the trigger
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.reminderDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeScheduledNotification(for reminder: ReminderTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reminder.id.uuidString]
        )
    }
    
    func updateNotification(for reminder: ReminderTask) {
        // Remove existing notification and schedule new one
        removeScheduledNotification(for: reminder)
        scheduleNotification(for: reminder)
    }
    
    // Handle notifications when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    // Get urgency color for notification
    func getUrgencyColor(_ urgencyLevel: Int) -> Color {
        guard let urgency = ReminderUrgency(rawValue: urgencyLevel) else {
            return Color("UrgencyLevelTwoColor") // Default to medium if unknown
        }
        
        switch urgency {
        case .low:
            return Color("UrgencyLevelOneColor")
        case .medium:
            return Color("UrgencyLevelTwoColor")
        case .high:
            return Color("UrgencyLevelThreeColor")
        case .critical:
            return Color("UrgencyLevelFourColor")
        }
    }
} 