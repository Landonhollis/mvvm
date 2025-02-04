import Foundation

enum ReminderUrgency: Int, Codable, CaseIterable {
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
    
    // Add coding keys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case priorityName
        case reminderDate
        case reminderUrgency
    }
}

struct NoteTask: Identifiable, Codable {
    var id: UUID = UUID()
    var noteName: String
    var noteText: String
    var attributedText: NSAttributedString?
    var drawingData: Data?
    
    enum CodingKeys: String, CodingKey {
        case id, noteName, noteText, attributedText, drawingData
    }
    
    init(id: UUID = UUID(), noteName: String, noteText: String, attributedText: NSAttributedString? = nil, drawingData: Data? = nil) {
        self.id = id
        self.noteName = noteName
        self.noteText = noteText
        self.attributedText = attributedText
        self.drawingData = drawingData
    }
    
    // Custom encoding/decoding for NSAttributedString
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(noteName, forKey: .noteName)
        try container.encode(noteText, forKey: .noteText)
        if let attributedText = attributedText,
           let data = try? NSKeyedArchiver.archivedData(withRootObject: attributedText, requiringSecureCoding: false) {
            try container.encode(data, forKey: .attributedText)
        }
        if let drawingData = drawingData {
            try container.encode(drawingData, forKey: .drawingData)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        noteName = try container.decode(String.self, forKey: .noteName)
        noteText = try container.decode(String.self, forKey: .noteText)
        if let data = try? container.decode(Data.self, forKey: .attributedText),
           let attributed = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
            attributedText = attributed
        }
        drawingData = try? container.decode(Data.self, forKey: .drawingData)
    }
} 