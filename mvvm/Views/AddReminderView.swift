//
//  AddReminderView.swift
//  mvvm
//
//  Created by Landon Hollis on 2/2/25.
//

import SwiftUI

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TaskViewModel
    
    @State private var reminderName: String = ""
    @State private var selectedUrgency: ReminderUrgency = .medium
    
    // Date picker states
    @State private var isDateEnabled = true
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay = Calendar.current.component(.day, from: Date())
    
    // Time picker states
    @State private var isTimeEnabled = true
    @State private var selectedHour = Calendar.current.component(.hour, from: Date())
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    
    var body: some View {
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
                    .background(Color("SecondaryColor"))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveReminder()
                    }
                    .foregroundColor(Color("LinesAndTextColor"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color("SecondaryColor"))
                    .cornerRadius(20)
                }
                .padding()
                
                // Reminder Name Field
                TextField("Name of reminder", text: $reminderName)
                    .font(.title)
                    .foregroundColor(Color("LinesAndTextColor"))
                    .padding()
                    .background(Color("SecondaryColor"))
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
    
    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.monthSymbols[month - 1]
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
    
    private func saveReminder() {
        var components = DateComponents()
        
        if isDateEnabled {
            components.month = selectedMonth
            components.day = selectedDay
        }
        
        if isTimeEnabled {
            components.hour = selectedHour
            components.minute = selectedMinute
        }
        
        // If neither date nor time is enabled, use current date/time
        let reminderDate = isDateEnabled || isTimeEnabled ?
            Calendar.current.date(from: components) ?? Date() :
            Date()
        
        let reminder = ReminderTask(
            priorityName: reminderName,
            reminderDate: reminderDate,
            reminderUrgency: selectedUrgency
        )
        
        viewModel.addReminderTask(reminder)
        dismiss()
    }
}

#Preview {
    AddReminderView()
        .environmentObject(TaskViewModel())
}

