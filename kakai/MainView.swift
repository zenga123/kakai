//
//  MainView.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var relationship: RelationshipModel
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            HStack {
                Text("\(relationship.userName) & \(relationship.partnerName)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.pink)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 250, height: 250)
                
                VStack(spacing: 8) {
                    Text("함께한 시간")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(relationship.daysTogether)일")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 20)
            
            if let nextDate = relationship.nextMeetingDate, let daysUntil = relationship.daysUntilNextMeeting {
                VStack(spacing: 15) {
                    Text("다음 만남까지")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 5) {
                        Text("\(daysUntil)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.pink)
                        
                        Text("일 남음")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Text(formatDate(nextDate))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.pink.opacity(0.1))
                .cornerRadius(15)
                .padding(.top, 30)
            } else {
                Button(action: {
                    showingDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("다음 만남 날짜 추가하기")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding(.top, 40)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingDatePicker) {
            VStack {
                HStack {
                    Button("취소") {
                        showingDatePicker = false
                    }
                    
                    Spacer()
                    
                    Button("저장") {
                        relationship.nextMeetingDate = selectedDate
                        relationship.saveData() // 데이터 저장
                        showingDatePicker = false
                    }
                }
                .padding()
                
                DatePicker("다음 만남 날짜", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                Spacer()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    MainView()
        .environmentObject(RelationshipModel())
}
