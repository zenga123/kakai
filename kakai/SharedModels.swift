//
//  SharedModels.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import Foundation
import SwiftUI

// 앱 그룹 식별자 - 앱과 위젯 간 데이터 공유에 사용
let appGroupID = "group.gaku.kakai"

// 만남 모델
struct Meeting: Codable, Identifiable {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date?
    var memo: String?
    var photoFilename: String?
    var isCompleted: Bool
    
    // 몇박 몇일인지 계산하는 계산 속성
    var duration: (nights: Int, days: Int)? {
        guard let endDate = endDate else { return nil }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return (nights: max(0, days), days: max(1, days + 1))
    }
    
    // "2박 3일" 형식의 문자열 반환
    var durationText: String? {
        guard let duration = duration else { return nil }
        return "\(duration.nights)박 \(duration.days)일"
    }
    
    // 초기화 메서드 추가
    init(id: UUID, title: String, startDate: Date, endDate: Date? = nil, memo: String? = nil, photoFilename: String? = nil, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.memo = memo
        self.photoFilename = photoFilename
        self.isCompleted = isCompleted
    }
}

// 위젯 엔트리에 사용하는 단순화된 데이터 구조
struct MeetingWidgetData: Codable {
    var title: String
    var startDate: Date
    var endDate: Date?
    
    init(title: String, startDate: Date, endDate: Date? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // Meeting에서 위젯 데이터 생성
    init(from meeting: Meeting) {
        self.title = meeting.title
        self.startDate = meeting.startDate
        self.endDate = meeting.endDate
    }
    
    // "2박 3일" 형식의 문자열 반환
    var durationText: String? {
        guard let endDate = endDate else { return nil }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let nights = max(0, days)
        let totalDays = max(1, days + 1)
        return "\(nights)박 \(totalDays)일"
    }
}
