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
               let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: upcomingMeeting.startDate).day {
                
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
                .background(Color.pink.opacity(0.1))
                .cornerRadius(15)
                .padding(.top, 30)
                
            } else {
                Button(action: {
                    showingMeetingSheet = true
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("다음 만남 추가하기")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding(.top, 40)
            }
            
            Spacer()
            
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
                    
                    Toggle("기간 만남", isOn: $isRangeSelection)
                    
                    if isRangeSelection {
                        DatePicker("종료일", selection: $endDate, in: startDate..., displayedComponents: .date)
                        
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                
                // 남은 일수 또는 완료 표시
                if meeting.startDate > Date() {
                    let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: meeting.startDate).day ?? 0
                    Text("D-\(daysUntil)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if meeting.isCompleted {
                    Text("만남 완료")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                
                // 사진 영역
                VStack {
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
                
                // 메모 영역
                if let memo = meeting.memo, !memo.isEmpty {
                    Text("메모")
                        .font(.headline)
                    
                    Text(memo)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("만남 상세")
        .navigationBarItems(
            trailing: Button(editMode ? "완료" : "편집") {
                if editMode && selectedImage != nil {
                    if let filename = relationship.saveImage(selectedImage!, for: meeting.id) {
                        var updatedMeeting = meeting
                        updatedMeeting.photoFilename = filename
                        relationship.updateMeeting(updatedMeeting)
                        meeting = updatedMeeting
                    }
                }
                editMode.toggle()
            }
        )
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
