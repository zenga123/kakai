//
//  EnhancedCalendarView.swift
//  kakai
//
//  Created for kakai app.
//

import SwiftUI

struct EnhancedCalendarView: View {
    let startDate: Date
    let endDate: Date?
    
    // 현재 표시할 월을 계산
    private var calendarStartDate: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: startDate)
        components.day = 1
        return calendar.date(from: components) ?? startDate
    }
    
    // 월 표시 포맷
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
                    .foregroundColor(.black)
                    .padding(.top, 8)
            }
            
            // 요일 헤더
            HStack {
                let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .black))
                }
            }
            .padding(.vertical, 8)
            
            // 달력 격자
            let firstWeekday = firstWeekdayOfMonth(calendarStartDate)
            let daysInMonth = daysInMonth(calendarStartDate)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                // 이전 달의 빈 날짜
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Text("")
                        .frame(height: 36)
                }
                
                // 현재 달의 날짜들
                ForEach(1...daysInMonth, id: \.self) { day in
                    if let currentDay = getDateFor(day: day) {
                        ZStack {
                            // 배경
                            if isDateInRange(currentDay) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.pink.opacity(0.3))
                                    .frame(width: 36, height: 36)
                            }
                            
                            // 시작일/종료일 표시
                            if isSameDay(currentDay, startDate) || (endDate != nil && isSameDay(currentDay, endDate!)) {
                                Circle()
                                    .fill(isSameDay(currentDay, startDate) ? Color.pink : Color.purple)
                                    .frame(width: 34, height: 34)
                            }
                            
                            // 날짜 텍스트
                            Text("\(day)")
                                .foregroundColor(
                                    isSameDay(currentDay, startDate) || (endDate != nil && isSameDay(currentDay, endDate!))
                                    ? .white
                                    : (isDateInRange(currentDay) ? .pink : .black)
                                )
                                .font(.system(size: 16, weight: isSameDay(currentDay, startDate) || (endDate != nil && isSameDay(currentDay, endDate!)) ? .bold : .regular))
                        }
                        .frame(height: 36)
                    }
                }
            }
            .padding(8)
        }
        .padding()
        .background(Color.white)
    }
}

// MARK: - 미리보기
struct EnhancedCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 25))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 28))
        
        return EnhancedCalendarView(startDate: startDate, endDate: endDate)
            .frame(height: 320)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
