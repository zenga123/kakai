//
//  RelationshipModel.swift
//  kakai
//
//  Created for kakai app on 2025/03/16.
//

import Foundation

class RelationshipModel: ObservableObject {
    @Published var userName: String = ""
    @Published var partnerName: String = ""
    @Published var relationshipStartDate: Date = Date()
    @Published var nextMeetingDate: Date?
    
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
}
