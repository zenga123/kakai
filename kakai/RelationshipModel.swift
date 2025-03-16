//
//  RelationshipModel.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import Foundation
import SwiftUI
import WidgetKit

class RelationshipModel: ObservableObject {
    @Published var userName: String = ""
    @Published var partnerName: String = ""
    @Published var relationshipStartDate: Date = Date()
    @Published var nextMeetingDate: Date?
    @Published var meetings: [Meeting] = []
    
    // UserDefaults 키
    private let userNameKey = "userName"
    private let partnerNameKey = "partnerName"
    private let startDateKey = "startDate"
    private let nextMeetingKey = "nextMeeting"
    private let meetingsKey = "meetings"
    
    init() {
        loadData()
    }
    
    var coupleNames: String {
        return "\(userName) & \(partnerName)"
    }
    
    var daysTogether: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: relationshipStartDate, to: Date())
        return components.day ?? 0
    }
    
    var daysUntilNextMeeting: Int? {
        guard let nextMeetingDate = nextMeetingDate else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextMeetingDate)
        return components.day
    }
    
    // 다음 만남 가져오기 (오늘 이후의 가장 가까운 날짜)
    var upcomingMeeting: Meeting? {
        let today = Date()
        return meetings
            .filter { $0.startDate > today }
            .sorted { $0.startDate < $1.startDate }
            .first
    }
    
    // 새 만남 추가
    func addMeeting(title: String, startDate: Date, endDate: Date? = nil) {
        let newMeeting = Meeting(
            id: UUID(),
            title: title,
            startDate: startDate,
            endDate: endDate,
            memo: nil,
            photoFilename: nil,
            isCompleted: false
        )
        
        meetings.append(newMeeting)
        saveData()
    }
    
    // 만남 업데이트
    func updateMeeting(_ meeting: Meeting) {
        if let index = meetings.firstIndex(where: { $0.id == meeting.id }) {
            meetings[index] = meeting
            saveData()
        }
    }
    
    // 만남 삭제
    func deleteMeeting(id: UUID) {
        meetings.removeAll { $0.id == id }
        saveData()
    }
    
    // 이미지 저장
    func saveImage(_ image: UIImage, for meetingId: UUID) -> String? {
        guard let documentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        
        let filename = "\(meetingId.uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // 이미지 로드
    func loadImage(filename: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    // UserDefaults에 데이터 저장
    func saveData() {
        let sharedDefaults = UserDefaults(suiteName: appGroupID)
        
        sharedDefaults?.set(userName, forKey: userNameKey)
        sharedDefaults?.set(partnerName, forKey: partnerNameKey)
        sharedDefaults?.set(relationshipStartDate, forKey: startDateKey)
        
        // 만남 데이터 저장
        if let encodedMeetings = try? JSONEncoder().encode(meetings) {
            sharedDefaults?.set(encodedMeetings, forKey: meetingsKey)
        }
        
        // 가장 빠른 미래 만남의 날짜를 nextMeetingDate로 설정
        if let upcomingMeeting = upcomingMeeting {
            sharedDefaults?.set(upcomingMeeting.startDate, forKey: nextMeetingKey)
            nextMeetingDate = upcomingMeeting.startDate
            
            // 위젯 데이터 저장
            let widgetData = MeetingWidgetData(from: upcomingMeeting)
            if let encodedWidgetData = try? JSONEncoder().encode(widgetData) {
                sharedDefaults?.set(encodedWidgetData, forKey: "widgetMeetingData")
            }
        } else {
            sharedDefaults?.removeObject(forKey: nextMeetingKey)
            sharedDefaults?.removeObject(forKey: "widgetMeetingData")
            nextMeetingDate = nil
        }
        
        // 위젯 업데이트를 위한 알림
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // UserDefaults에서 데이터 로드
    func loadData() {
        let sharedDefaults = UserDefaults(suiteName: appGroupID)
        
        if let savedUserName = sharedDefaults?.string(forKey: userNameKey) {
            userName = savedUserName
        }
        
        if let savedPartnerName = sharedDefaults?.string(forKey: partnerNameKey) {
            partnerName = savedPartnerName
        }
        
        if let savedStartDate = sharedDefaults?.object(forKey: startDateKey) as? Date {
            relationshipStartDate = savedStartDate
        }
        
        if let savedNextMeeting = sharedDefaults?.object(forKey: nextMeetingKey) as? Date {
            nextMeetingDate = savedNextMeeting
        }
        
        // 만남 데이터 로드
        if let savedMeetingsData = sharedDefaults?.data(forKey: meetingsKey),
           let decodedMeetings = try? JSONDecoder().decode([Meeting].self, from: savedMeetingsData) {
            meetings = decodedMeetings
        }
    }
}
