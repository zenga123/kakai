//
//  MainView.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import SwiftUI
import PhotosUI

struct MainView: View {
    @EnvironmentObject var relationship: RelationshipModel
    @State private var showingMeetingSheet = false
    @State private var showingHistoryView = false
    @State private var newMeetingTitle = ""
    @State private var newMeetingStartDate = Date()
    @State private var newMeetingEndDate = Date().addingTimeInterval(24 * 60 * 60)
    @State private var isRangeSelection = false
    
    @State private var selectedMeeting: Meeting? = nil
    @State private var showingMeetingDetail = false
    
    var body: some View {
        VStack {
            HStack {
                Text("\(relationship.userName) & \(relationship.partnerName)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.pink)
                Spacer()
                
                Button(action: {
                    showingHistoryView = true
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
                        selectedMeeting = upcomingMeeting
                        showingMeetingDetail = true
                    }) {
                        Text("자세히 보기")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.pink)
                            .cornerRadius(20)
                    }
                    .padding(.top, 5)
                }
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
        .sheet(isPresented: $showingHistoryView) {
            MeetingHistoryView(relationship: relationship)
        }
        .sheet(isPresented: $showingMeetingDetail) {
            if let meeting = selectedMeeting {
                MeetingDetailView(relationship: relationship, meeting: meeting)
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
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                    
                    Toggle("종료일 추가", isOn: $isRangeSelection)
                    
                    if isRangeSelection {
                        DatePicker("종료일", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ko_KR"))
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
                        .frame(height: 280)
                        .background(Color.white)
                        .cornerRadius(12)
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
                            Text("아직 계획이 없습니다. 편집 버튼을 눌러 계획을 작성해보세요.")
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
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.pink.opacity(0.3))
            }
            
            // 시작일/종료일 표시
            if isStartDate || isEndDate {
                Circle()
                    .fill(isStartDate ? Color.pink : Color.purple)
                    .frame(width: 32, height: 32)
            }
            
            // 날짜 텍스트
            Text("\(day)")
                .foregroundColor(isStartDate || isEndDate ? .white : (isInRange ? .pink : .primary))
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

#Preview {
    MainView()
        .environmentObject(RelationshipModel())
}
