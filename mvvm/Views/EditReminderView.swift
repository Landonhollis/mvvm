//
//  EditReminderView.swift
//  mvvm
//
//  Created by Landon Hollis on 2/2/25.
//

import SwiftUI

struct EditReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TaskViewModel
    
    // Existing reminder to edit
    let reminder: ReminderTask
    
    // State variables initialized with existing reminder data
    @State private var reminderName: String
    @State private var selectedUrgency: ReminderUrgency
    
    // Date picker states
    @State private var isDateEnabled: Bool
    @State private var selectedMonth: Int
    @State private var selectedDay: Int
    
    // Time picker states
    @State private var isTimeEnabled: Bool
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    
    init(reminder: ReminderTask) {
        self.reminder = reminder
        
        // Initialize state variables with reminder data
        _reminderName = State(initialValue: reminder.priorityName)
        _selectedUrgency = State(initialValue: reminder.reminderUrgency)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: reminder.reminderDate)
        
        _selectedMonth = State(initialValue: components.month ?? Calendar.current.component(.month, from: Date()))
        _selectedDay = State(initialValue: components.day ?? Calendar.current.component(.day, from: Date()))
        _selectedHour = State(initialValue: components.hour ?? Calendar.current.component(.hour, from: Date()))
        _selectedMinute = State(initialValue: components.minute ?? Calendar.current.component(.minute, from: Date()))
        
        // Initialize toggles (true if component exists)
        _isDateEnabled = State(initialValue: components.month != nil || components.day != nil)
        _isTimeEnabled = State(initialValue: components.hour != nil || components.minute != nil)
    }
    
    var body: some View {
        // Reuse the same layout as AddReminderView
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Header with Cancel and Save buttons
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("LinesAndTextColor"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color("AppSecondaryColor"))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveEditedReminder()
                    }
                    .foregroundColor(Color("LinesAndTextColor"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color("AppSecondaryColor"))
                    .cornerRadius(20)
                }
                .padding()
                
                // Reminder Name Field
                TextField("Name of reminder", text: $reminderName)
                    .font(.title)
                    .foregroundColor(Color("LinesAndTextColor"))
                    .padding()
                    .background(Color("AppSecondaryColor"))
                    .cornerRadius(20)
                    .padding(.horizontal)
                
                // Date Section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Date:")
                            .font(.title)
                            .foregroundColor(Color("LinesAndTextColor"))
                        
                        Toggle("", isOn: $isDateEnabled)
                            .labelsHidden()
                            .tint(Color("AddButtonColor"))
                    }
                    .padding(.horizontal)
                    
                    if isDateEnabled {
                        HStack(spacing: 20) {
                            // Month Picker
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text(monthName(month))
                                }
                            }
                            .pickerStyle(.wheel)
                            
                            // Day Picker
                            Picker("Day", selection: $selectedDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)")
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(height: 100)
                    }
                }
                
                // Time Section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Time:")
                            .font(.title)
                            .foregroundColor(Color("LinesAndTextColor"))
                        
                        Toggle("", isOn: $isTimeEnabled)
                            .labelsHidden()
                            .tint(Color("AddButtonColor"))
                    }
                    .padding(.horizontal)
                    
                    if isTimeEnabled {
                        HStack(spacing: 20) {
                            // Hour Picker
                            Picker("Hour", selection: $selectedHour) {
                                ForEach(0...23, id: \.self) { hour in
                                    Text("\(hour)")
                                }
                            }
                            .pickerStyle(.wheel)
                            
                            // Minute Picker
                            Picker("Minute", selection: $selectedMinute) {
                                ForEach(0...59, id: \.self) { minute in
                                    Text("\(minute)")
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(height: 100)
                    }
                }
                
                // Urgency Section
                VStack(alignment: .leading) {
                    Text("Urgency:")
                        .font(.title)
                        .foregroundColor(Color("LinesAndTextColor"))
                        .padding(.horizontal)
                    
                    VStack(spacing: 10) {
                        ForEach(ReminderUrgency.allCases, id: \.self) { urgency in
                            Button(action: { selectedUrgency = urgency }) {
                                Text(urgencyText(urgency))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(urgencyColor(urgency))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color("LinesAndTextColor"), lineWidth: selectedUrgency == urgency ? 2 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Reuse helper functions from AddReminderView
    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.monthSymbols[month - 1]
    }
    
    private func urgencyText(_ urgency: ReminderUrgency) -> String {
        switch urgency {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Very High"
        }
    }
    
    private func urgencyColor(_ urgency: ReminderUrgency) -> Color {
        switch urgency {
        case .low: return Color("UrgencyLevelOneColor")
        case .medium: return Color("UrgencyLevelTwoColor")
        case .high: return Color("UrgencyLevelThreeColor")
        case .critical: return Color("UrgencyLevelFourColor")
        }
    }
    
    private func saveEditedReminder() {
        var components = DateComponents()
        
        if isDateEnabled {
            components.month = selectedMonth
            components.day = selectedDay
        }
        
        if isTimeEnabled {
            components.hour = selectedHour
            components.minute = selectedMinute
        }
        
        let reminderDate = isDateEnabled || isTimeEnabled ?
            Calendar.current.date(from: components) ?? Date() :
            Date()
        
        let editedReminder = ReminderTask(
            id: reminder.id, // Keep the same ID
            priorityName: reminderName,
            reminderDate: reminderDate,
            reminderUrgency: selectedUrgency
        )
        
        viewModel.updateReminderTask(editedReminder)
        dismiss()
    }
}

#Preview {
    EditReminderView(reminder: ReminderTask(
        priorityName: "Sample Reminder",
        reminderDate: Date(),
        reminderUrgency: .medium
    ))
    .environmentObject(TaskViewModel())
}

