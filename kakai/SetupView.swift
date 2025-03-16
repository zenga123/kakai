//
//  SetupView.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import SwiftUI

struct SetupView: View {
    @EnvironmentObject var relationship: RelationshipModel
    @Binding var isSetupComplete: Bool
    
    @State private var coupleNames: String = ""
    @State private var startDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("가까이")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.pink)
                .padding(.top, 50)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("커플 이름")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                TextField("예: 지민 & 수지", text: $coupleNames)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 20)
                
                Text("사귀기 시작한 날짜")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                saveAndContinue()
            }) {
                Text("다음")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(coupleNames.isEmpty ? Color.gray : Color.pink)
                    .cornerRadius(25)
            }
            .disabled(coupleNames.isEmpty)
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.pink.opacity(0.1)]),
                          startPoint: .top,
                          endPoint: .bottom)
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private func saveAndContinue() {
        // 커플 이름에서 사용자 이름과 파트너 이름 추출 시도
        let names = coupleNames.split(separator: "&").map { String($0.trimmingCharacters(in: .whitespaces)) }
        if names.count >= 2 {
            relationship.userName = names[0]
            relationship.partnerName = names[1]
        } else if !coupleNames.isEmpty {
            // 구분자가 없는 경우 전체를 사용자 이름으로 설정
            relationship.userName = coupleNames
            relationship.partnerName = ""
        }
        
        relationship.relationshipStartDate = startDate
        isSetupComplete = true
    }
}

#Preview {
    SetupView(isSetupComplete: .constant(false))
        .environmentObject(RelationshipModel())
}
