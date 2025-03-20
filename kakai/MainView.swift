//
//  MainView.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import SwiftUI
import PhotosUI

// ActiveSheet 열거형 정의
enum ActiveSheet: Identifiable {
    case history
    case meetingDetail
    
    var id: Int {
        hashValue
    }
}

// 새로 추가된 간소화된 MeetingDetailView
struct SimpleMeetingDetailView: View {
    @ObservedObject var relationship: RelationshipModel
    let meeting: Meeting
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 제목
                Text(meeting.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 날짜 정보
                VStack(alignment: .leading) {
                    Text("시작일: \(formatDate(meeting.startDate))")
                    
                    if let endDate = meeting.endDate {
                        Text("종료일: \(formatDate(endDate))")
                    }
                    
                    if let durationText = meeting.durationText {
                        Text("기간: \(durationText)")
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                // 메모
                if let memo = meeting.memo, !memo.isEmpty {
                    VStack(alignment: .leading) {
                        Text("메모")
                            .font(.headline)
                        
                        Text(memo)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// 개별 계획 카드 뷰
struct PlanCardView: View {
    let plan: String
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "\(index).circle.fill")
                    .foregroundColor(.pink)
                
                Text(planEmoji(for: plan))
                    .font(.headline)
            }
            
            Text(plan)
                .font(.body)
                .foregroundColor(.black)
                .padding(.leading, 26) // 아이콘 너비 + 간격
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
    
    // 계획 내용에 따라 적절한 이모지 반환
    private func planEmoji(for plan: String) -> String {
        let planLowercase = plan.lowercased()
        
        if planLowercase.contains("공부") || planLowercase.contains("study") {
            return "📚 공부"
        } else if planLowercase.contains("영화") || planLowercase.contains("movie") {
            return "🎬 영화"
        } else if planLowercase.contains("식사") || planLowercase.contains("밥") || planLowercase.contains("먹") || planLowercase.contains("food") || planLowercase.contains("eat") {
            return "🍽️ 식사"
        } else if planLowercase.contains("카페") || planLowercase.contains("커피") || planLowercase.contains("cafe") || planLowercase.contains("coffee") {
            return "☕️ 카페"
        } else if planLowercase.contains("쇼핑") || planLowercase.contains("shopping") {
            return "🛍️ 쇼핑"
        } else if planLowercase.contains("산책") || planLowercase.contains("walk") {
            return "🚶 산책"
        } else {
            return "📝 계획"
        }
    }
}

// 계획 편집 뷰
struct PlanEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var relationship: RelationshipModel
    let meeting: Meeting
    @State private var memoText: String
    @FocusState private var isTextFieldFocused: Bool
    
    init(relationship: RelationshipModel, meeting: Meeting) {
        self.relationship = relationship
        self.meeting = meeting
        // 새 메모를 작성하기 위해 빈 문자열로 초기화
        self._memoText = State(initialValue: "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    gradient: Gradient(colors: [Color(white: 0.95), Color.pink.opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 상단 제목
                        Text("계획 작성")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 15)
                        // 상단 정보 카드
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.title2)
                                    .foregroundColor(.pink)
                                
                                Text(meeting.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("날짜: \(formatDate(meeting.startDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                if let endDate = meeting.endDate {
                                    Text("~ \(formatDate(endDate))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            if let durationText = meeting.durationText {
                                Text(durationText)
                                    .font(.footnote)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 8)
                                    .background(Color.pink.opacity(0.2))
                                    .cornerRadius(4)
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        
                            // 기존 계획 미리보기 (있는 경우)
                            if let existingMemo = meeting.memo, !existingMemo.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("기존 계획")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                    
                                    // 메모를 구분자로 분리하여 각각 카드로 표시
                                    let separator = "|||PLAN_SEPARATOR|||"
                                    let plans = existingMemo.components(separatedBy: separator)
                                    
                                    ForEach(plans.indices, id: \.self) { index in
                                        PlanCardView(plan: plans[index], index: index + 1)
                                    }
                                }
                            }
                        
                        // 설명 텍스트
                        VStack(alignment: .leading, spacing: 4) {
                            Text("새 계획 추가")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let existingMemo = meeting.memo, !existingMemo.isEmpty {
                                Text("새로운 계획이 별도의 항목으로 추가됩니다.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("만남에 대한 계획이나 아이디어를 작성해보세요.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // 텍스트 에디터
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                            
                            if memoText.isEmpty && !isTextFieldFocused {
                                Text("새 계획을 입력하세요...")
                                    .foregroundColor(Color.gray.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $memoText)
                                .focused($isTextFieldFocused)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .cornerRadius(8)
                                .frame(minHeight: 200)
                                .foregroundColor(.black) // 텍스트 색상을 검정색으로 명시적 지정
                        }
                        .padding(.horizontal)
                        
                        // 아이디어 제안
                        VStack(alignment: .leading, spacing: 12) {
                            Text("어떤 계획을 세워볼까요?")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    suggestionButton("🍽 맛집 탐방")
                                    suggestionButton("🎬 영화 관람")
                                    suggestionButton("☕️ 카페 데이트")
                                    suggestionButton("🚶‍♀️ 산책하기")
                                    suggestionButton("🛍 쇼핑하기")
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // 저장/취소 버튼
                        HStack(spacing: 15) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("취소")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.pink, lineWidth: 1)
                                    )
                                    .foregroundColor(.pink)
                            }
                            
                            Button(action: {
                                savePlan()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("저장")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.pink)
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                }
            }
            // .navigationBarTitle("계획 작성", displayMode: .inline) // 네비게이션 타이틀 제거
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.pink),
                trailing: Button(action: {
                    isTextFieldFocused = false
                }) {
                    if isTextFieldFocused {
                        Text("완료")
                            .foregroundColor(.pink)
                    }
                }
            )
            .onTapGesture {
                // 화면 탭하면 키보드 닫기
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    // 제안 버튼 생성 함수
    private func suggestionButton(_ text: String) -> some View {
        Button(action: {
            if memoText.isEmpty {
                memoText = text
            } else {
                memoText += "\n" + text
            }
        }) {
            Text(text)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func savePlan() {
        var updatedMeeting = meeting
        
        // 구분자로 계획 항목을 구분
        let separator = "|||PLAN_SEPARATOR|||"
        
        // 기존 메모가 있을 경우
        if let existingMemo = updatedMeeting.memo, !existingMemo.isEmpty, !memoText.isEmpty {
            // 기존 메모에 새 메모 추가 (구분자 사용)
            updatedMeeting.memo = existingMemo + separator + memoText
        } else {
            // 기존 메모가 없거나 새 메모가 없는 경우, 새 메모로 설정
            updatedMeeting.memo = memoText.isEmpty ? nil : memoText
        }
        
        relationship.updateMeeting(updatedMeeting)
    }
}

struct MainView: View {
    @EnvironmentObject var relationship: RelationshipModel
    @State private var showingMeetingSheet = false
    @State private var newMeetingTitle = ""
    @State private var newMeetingStartDate = Date()
    @State private var newMeetingEndDate = Date().addingTimeInterval(24 * 60 * 60)
    @State private var isRangeSelection = false
    
    @State private var selectedMeeting: Meeting? = nil
    @State private var activeSheet: ActiveSheet? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text("\(relationship.userName) & \(relationship.partnerName)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.pink)
                Spacer()
                
                Button(action: {
                    activeSheet = .history
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.headline)
                        .foregroundColor(.pink)
                }
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
            
            if let upcomingMeeting = relationship.upcomingMeeting,
               let daysUntil = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: upcomingMeeting.startDate)).day {
                
                VStack(spacing: 15) {
                    Text("다음 만남")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(upcomingMeeting.title)
                        .font(.title3)
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 5) {
                        Text("\(daysUntil)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.pink)
                        
                        Text("일 남음")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Text(formatDate(upcomingMeeting.startDate))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let endDate = upcomingMeeting.endDate {
                        Text("~ \(formatDate(endDate))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if let durationText = upcomingMeeting.durationText {
                        Text(durationText)
                            .font(.subheadline)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Button(action: {
                        activeSheet = .meetingDetail
                    }) {
                        Text("자세히 보기")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.pink)
                            .cornerRadius(20)
                    }
                    .padding(.top, 5)                }
                .padding()
                .background(Color.pink.opacity(0.2))
                .cornerRadius(15)
                .padding(.top, 30)
                
            } else {
                // 다음 만남 추가하기 버튼 제거됨
            }
            
            Spacer()
            
            // 예정된 만남이 없을 때만 새 만남 추가 버튼 표시
            if relationship.upcomingMeeting == nil {
                Button(action: {
                    showingMeetingSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("새 만남 추가")
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .shadow(color: .pink.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.bottom, 20)
            }
        }
        .padding()
        .sheet(isPresented: $showingMeetingSheet) {
            AddMeetingView(relationship: relationship, isPresented: $showingMeetingSheet)
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .history:
                MeetingHistoryView(relationship: relationship)
            case .meetingDetail:
                NavigationView {
                    ZStack {
                        // 배경 그라데이션
                        LinearGradient(gradient: Gradient(colors: [Color.white, Color.pink.opacity(0.1)]),
                                     startPoint: .top,
                                     endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                        
                        if let upcomingMeeting = relationship.upcomingMeeting {
                            MeetingDetailContentView(relationship: relationship, meeting: upcomingMeeting)
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(.pink.opacity(0.8))
                                
                                Text("예정된 만남이 없습니다")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    activeSheet = nil
                                    showingMeetingSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("새 만남 추가하기")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(Color.pink)
                                    .cornerRadius(25)
                                }
                                .padding(.top, 10)
                            }
                        }
                    }
                    .navigationBarTitle("만남 상세정보", displayMode: .inline)
                    .navigationBarItems(trailing: Button("닫기") {
                        activeSheet = nil
                    })
                    // 네비게이션 바 스타일 수정
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("만남 상세정보")
                                .font(.headline)
                                .foregroundColor(.black) // 타이틀 색상을 검은색으로 변경
                        }
                    }
                }
                // 전체 네비게이션 바 스타일 설정
                .navigationViewStyle(StackNavigationViewStyle())
                .accentColor(.pink) // 액센트 색상 설정
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
}

struct AddMeetingView: View {
    @ObservedObject var relationship: RelationshipModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(24 * 60 * 60)
    @State private var isRangeSelection = false
    @State private var memo = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("만남 정보")) {
                    TextField("제목", text: $title)
                    
                    DatePicker("시작일", selection: $startDate, in: Date()..., displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                    
                    Toggle("종료일 추가", isOn: $isRangeSelection)
                    
                    if isRangeSelection {
                        DatePicker("종료일", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                        
                        if let nights = calculateNights(), let days = calculateDays() {
                            HStack {
                                Spacer()
                                Text("\(nights)박 \(days)일")
                                    .font(.headline)
                                    .foregroundColor(.pink)
                                Spacer()
                            }
                        }
                    }
                }
                
                Section(header: Text("메모")) {
                    TextField("간단한 메모 (선택사항)", text: $memo)
                }
            }
            .navigationTitle("새 만남 추가")
            .navigationBarItems(
                leading: Button("취소") {
                    isPresented = false
                },
                trailing: Button("저장") {
                    saveMeeting()
                    isPresented = false
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    private func calculateNights() -> Int? {
        guard isRangeSelection else { return nil }
        let calendar = Calendar.current
        let nights = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(0, nights)
    }
    
    private func calculateDays() -> Int? {
        guard let nights = calculateNights() else { return nil }
        return nights + 1
    }
    
    private func saveMeeting() {
        let newMeeting = Meeting(
            id: UUID(),
            title: title,
            startDate: startDate,
            endDate: isRangeSelection ? endDate : nil,
            memo: memo.isEmpty ? nil : memo,
            photoFilename: nil,
            isCompleted: false
        )
        
        relationship.meetings.append(newMeeting)
        relationship.saveData()
    }
}

struct MeetingDetailView: View {
    @ObservedObject var relationship: RelationshipModel
    @State var meeting: Meeting
    @State private var editMode = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var planText: String
    @State private var showingCalendar = true
    
    init(relationship: RelationshipModel, meeting: Meeting) {
        self.relationship = relationship
        self._meeting = State(initialValue: meeting)
        // 메모를 기본 계획 텍스트로 사용하거나 빈 문자열로 초기화
        self._planText = State(initialValue: meeting.memo ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 제목 및 날짜 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text(meeting.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(formatDate(meeting.startDate))
                        
                        if let endDate = meeting.endDate {
                            Text("~")
                            Text(formatDate(endDate))
                        }
                    }
                    .foregroundColor(.gray)
                    
                    if let durationText = meeting.durationText {
                        Text(durationText)
                            .font(.subheadline)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 10)
                
                // 캘린더 뷰 (상태에 따라 표시/숨김)
                if showingCalendar {
                    CalendarRangeView(startDate: meeting.startDate, endDate: meeting.endDate)
                        .frame(width: 280, height: 280)  // 정사각형 프레임
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.bottom, 10)
                }

                
                // 남은 일수 또는 완료 표시
                if meeting.startDate > Date() {
                    let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: meeting.startDate).day ?? 0
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("일정까지 남은 시간")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("D-\(daysUntil)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.pink)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showingCalendar.toggle()
                            }
                        }) {
                            VStack {
                                Image(systemName: showingCalendar ? "calendar.badge.minus" : "calendar.badge.plus")
                                    .font(.title2)
                                Text(showingCalendar ? "달력 숨기기" : "달력 보기")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.bottom, 16)
                } else if meeting.isCompleted {
                    HStack {
                        Text("만남 완료")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showingCalendar.toggle()
                            }
                        }) {
                            VStack {
                                Image(systemName: showingCalendar ? "calendar.badge.minus" : "calendar.badge.plus")
                                    .font(.title2)
                                Text(showingCalendar ? "달력 숨기기" : "달력 보기")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.bottom, 16)
                }
                
                // 계획 섹션
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("계획")
                            .font(.headline)
                        
                        Spacer()
                        
                        if editMode {
                            Button("저장") {
                                savePlan()
                                editMode = false
                            }
                            .foregroundColor(.blue)
                        } else {
                            Button("편집") {
                                editMode = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if editMode {
                        TextEditor(text: $planText)
                            .frame(minHeight: 150)
                            .padding(4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        if planText.isEmpty {
                            Text("아직 계획이 없습니다. 새 계획 추가 버튼을 눌러 계획을 작성해보세요.")
                                .foregroundColor(.gray)
                                .italic()
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                        } else {
                            Text(planText)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.bottom, 16)
                
                // 사진 영역
                VStack(alignment: .leading) {
                    Text("사진")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    if let photoFilename = meeting.photoFilename,
                       let image = relationship.loadImage(filename: photoFilename) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(12)
                    } else if selectedImage != nil {
                        Image(uiImage: selectedImage!)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            VStack {
                                Image(systemName: "photo.badge.plus")
                                    .font(.largeTitle)
                                Text("사진 추가")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("만남 상세")
        .navigationBarItems(
            trailing: Button(action: {
                if editMode {
                    // 편집 모드에서는 저장
                    savePlan()
                    editMode = false
                }
                
                if selectedImage != nil {
                    if let filename = relationship.saveImage(selectedImage!, for: meeting.id) {
                        var updatedMeeting = meeting
                        updatedMeeting.photoFilename = filename
                        relationship.updateMeeting(updatedMeeting)
                        meeting = updatedMeeting
                    }
                }
            }) {
                Text(editMode ? "완료" : "편집")
            }
        )
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func savePlan() {
        var updatedMeeting = meeting
        updatedMeeting.memo = planText
        relationship.updateMeeting(updatedMeeting)
        meeting = updatedMeeting
    }
}

struct CalendarRangeView: View {
    let startDate: Date
    let endDate: Date?
    
    // 현재 표시할 월을 계산
    private var calendarStartDate: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: startDate)
        components.day = 1
        return calendar.date(from: components) ?? startDate
    }
    
    // 헤더 텍스트 포맷
    private func formatMonthHeader() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: calendarStartDate)
    }
    
    // 월의 첫날 요일 계산 (0: 일요일, 1: 월요일, ...)
    private func firstWeekdayOfMonth(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDayOfMonth) - 1
    }
    
    // 월의 일수 계산
    private func daysInMonth(_ date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    // 날짜가 선택된 범위에 포함되는지 확인
    private func isDateInRange(_ date: Date) -> Bool {
        let calendar = Calendar.current
        
        // 시작 날짜와 비교
        let startCompare = calendar.compare(date, to: startDate, toGranularity: .day)
        
        if let endDate = endDate {
            // 종료 날짜가 있는 경우
            let endCompare = calendar.compare(date, to: endDate, toGranularity: .day)
            return (startCompare == .orderedSame || startCompare == .orderedDescending) &&
                   (endCompare == .orderedSame || endCompare == .orderedAscending)
        } else {
            // 종료 날짜가 없는 경우 시작 날짜만 체크
            return startCompare == .orderedSame
        }
    }
    
    // 특정 일의 Date 객체 생성
    private func getDateFor(day: Int) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: calendarStartDate)
        components.day = day
        return calendar.date(from: components)
    }
    
    // 두 날짜가 같은 날인지 확인
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedSame
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
            
            VStack {
                // 달력 헤더
                HStack {
                    Text(formatMonthHeader())
                        .font(.headline)
                        .padding(.top, 8)
                }
                
                // 요일 헤더
                HStack {
                    let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .primary))
                    }
                }
                .padding(.vertical, 8)
                
                // 달력 격자
                let firstWeekday = firstWeekdayOfMonth(calendarStartDate)
                let daysInMonth = daysInMonth(calendarStartDate)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    // 이전 달의 빈 날짜
                    ForEach(0..<firstWeekday, id: \.self) { _ in
                        Text("")
                            .frame(height: 32)
                    }
                    
                    // 현재 달의 날짜들
                    ForEach(1...daysInMonth, id: \.self) { day in
                        if let currentDay = getDateFor(day: day) {
                            CalendarDayView(
                                day: day,
                                isInRange: isDateInRange(currentDay),
                                isStartDate: isSameDay(currentDay, startDate),
                                isEndDate: endDate != nil ? isSameDay(currentDay, endDate!) : false
                            )
                        }
                    }
                }
                .padding(8)
            }
            .padding()
        }
    }
}

