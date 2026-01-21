//
//  CheckInStreakCalculator.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 1/11/26.
//

import Foundation

struct CheckInStreakCalculator {
    static func currentStreak(
        checkins: [DailyCheckIn],
        trainingDays: [String: String],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let trainingWeekdays = Set(trainingDays.keys.compactMap { weekdayNumber(from: $0) })
        guard !trainingWeekdays.isEmpty else { return 0 }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone

        let checkInDates = Set(
            checkins.compactMap { checkin in
                let dateString = String(checkin.check_in_date.prefix(10))
                guard let date = formatter.date(from: dateString) else { return nil }
                return calendar.startOfDay(for: date)
            }
        )

        let today = calendar.startOfDay(for: referenceDate)
        let hasCheckInToday = checkInDates.contains(today)
        let searchStart = hasCheckInToday
            ? today
            : calendar.date(byAdding: .day, value: -1, to: today) ?? today

        guard let endDate = mostRecentTrainingDay(onOrBefore: searchStart, trainingWeekdays: trainingWeekdays, calendar: calendar),
              checkInDates.contains(endDate) else {
            return 0
        }

        var streak = 0
        var currentDate = endDate

        while checkInDates.contains(currentDate) {
            streak += 1

            guard let previousDate = previousTrainingDay(
                before: currentDate,
                trainingWeekdays: trainingWeekdays,
                calendar: calendar
            ) else {
                break
            }

            currentDate = previousDate
        }

        return streak
    }

    private static func weekdayNumber(from dayName: String) -> Int? {
        switch dayName.lowercased() {
        case "sunday": return 1
        case "monday": return 2
        case "tuesday": return 3
        case "wednesday": return 4
        case "thursday": return 5
        case "friday": return 6
        case "saturday": return 7
        default: return nil
        }
    }

    private static func mostRecentTrainingDay(
        onOrBefore date: Date,
        trainingWeekdays: Set<Int>,
        calendar: Calendar
    ) -> Date? {
        var current = calendar.startOfDay(for: date)

        for _ in 0..<7 {
            if trainingWeekdays.contains(calendar.component(.weekday, from: current)) {
                return current
            }

            guard let previous = calendar.date(byAdding: .day, value: -1, to: current) else {
                return nil
            }

            current = previous
        }

        return nil
    }

    private static func previousTrainingDay(
        before date: Date,
        trainingWeekdays: Set<Int>,
        calendar: Calendar
    ) -> Date? {
        var current = date

        for _ in 0..<7 {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: current) else {
                return nil
            }

            current = previous

            if trainingWeekdays.contains(calendar.component(.weekday, from: current)) {
                return calendar.startOfDay(for: current)
            }
        }

        return nil
    }
}
