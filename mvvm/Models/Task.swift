import Foundation

enum ReminderUrgency: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
}

struct ReminderTask: Identifiable, Codable {
    var id: UUID = UUID()
    var priorityName: String
    var reminderDate: Date
    var reminderUrgency: ReminderUrgency
}

struct NoteTask: Identifiable, Codable {
    var id: UUID = UUID()
    var noteName: String
    var noteText: String
} 