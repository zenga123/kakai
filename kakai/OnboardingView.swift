//
//  OnboardingView.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var relationship: RelationshipModel
    @Binding var isSetupComplete: Bool
    
    // 온보딩 단계
    @State private var onboardingStep = 0
    
    // 사용자 입력 값
    @State private var userName: String = ""
    @State private var partnerName: String = ""
    @State private var startDate: Date = Date()
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.9, green: 0.7, blue: 0.7), Color(red: 0.5, green: 0.0, blue: 0.3)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // 단계별 내용
                switch onboardingStep {
                case 0:
                    userNameStep
                case 1:
                    partnerNameStep
                case 2:
                    dateSelectionStep
                default:
                    EmptyView()
                }
                
                Spacer()
                
                // 다음 버튼
                Button(action: {
                    nextStep()
                }) {
                    Text("다음")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(getButtonColor())
                        .cornerRadius(25)
                }
                .disabled(!canProceed())
                .padding(.bottom, 50)
            }
        }
    }
    
    // 사용자 이름 입력 단계
    var userNameStep: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("본인의 이름을 알려주세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 20)
            
            TextField("", text: $userName)
                .font(.title3)
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.pink, lineWidth: 2)
                )
                .overlay(
                    HStack {
                        if userName.isEmpty {
                            Text("이름 입력")
                                .foregroundColor(.pink.opacity(0.8))
                                .padding(.leading, 16)
                        }
                        Spacer()
                    }
                )
        }
        .padding(.horizontal, 40)
    }
    
    // 파트너 이름 입력 단계
    var partnerNameStep: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("연인의 이름을 알려주세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 20)
            
            TextField("", text: $partnerName)
                .font(.title3)
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.pink, lineWidth: 2)
                )
                .overlay(
                    HStack {
                        if partnerName.isEmpty {
                            Text("이름 입력")
                                .foregroundColor(.pink.opacity(0.8))
                                .padding(.leading, 16)
                        }
                        Spacer()
                    }
                )
        }
        .padding(.horizontal, 40)
    }
    
    var dateSelectionStep: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("사귄 날짜를 알려주세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 20)
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    
                    // 날짜 선택기 - 년/월/일
                    HStack(spacing: 0) {
                        // 연도 선택
                        VStack {
                            Text("연도")
                                .font(.headline)
                                .foregroundColor(.pink)
                                .padding(.bottom, 5)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.pink.opacity(0.1))
                                    .frame(height: 120)
                                
                                Picker("연도", selection: Binding<Int>(
                                    get: { Calendar.current.component(.year, from: self.startDate) },
                                    set: { newYear in
                                        let calendar = Calendar.current
                                        var components = calendar.dateComponents([.year, .month, .day], from: self.startDate)
                                        components.year = newYear
                                        if let newDate = calendar.date(from: components) {
                                            self.startDate = newDate
                                        }
                                    }
                                )) {
                                    ForEach(2000...2030, id: \.self) { year in
                                        Text("\(year)년")
                                            .tag(year)
                                            .foregroundColor(.black)
                                            .font(.headline)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 100, height: 120)
                                .clipped()
                            }
                        }
                        .padding(.horizontal, 5)
                        
                        // 월 선택
                        VStack {
                            Text("월")
                                .font(.headline)
                                .foregroundColor(.pink)
                                .padding(.bottom, 5)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.pink.opacity(0.1))
                                    .frame(height: 120)
                                
                                Picker("월", selection: Binding<Int>(
                                    get: { Calendar.current.component(.month, from: self.startDate) },
                                    set: { newMonth in
                                        let calendar = Calendar.current
                                        var components = calendar.dateComponents([.year, .month, .day], from: self.startDate)
                                        components.month = newMonth
                                        if let newDate = calendar.date(from: components) {
                                            self.startDate = newDate
                                        }
                                    }
                                )) {
                                    ForEach(1...12, id: \.self) { month in
                                        Text("\(month)월")
                                            .tag(month)
                                            .foregroundColor(.black)
                                            .font(.headline)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 80, height: 120)
                                .clipped()
                            }
                        }
                        .padding(.horizontal, 5)
                        
                        // 일 선택
                        VStack {
                            Text("일")
                                .font(.headline)
                                .foregroundColor(.pink)
                                .padding(.bottom, 5)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.pink.opacity(0.1))
                                    .frame(height: 120)
                                
                                Picker("일", selection: Binding<Int>(
                                    get: { Calendar.current.component(.day, from: self.startDate) },
                                    set: { newDay in
                                        let calendar = Calendar.current
                                        var components = calendar.dateComponents([.year, .month, .day], from: self.startDate)
                                        components.day = newDay
                                        if let newDate = calendar.date(from: components) {
                                            self.startDate = newDate
                                        }
                                    }
                                )) {
                                    ForEach(1...31, id: \.self) { day in
                                        Text("\(day)일")
                                            .tag(day)
                                            .foregroundColor(.black)
                                            .font(.headline)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 80, height: 120)
                                .clipped()
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.vertical, 20)
                }
                .frame(height: 220)
            }
            .padding(.horizontal, 10)
        }
        .padding(.horizontal, 40)
    }
    
    // 버튼 색상 (활성화 여부에 따라)
    private func getButtonColor() -> Color {
        if canProceed() {
            return Color.pink
        } else {
            return Color.gray
        }
    }
    
    // 현재 단계에서 진행 가능한지 확인
    private func canProceed() -> Bool {
        switch onboardingStep {
        case 0:
            return !userName.isEmpty
        case 1:
            return !partnerName.isEmpty
        case 2:
            return true
        default:
            return false
        }
    }
    
    // 다음 단계로 진행
    private func nextStep() {
        if onboardingStep < 2 {
            onboardingStep += 1
        } else {
            // 모든 단계 완료 - 데이터 저장 및 메인 화면으로 이동
            saveAndContinue()
        }
    }
    
    // 데이터 저장 및 메인 화면으로 이동
    private func saveAndContinue() {
        relationship.userName = userName
        relationship.partnerName = partnerName
        relationship.relationshipStartDate = startDate
        isSetupComplete = true
    }
}

#Preview {
    OnboardingView(isSetupComplete: .constant(false))
        .environmentObject(RelationshipModel())
}
