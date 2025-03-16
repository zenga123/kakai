//
//  RelationshipModel.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import Foundation
import SwiftUI
import WidgetKit

// 앱 그룹 식별자 - 앱과 위젯 간 데이터 공유에 사용
let appGroupID = "group.gaku.kakai"

class RelationshipModel: ObservableObject {
    @Published var userName: String = ""
    @Published var partnerName: String = ""
    @Published var relationshipStartDate: Date = Date()
    @Published var nextMeetingDate: Date?
    
    // UserDefaults 키
    private let userNameKey = "userName"
    private let partnerNameKey = "partnerName"
    private let startDateKey = "startDate"
    private let nextMeetingKey = "nextMeeting"
    
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
    
    // UserDefaults에 데이터 저장
    func saveData() {
        let sharedDefaults = UserDefaults(suiteName: appGroupID)
        
        sharedDefaults?.set(userName, forKey: userNameKey)
        sharedDefaults?.set(partnerName, forKey: partnerNameKey)
        sharedDefaults?.set(relationshipStartDate, forKey: startDateKey)
        
        if let nextDate = nextMeetingDate {
            sharedDefaults?.set(nextDate, forKey: nextMeetingKey)
        } else {
            sharedDefaults?.removeObject(forKey: nextMeetingKey)
        }
        
        // 위젯 업데이트를 위한 알림 (위젯 구현 시 필요)
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
    }
}
