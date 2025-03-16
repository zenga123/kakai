//
//  KakaiWidgetSimple.swift
//  KakaiWidget
//
//  Created for kakai app on 2025/03/16.
//

import WidgetKit
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
}

// 위젯용 간소화 데이터 모델
struct MeetingWidgetData: Codable {
    var title: String
    var startDate: Date
    var endDate: Date?
    
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let daysTogether: Int
    let daysUntilNextMeeting: Int?
    let coupleNames: String
    let meetingTitle: String?
    let duration: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), daysTogether: 100, daysUntilNextMeeting: 7, coupleNames: "지민 & 수지", meetingTitle: "주말 데이트", duration: "1박 2일")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // 다음 날 자정에 업데이트
        let nextUpdateDate = Calendar.current.startOfDay(for: Date().addingTimeInterval(24 * 60 * 60))
        let entry = getEntry()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    private func getEntry() -> SimpleEntry {
        // 기본값 설정
        var daysTogether = 0
        var daysUntilMeeting: Int? = nil
        var coupleNames = "커플 이름"
        var meetingTitle: String? = nil
        var duration: String? = nil
        
        // UserDefaults에서 데이터 읽기 시도
        if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
            let userName = sharedDefaults.string(forKey: "userName") ?? ""
            let partnerName = sharedDefaults.string(forKey: "partnerName") ?? ""
            
            if !userName.isEmpty || !partnerName.isEmpty {
                coupleNames = "\(userName) & \(partnerName)"
            }
            
            if let startDate = sharedDefaults.object(forKey: "startDate") as? Date {
                let components = Calendar.current.dateComponents([.day], from: startDate, to: Date())
                daysTogether = components.day ?? 0
            }
            
            if let nextMeetingDate = sharedDefaults.object(forKey: "nextMeeting") as? Date {
                let components = Calendar.current.dateComponents([.day], from: Date(), to: nextMeetingDate)
                daysUntilMeeting = components.day
            }
            
            // 위젯용 미팅 데이터 가져오기 (간소화된 버전)
            if let widgetDataRaw = sharedDefaults.data(forKey: "widgetMeetingData") {
                if let widgetData = try? JSONDecoder().decode(MeetingWidgetData.self, from: widgetDataRaw) {
                    meetingTitle = widgetData.title
                    duration = widgetData.durationText
                }
            }
        }
        
        return SimpleEntry(
            date: Date(),
            daysTogether: daysTogether,
            daysUntilNextMeeting: daysUntilMeeting,
            coupleNames: coupleNames,
            meetingTitle: meetingTitle,
            duration: duration
        )
    }
}

struct KakaiWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidget(entry: entry)
        case .systemMedium:
            MediumWidget(entry: entry)
        default:
            SmallWidget(entry: entry)
        }
    }
}

struct SmallWidget: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 5) {
            if let daysRemaining = entry.daysUntilNextMeeting {
                Text("만남까지")
                    .font(.caption)
                    .foregroundColor(.white)
                
                if let title = entry.meetingTitle {
                    Text(title)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                
                Text("\(daysRemaining)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("일 남음")
                    .font(.caption)
                    .foregroundColor(.white)
                
                if let duration = entry.duration {
                    Text(duration)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }
            } else {
                Text("함께한 시간")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text("\(entry.daysTogether)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("일")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(entry.coupleNames)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct MeetingSmallWidget: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 5) {
            Text("다음 만남")
                .font(.caption)
                .foregroundColor(.white)
            
            if let title = entry.meetingTitle {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.bottom, 2)
            }
            
            if let daysRemaining = entry.daysUntilNextMeeting {
                Text("\(daysRemaining)")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                
                Text("일 남음")
                    .font(.caption)
                    .foregroundColor(.white)
                
                if let duration = entry.duration {
                    Text(duration)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }
            } else {
                Text("미정")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("날짜를 설정해주세요")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(entry.coupleNames)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct MediumWidget: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            // 함께한 일수
            VStack(spacing: 5) {
                Text("함께한 시간")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text("\(entry.daysTogether)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("일")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            
            // 구분선
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1, height: 60)
            
            // 다음 만남까지 남은 일수
            VStack(spacing: 5) {
                if let title = entry.meetingTitle {
                    Text(title)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                Text("다음 만남까지")
                    .font(.caption)
                    .foregroundColor(.white)
                
                if let daysRemaining = entry.daysUntilNextMeeting {
                    Text("\(daysRemaining)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("일 남음")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    if let duration = entry.duration {
                        Text(duration)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(4)
                    }
                } else {
                    Text("미정")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .overlay(
            VStack {
                Spacer()
                Text(entry.coupleNames)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.bottom, 8)
            }
        )
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// 위젯 정의
struct KakaiWidget: Widget {
    let kind: String = "KakaiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            KakaiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("가까이")
        .description("다음 만남까지 남은 시간을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct KakaiMeetingWidget: Widget {
    let kind: String = "KakaiMeetingWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MeetingSmallWidget(entry: entry)
        }
        .configurationDisplayName("다음 만남")
        .description("다음 만남까지 남은 일수만 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

struct KakaiWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KakaiWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                daysTogether: 100,
                daysUntilNextMeeting: 7,
                coupleNames: "지민 & 수지",
                meetingTitle: "제주도 여행",
                duration: "2박 3일"
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            KakaiWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                daysTogether: 100,
                daysUntilNextMeeting: 7,
                coupleNames: "지민 & 수지",
                meetingTitle: "제주도 여행",
                duration: "2박 3일"
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            MeetingSmallWidget(entry: SimpleEntry(
                date: Date(),
                daysTogether: 100,
                daysUntilNextMeeting: 7,
                coupleNames: "지민 & 수지",
                meetingTitle: "제주도 여행",
                duration: "2박 3일"
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
