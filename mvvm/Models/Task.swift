import Foundation

enum ReminderUrgency: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
}

enum ReminderMonth: String, CaseIterable {
    case january = "January"
    case february = "February"
    case march = "March"
    case april = "April"
    case may = "May"
    case june = "June"
    case july = "July"
    case august = "August"
    case september = "September"
    case october = "October"
    case november = "November"
    case december = "December"
}

struct ReminderTask: Identifiable, Codable {
    var id: UUID = UUID()
    var priorityName: String
    var reminderTimeMonth: ReminderMonth
    var reminderTimeDay: Int
    var reminderTimeHour: Int
    var reminderTimeMinute: Int
    var reminderUrgency: ReminderUrgency
}

struct NoteTask: Identifiable, Codable {
    var id: UUID = UUID()
    var noteName: String
    var noteText: String
} 