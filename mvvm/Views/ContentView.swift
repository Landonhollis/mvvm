import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var showingAddMenu = false
    @State private var showingNoteView = false
    @State private var showingReminderView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("R/N")
                            .font(.title)
                            .foregroundColor(Color("LinesAndTextColor"))
                        
                        Spacer()
                        
                        Button(action: { isDarkMode.toggle() }) {
                            Text(isDarkMode ? "Dark Mode" : "Light Mode")
                                .foregroundColor(Color("LinesAndTextColor"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color("SecondaryColor"))
                                .cornerRadius(20)
                        }
                    }
                    .padding()
                    
                    // Add Button
                    Button(action: {
                        showingAddMenu = true
                    }) {
                        HStack {
                            Text("Add")
                                .font(.title2)
                            Image(systemName: "plus")
                        }
                        .foregroundColor(Color("BackgroundColor"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AddButtonColor"))
                        .cornerRadius(25)
                        .padding(.horizontal)
                    }
                    
                    // Reminders Section
                    VStack(alignment: .leading) {
                        Text("Reminders")
                            .font(.title2)
                            .foregroundColor(Color("LinesAndTextColor"))
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(viewModel.reminderTasks) { reminder in
                                    ReminderRow(reminder: reminder)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 250)
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading) {
                        Text("Notes")
                            .font(.title2)
                            .foregroundColor(Color("LinesAndTextColor"))
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(viewModel.noteTasks) { note in
                                    NoteCard(note: note)
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                // Add Menu Popup
                if showingAddMenu {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingAddMenu = false
                        }
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            showingReminderView = true
                            showingAddMenu = false
                        }) {
                            Text("Reminder")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color("LinesAndTextColor"))
                        }
                        .background(Color("BackgroundColor"))
                        
                        Divider()
                            .background(Color("LinesAndTextColor"))
                        
                        Button(action: {
                            showingNoteView = true
                            showingAddMenu = false
                        }) {
                            Text("Note")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color("LinesAndTextColor"))
                        }
                        .background(Color("BackgroundColor"))
                        
                        Divider()
                            .background(Color("LinesAndTextColor"))
                        
                        Button(action: {
                            showingAddMenu = false
                        }) {
                            Text("Cancel")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color("LinesAndTextColor"))
                        }
                        .background(Color("BackgroundColor"))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    .transition(.scale)
                }
            }
        }
        .animation(.easeInOut, value: showingAddMenu)
        .sheet(isPresented: $showingNoteView) {
            NoteView()
        }
        .sheet(isPresented: $showingReminderView) {
            AddReminderView()
        }
    }
}

struct ReminderRow: View {
    let reminder: ReminderTask
    @EnvironmentObject private var viewModel: TaskViewModel
    
    var urgencyColor: Color {
        switch reminder.reminderUrgency {
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
    
    var body: some View {
        HStack {
            Text(reminder.priorityName)
                .foregroundColor(Color("LinesAndTextColor"))
            
            Spacer()
            
            Text(viewModel.formatReminderDate(reminder.reminderDate))
                .foregroundColor(Color("BackgroundColor"))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(urgencyColor)
                .cornerRadius(15)
        }
        .padding()
        .background(Color("SecondaryColor"))
        .cornerRadius(10)
    }
}

struct NoteCard: View {
    let note: NoteTask
    
    var body: some View {
        Text(note.noteText)
            .foregroundColor(Color("LinesAndTextColor"))
            .multilineTextAlignment(.center)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color("SecondaryColor"))
            .cornerRadius(15)
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskViewModel())
}