// 캘린더 날짜 셀 뷰
struct CalendarDayView: View {
    let day: Int
    let isInRange: Bool
    let isStartDate: Bool
    let isEndDate: Bool
    
    var body: some View {
        ZStack {
            // 배경
            if isInRange {
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            
            // 시작일/종료일 표시
            if isStartDate || isEndDate {
                Circle()
                    .fill(Color.red)
                    .frame(width: 32, height: 32)
            }
            
            // 날짜 텍스트
            Text("\(day)")
                .foregroundColor(isStartDate || isEndDate ? .white : (isInRange ? .red : .primary))
                .font(.system(size: 16, weight: isStartDate || isEndDate ? .bold : .regular))
        }
        .frame(height: 32)
    }
}
struct MeetingHistoryView: View {
    @ObservedObject var relationship: RelationshipModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(relationship.meetings.sorted { $0.startDate > $1.startDate }) { meeting in
                    MeetingRowView(relationship: relationship, meeting: meeting)
                }
                .onDelete(perform: deleteMeeting)
            }
            .navigationTitle("만남 히스토리")
        }
    }
    
    private func deleteMeeting(at offsets: IndexSet) {
        let sortedMeetings = relationship.meetings.sorted { $0.startDate > $1.startDate }
        for index in offsets {
            relationship.deleteMeeting(id: sortedMeetings[index].id)
        }
    }
}

