import Foundation

class TaskViewModel: ObservableObject {
    @Published var reminderTasks: [ReminderTask] = []
    @Published var noteTasks: [NoteTask] = []
    
    // MARK: - Reminder Task Methods
    func addReminderTask(_ task: ReminderTask) {
        reminderTasks.append(task)
        sortRemindersByDate()
        saveReminderTasks()
    }
    
    func deleteReminderTask(at indexSet: IndexSet) {
        reminderTasks.remove(atOffsets: indexSet)
        saveReminderTasks()
    }
    
    func updateReminderTask(_ task: ReminderTask) {
        if let index = reminderTasks.firstIndex(where: { $0.id == task.id }) {
            reminderTasks[index] = task
            sortRemindersByDate()
            saveReminderTasks()
        }
    }
    
    // MARK: - Date Handling Methods
    private func sortRemindersByDate() {
        reminderTasks.sort { $0.reminderDate < $1.reminderDate }
    }
    
    func isReminderOverdue(_ task: ReminderTask) -> Bool {
        return task.reminderDate < Date()
    }
    
    func formatReminderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func upcomingReminders() -> [ReminderTask] {
        let now = Date()
        return reminderTasks.filter { $0.reminderDate > now }
            .sorted { $0.reminderDate < $1.reminderDate }
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
    
    func updateNoteTask(_ task: NoteTask) {
        if let index = noteTasks.firstIndex(where: { $0.id == task.id }) {
            noteTasks[index] = task
            saveNoteTasks()
        }
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
            sortRemindersByDate()
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