import Foundation

class TaskViewModel: ObservableObject {
    @Published var reminderTasks: [ReminderTask] = []
    @Published var noteTasks: [NoteTask] = []
    
    // MARK: - Reminder Task Methods
    func addReminderTask(_ task: ReminderTask) {
        reminderTasks.append(task)
        saveReminderTasks()
    }
    
    func deleteReminderTask(at indexSet: IndexSet) {
        reminderTasks.remove(atOffsets: indexSet)
        saveReminderTasks()
    }
    
    // MARK: - Note Task Methods
    func addNoteTask(_ task: NoteTask) {
        noteTasks.append(task)
        saveNoteTasks()
    }
    
    func deleteNoteTask(at indexSet: IndexSet) {
        noteTasks.remove(atOffsets: indexSet)
        saveNoteTasks()
    }
    
    // MARK: - Persistence
    private func saveReminderTasks() {
        if let encoded = try? JSONEncoder().encode(reminderTasks) {
            UserDefaults.standard.set(encoded, forKey: "reminderTasks")
        }
    }
    
    private func saveNoteTasks() {
        if let encoded = try? JSONEncoder().encode(noteTasks) {
            UserDefaults.standard.set(encoded, forKey: "noteTasks")
        }
    }
    
    private func loadTasks() {
        if let reminderData = UserDefaults.standard.data(forKey: "reminderTasks"),
           let decodedReminders = try? JSONDecoder().decode([ReminderTask].self, from: reminderData) {
            reminderTasks = decodedReminders
        }
        
        if let noteData = UserDefaults.standard.data(forKey: "noteTasks"),
           let decodedNotes = try? JSONDecoder().decode([NoteTask].self, from: noteData) {
            noteTasks = decodedNotes
        }
    }
    
    init() {
        loadTasks()
    }
} 