struct MeetingRowView: View {
    @ObservedObject var relationship: RelationshipModel
    let meeting: Meeting
    
    var body: some View {
        HStack {
            // 썸네일 이미지
            if let photoFilename = meeting.photoFilename,
               let image = relationship.loadImage(filename: photoFilename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // 만남 정보
            VStack(alignment: .leading) {
                Text(meeting.title)
                    .font(.headline)
                
                HStack {
                    Text(formatDate(meeting.startDate))
                    
                    if let endDate = meeting.endDate {
                        Text("~")
                        Text(formatDate(endDate))
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                if let durationText = meeting.durationText {
                    Text(durationText)
                        .font(.caption2)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

// 만남 상세 정보 콘텐츠 뷰
struct MeetingDetailContentView: View {
    @ObservedObject var relationship: RelationshipModel
    let meeting: Meeting
    @State private var showingPlanEditor = false
    
    // 계획 내용에 따라 적절한 이모지 반환
    private func planEmoji(for plan: String) -> String {
        let planLowercase = plan.lowercased()
        
        if planLowercase.contains("공부") || planLowercase.contains("study") {
            return "📚 공부"
        } else if planLowercase.contains("영화") || planLowercase.contains("movie") {
            return "🎬 영화"
        } else if planLowercase.contains("식사") || planLowercase.contains("밥") || planLowercase.contains("먹") || planLowercase.contains("food") || planLowercase.contains("eat") {
            return "🍽️ 식사"
        } else if planLowercase.contains("카페") || planLowercase.contains("커피") || planLowercase.contains("cafe") || planLowercase.contains("coffee") {
            return "☕️ 카페"
        } else if planLowercase.contains("쇼핑") || planLowercase.contains("shopping") {
            return "🛍️ 쇼핑"
        } else if planLowercase.contains("산책") || planLowercase.contains("walk") {
            return "🚶 산책"
        } else if planLowercase.contains("여행") || planLowercase.contains("travel") || planLowercase.contains("trip") {
            return "✈️ 여행"
        } else {
            return "📝 계획"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 헤더 섹션 - 제목과 날짜 요약
                VStack(alignment: .leading, spacing: 8) {
                    Text(meeting.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.pink)
                        
                        Text(formatDate(meeting.startDate))
                            .foregroundColor(.black)

                        if let endDate = meeting.endDate {
                            Text("~")
                                .foregroundColor(.gray)
                            Text(formatDate(endDate))
                                .foregroundColor(.black)
                        }
                    }

                    if let durationText = meeting.durationText {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.pink)
                            
                            Text(durationText)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.pink.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 5)
                
                // 타이머 섹션 - D-day 카운트다운
                if meeting.startDate > Date() {
                    let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: meeting.startDate).day ?? 0
                    
                    VStack(spacing: 0) {
                        Text("만남까지")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(daysUntil)")
                                .font(.system(size: 42, weight: .heavy))
                                .foregroundColor(.pink)
                            
                            Text("일")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .padding(.vertical, 10)
                }

                // 달력 섹션
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("일정")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    // 분리된 EnhancedCalendarView 사용
                EnhancedCalendarView(startDate: meeting.startDate, endDate: meeting.endDate)
                    .frame(height: 370) // 높이 증가
                    .padding(.vertical, 10) // 상하 여백 추가
                    .padding(.horizontal, 5) // 좌우 여백 추가
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }                                .padding(.vertical, 10)

                // 계획 섹션
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("계획")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                    }
                    
                    // 기존 메모 표시 - 계획 카드로 분리하여 표시
                    if let memo = meeting.memo, !memo.isEmpty {
                        let separator = "|||PLAN_SEPARATOR|||"
                        let plans = memo.components(separatedBy: separator)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(plans.indices, id: \.self) { index in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "\(index + 1).circle.fill")
                                                .foregroundColor(.pink)
                                            
                                            Text(planEmoji(for: plans[index]))
                                                .font(.headline)
                                        }
                                        
                                        Text(plans[index])
                                            .font(.body)
                                            .foregroundColor(.black)
                                            .padding(.leading, 6)
                                    }
                                    .padding()
                                    .frame(width: 100, height: 100)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                                    )
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 32))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("아직 계획이 없습니다. 새 계획 추가 버튼을 눌러 계획을 작성해보세요.")
                                .multilineTextAlignment(.center)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                    }

                    // 계획 추가 버튼
                    Button(action: {
                        showingPlanEditor = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            Text("새 계획 추가")
                                .font(.subheadline)
                        }
                        .foregroundColor(.pink)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.pink, lineWidth: 1)
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showingPlanEditor) {
            PlanEditorView(relationship: relationship, meeting: meeting)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
}

#Preview {
    MainView()
        .environmentObject(RelationshipModel())
}
