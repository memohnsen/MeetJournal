//
//  TrendsView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Charts
import Clerk

struct TrendsView: View {
    @Environment(\.clerk) private var clerk
    @State private var viewModel = HistoryModel()
    var checkins: [DailyCheckIn] { viewModel.checkIns }
    var workouts: [SessionReport] { viewModel.sessionReport }
    var meets: [CompReport] { viewModel.compReport }
    
    @State private var aiModel = OpenRouter()
    @State private var ouraService = Oura()
    
    @State private var aiShown: Bool = false
    @State private var ouraSleepData: [OuraSleep] = []
    @State private var isLoadingOuraData: Bool = false
    
    @State private var selectedFilter: String = "Check-Ins"
    @State private var selectedTimeFrame: String = "Last 30 Days"
    
    var isOuraConnected: Bool {
        guard let userId = clerk.user?.id else { return false }
        return ouraService.getAccessToken(userId: userId) != nil
    }
    
    var filterOptions: [String] {
        var options = ["Check-Ins", "Workouts", "Meets"]
        if isOuraConnected {
            options.append("Oura")
        }
        return options
    }
        
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    Filter(selected: $selectedFilter, options: filterOptions)
                        .onChange(of: selectedFilter) { _, newValue in
                            AnalyticsManager.shared.trackTrendsFilterChanged(filter: newValue)
                            if newValue == "Oura" {
                                Task {
                                    await fetchOuraData()
                                }
                            }
                        }
                    
                    VStack{
                        Button {
                            aiShown = true
                            AnalyticsManager.shared.trackAIAnalysisRequested(filter: selectedFilter)
                        } label: {
                            HStack{
                                Text("Let AI Analyze Your Data")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline.bold())
                        }
                    }
                    .cardStyling()
                    
                    if selectedFilter == "Check-Ins" {
                        CheckInGraphView(checkins: checkins, selectedTimeFrame: selectedTimeFrame)
                    } else if selectedFilter == "Workouts" {
                        WorkoutsGraphView(workouts: workouts, selectedTimeFrame: selectedTimeFrame)
                    } else if selectedFilter == "Oura" {
                        if isLoadingOuraData {
                            ProgressView("Loading Oura data...")
                                .padding()
                        } else if ouraSleepData.isEmpty {
                            Text("No Oura data available")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            OuraGraphView(
                                sleepData: ouraSleepData,
                                selectedTimeFrame: selectedTimeFrame
                            )
                        }
                    } else {
                        MeetsGraphView(meets: meets, selectedTimeFrame: selectedTimeFrame)
                    }
                }
            }
            .navigationTitle("Trends")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar{
                ToolbarItem{
                    Menu{
                        Button("Last 30 Days"){
                            selectedTimeFrame = "Last 30 Days"
                            AnalyticsManager.shared.trackTrendsTimeFrameChanged(timeFrame: "Last 30 Days")
                        }
                        
                        Button("Last 90 Days"){
                            selectedTimeFrame = "Last 90 Days"
                            AnalyticsManager.shared.trackTrendsTimeFrameChanged(timeFrame: "Last 90 Days")
                        }
                        
                        Button("Last 6 Months"){
                            selectedTimeFrame = "Last 6 Months"
                            AnalyticsManager.shared.trackTrendsTimeFrameChanged(timeFrame: "Last 6 Months")
                        }
                        
                        Button("Last 1 Year"){
                            selectedTimeFrame = "Last 1 Year"
                            AnalyticsManager.shared.trackTrendsTimeFrameChanged(timeFrame: "Last 1 Year")
                        }
                        
                        Button("All Time"){
                            selectedTimeFrame = "All Time"
                            AnalyticsManager.shared.trackTrendsTimeFrameChanged(timeFrame: "All Time")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
            .sheet(isPresented: $aiShown) {
                AIResults(selectedFilter: $selectedFilter, checkins: checkins, workouts: workouts, meets: meets, aiModel: aiModel)
            }
            .task {
                AnalyticsManager.shared.trackScreenView("TrendsView")
                await viewModel.fetchCheckins(user_id: clerk.user?.id ?? "")
                await viewModel.fetchCompReports(user_id: clerk.user?.id ?? "")
                await viewModel.fetchSessionReport(user_id: clerk.user?.id ?? "")
                
                if let userId = clerk.user?.id {
                    ouraService.checkConnectionStatus(userId: userId)
                    if isOuraConnected && selectedFilter == "Oura" {
                        await fetchOuraData()
                    }
                }
            }
            .onChange(of: selectedTimeFrame) { _, _ in
                if selectedFilter == "Oura" && isOuraConnected {
                    Task {
                        await fetchOuraData()
                    }
                }
            }
        }
    }
    
    func fetchOuraData() async {
        guard let userId = clerk.user?.id else { return }
        
        isLoadingOuraData = true
        defer { isLoadingOuraData = false }
        
        let calendar = Calendar.current
        let now = Date()
        let endDate = now
        
        let startDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            startDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            startDate = Date.distantPast
        default:
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        do {
            let sleepResult = try await ouraService.fetchDailySleep(userId: userId, startDate: startDate, endDate: endDate)
            
            ouraSleepData = sleepResult
            
            print("✅ Fetched Oura data: \(sleepResult.count) sleep records (includes HRV and readiness)")
        } catch {
            print("❌ Error fetching Oura data: \(error)")
            ouraSleepData = []
        }
    }
}

struct AIResults: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFilter: String
    var checkins: [DailyCheckIn]
    var workouts: [SessionReport]
    var meets: [CompReport]
    var aiModel: OpenRouter
    
    var prompt: String {
        return """
            Task: You are a sports data analyst specializing in Olympic Weightlifting and Powerlifting. You specialize in finding trends in large amounts of data. The following is the data we have on the athlete, I need you to analyze the data and find possible trends and return a response that will instruct the athlete on your findings. You are receiving data for an athlete's pre-lift check-ins, post-lift check-ins, and meet reflections. You should begin your process by matching the data and ordering by date to get a clear trend across the individual.
            
            Data Type: Daily check-in data performed prior to their lifting session. The overall score is a function of the physical and mental scores which are functions of the other 1-5 scale scores. 1 is always a poor value, 5 is always considered a good value, stress of 5 means relaxed, etc. The only time this isn't the case is for soreness, 1 is none, 5 is extreme.
            
            Data: \(checkins)
            
            Data Type: Post-session reflection data after each lifting session. 1 is always a poor value, 5 is always considered a good value, stress of 5 means relaxed, etc. The only time this isn't the case is for how hard was the session, 1 is easy, 5 is very hard.
            
            Data: \(workouts)
            
            Data Type: Post-competition reflection data. 1 is always a poor value, 5 is always considered a good value, stress of 5 means relaxed, etc.
            
            Data: \(meets)
                        
            Response Format:
            - No emojis
            - Do not include any greetings, get straight to the data
            - 250 words or less
            - No more than 4 sentences
            - Write as plain text, with each section of data formatted with an asterik to mark it as a bullet point
            - Do not include any recommendations or draw conclusions, only comment on trends
            """
    }
    
    @ViewBuilder
    func insufficientDataView(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                BackgroundColor()
    
                VStack {
                    if checkins.count >= 10 || workouts.count >= 10 || meets.count >= 3 {
                        if aiModel.isLoading || aiModel.response.isEmpty {
                            ProgressView("Analyzing your data...")
                        } else {
                            ScrollView {
                                VStack{
                                    Text(aiModel.response.replacingOccurrences(of: "*", with: "\n"))
                                        .padding([.horizontal, .bottom])
                                        .padding(.top, -4)
                                        .multilineTextAlignment(.center)
                                }
                                .cardStyling()
                            }
                        }
                    } else {
                        insufficientDataView(
                            icon: "chart.bar.doc.horizontal",
                            title: "More Data Needed",
                            description: "Complete at least 2 weeks of training to unlock this feature. The more data you provide, the more accurate the analysis."
                        )
                    }
                }
            }
            .navigationTitle("AI Trend Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    if #available(iOS 26.0, *) {
                        Button("Done", role: .confirm, action: { dismiss() })
                    } else {
                        Button("Done", action: { dismiss() })
                    }
                }
            }
            .task {
                if checkins.count >= 10 || workouts.count >= 10 || meets.count >= 3 {
                    try? await aiModel.query(prompt: prompt)
                    AnalyticsManager.shared.trackAIAnalysisCompleted(filter: selectedFilter, dataPoints: checkins.count)
                }
            }
        }
    }
}

struct CheckInGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    var checkins: [DailyCheckIn]
    var selectedTimeFrame: String
    
    struct AggregatedDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let averageScore: Double
    }
    
    enum TrendDirection {
        case up, down, flat
    }
    
    func calculateTrend(from data: [AggregatedDataPoint]) -> TrendDirection {
        guard data.count >= 2 else { return .flat }
        let sortedData = data.sorted { $0.date < $1.date }
        let first = sortedData.first!.averageScore
        let last = sortedData.last!.averageScore
        let threshold = 0.5 // Minimum change to be considered a trend
        
        if last > first + threshold {
            return .up
        } else if last < first - threshold {
            return .down
        } else {
            return .flat
        }
    }
    
    @ViewBuilder
    func trendIcon(for direction: TrendDirection) -> some View {
        switch direction {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
                .font(.headline)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundColor(.red)
                .font(.headline)
        case .flat:
            Image(systemName: "minus")
                .foregroundColor(blueEnergy)
                .font(.headline)
        }
    }
    
    // Filter and aggregate checkins based on selected time frame
    var overallChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // First, filter by time frame
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredCheckins = checkins.filter { checkin in
            if let checkinDate = dateFormatter.date(from: checkin.check_in_date) {
                return checkinDate >= cutoffDate
            }
            return false
        }
        
        // Determine if we need to aggregate
        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            // Return individual data points for short time frames
            return filteredCheckins.compactMap { checkin in
                if let date = dateFormatter.date(from: checkin.check_in_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(checkin.overall_score))
                }
                return nil
            }
        } else {
            // Group and average for longer time frames
            var groupedData: [DateComponents: [Int]] = [:]
            
            for checkin in filteredCheckins {
                if let date = dateFormatter.date(from: checkin.check_in_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(checkin.overall_score)
                }
            }
            
            // Calculate averages and create data points
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                // Create a representative date for this group
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    // For months, use the first day of the month
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var physicalChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredCheckins = checkins.filter { checkin in
            if let checkinDate = dateFormatter.date(from: checkin.check_in_date) {
                return checkinDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredCheckins.compactMap { checkin in
                if let date = dateFormatter.date(from: checkin.check_in_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(checkin.physical_score))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for checkin in filteredCheckins {
                if let date = dateFormatter.date(from: checkin.check_in_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(checkin.physical_score)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var mentalChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredCheckins = checkins.filter { checkin in
            if let checkinDate = dateFormatter.date(from: checkin.check_in_date) {
                return checkinDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredCheckins.compactMap { checkin in
                if let date = dateFormatter.date(from: checkin.check_in_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(checkin.mental_score))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for checkin in filteredCheckins {
                if let date = dateFormatter.date(from: checkin.check_in_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                     
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(checkin.mental_score)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var xAxisStride: Calendar.Component {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .month
        case "Last 90 Days":
            return .month
        case "Last 6 Months":
            return .month
        case "Last 1 Year":
            return .month
        case "All Time":
            return .month
        default:
            return .month
        }
    }
    
    var xAxisFormat: Date.FormatStyle {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .dateTime.month(.abbreviated)
        case "Last 90 Days":
            return .dateTime.month(.abbreviated)
        case "Last 6 Months", "Last 1 Year":
            return .dateTime.month(.abbreviated)
        case "All Time":
            return .dateTime.month(.abbreviated).year()
        default:
            return .dateTime.month(.abbreviated)
        }
    }
    
    var needsDiagonalLabels: Bool {
        switch selectedTimeFrame {
        case "Last 6 Months", "Last 1 Year", "All Time":
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        VStack{
            HStack {
                Text("Overall Readiness")
                    .font(.headline.bold())

                trendIcon(for: calculateTrend(from: overallChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(overallChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 25))
            }
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        VStack{
            HStack {
                Text("Physical Readiness")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: physicalChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(physicalChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 25))
            }
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        VStack{
            HStack {
                Text("Mental Readiness")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: mentalChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(mentalChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 25))
            }
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        .padding(.bottom, 30)
    }
}

struct WorkoutsGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    var workouts: [SessionReport]
    var selectedTimeFrame: String
    
    struct AggregatedDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let averageScore: Double
    }
    
    enum TrendDirection {
        case up, down, flat
    }
    
    func calculateTrend(from data: [AggregatedDataPoint]) -> TrendDirection {
        guard data.count >= 2 else { return .flat }
        let sortedData = data.sorted { $0.date < $1.date }
        let first = sortedData.first!.averageScore
        let last = sortedData.last!.averageScore
        let threshold = 0.1 // Minimum change to be considered a trend (smaller for 1-5 scale)
        
        if last > first + threshold {
            return .up
        } else if last < first - threshold {
            return .down
        } else {
            return .flat
        }
    }
    
    @ViewBuilder
    func trendIcon(for direction: TrendDirection) -> some View {
        switch direction {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
                .font(.headline)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundColor(.red)
                .font(.headline)
        case .flat:
            Image(systemName: "minus")
                .foregroundColor(blueEnergy)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    func trendIconInverted(for direction: TrendDirection) -> some View {
        // For metrics where lower is better (like misses), invert the colors
        switch direction {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundColor(.red) // Up is bad for misses
                .font(.headline)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundColor(.green) // Down is good for misses
                .font(.headline)
        case .flat:
            Image(systemName: "minus")
                .foregroundColor(blueEnergy)
                .font(.headline)
        }
    }
    
    var rpeChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredWorkouts = workouts.filter { workout in
            if let sessionDate = dateFormatter.date(from: workout.session_date) {
                return sessionDate >= cutoffDate
            }
            return false
        }
        
        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredWorkouts.compactMap { workout in
                if let date = dateFormatter.date(from: workout.session_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(workout.session_rpe))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for workout in filteredWorkouts {
                if let date = dateFormatter.date(from: workout.session_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(workout.session_rpe)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var movementChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredWorkouts = workouts.filter { workout in
            if let workoutDate = dateFormatter.date(from: workout.session_date) {
                return workoutDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredWorkouts.compactMap { workout in
                if let date = dateFormatter.date(from: workout.session_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(workout.movement_quality))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for workout in filteredWorkouts {
                if let date = dateFormatter.date(from: workout.session_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(workout.movement_quality)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var focusChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredWorkouts = workouts.filter { workout in
            if let workoutDate = dateFormatter.date(from: workout.session_date) {
                return workoutDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredWorkouts.compactMap { workout in
                if let date = dateFormatter.date(from: workout.session_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(workout.focus))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for workout in filteredWorkouts {
                if let date = dateFormatter.date(from: workout.session_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(workout.focus)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var missesChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredWorkouts = workouts.filter { workout in
            if let workoutDate = dateFormatter.date(from: workout.session_date) {
                return workoutDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredWorkouts.compactMap { workout in
                if let date = dateFormatter.date(from: workout.session_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(workout.misses) ?? 0)
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for workout in filteredWorkouts {
                if let date = dateFormatter.date(from: workout.session_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(Int(workout.misses) ?? 0)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var xAxisStride: Calendar.Component {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .month
        case "Last 90 Days":
            return .month
        case "Last 6 Months":
            return .month
        case "Last 1 Year":
            return .month
        case "All Time":
            return .month
        default:
            return .month
        }
    }
    
    var xAxisFormat: Date.FormatStyle {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .dateTime.month(.abbreviated)
        case "Last 90 Days":
            return .dateTime.month(.abbreviated)
        case "Last 6 Months", "Last 1 Year":
            return .dateTime.month(.abbreviated)
        case "All Time":
            return .dateTime.month(.abbreviated).year()
        default:
            return .dateTime.month(.abbreviated)
        }
    }
    
    var needsDiagonalLabels: Bool {
        switch selectedTimeFrame {
        case "Last 6 Months", "Last 1 Year", "All Time":
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        VStack{
            HStack {
                Text("Session RPE")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: rpeChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(rpeChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 1))
            }
            .chartYScale(domain: 1...5)
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        VStack{
            HStack {
                Text("Movement Quality")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: movementChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(movementChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 1))
            }
            .chartYScale(domain: 1...5)
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        VStack{
            HStack {
                Text("Focus")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: focusChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(focusChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 1))
            }
            .chartYScale(domain: 1...5)
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        VStack{
            HStack {
                Text("Misses")
                    .font(.headline.bold())
                
                trendIconInverted(for: calculateTrend(from: missesChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(missesChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 1))
            }
            .chartYScale(domain: 0...5)
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        .padding(.bottom, 30)
    }
}

struct MeetsGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("userSport") private var userSport: String = ""
    var meets: [CompReport]
    var selectedTimeFrame: String
    
    struct AggregatedDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let averageScore: Double
    }
    
    enum TrendDirection {
        case up, down, flat
    }
    
    func calculateTrend(from data: [AggregatedDataPoint]) -> TrendDirection {
        guard data.count >= 2 else { return .flat }
        let sortedData = data.sorted { $0.date < $1.date }
        let first = sortedData.first!.averageScore
        let last = sortedData.last!.averageScore
        
        let threshold: Double
        if first > 0 && first <= 5 {
            threshold = 0.1 // For 1-5 scale ratings
        } else {
            threshold = first * 0.02 // 2% change for totals
        }
        
        if last > first + threshold {
            return .up
        } else if last < first - threshold {
            return .down
        } else {
            return .flat
        }
    }
    
    @ViewBuilder
    func trendIcon(for direction: TrendDirection) -> some View {
        switch direction {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
                .font(.headline)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundColor(.red)
                .font(.headline)
        case .flat:
            Image(systemName: "minus")
                .foregroundColor(blueEnergy)
                .font(.headline)
        }
    }
    
    var performanceChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredmeets = meets.filter { meet in
            if let sessionDate = dateFormatter.date(from: meet.meet_date) {
                return sessionDate >= cutoffDate
            }
            return false
        }
        
        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredmeets.compactMap { meet in
                if let date = dateFormatter.date(from: meet.meet_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(meet.performance_rating))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for meet in filteredmeets {
                if let date = dateFormatter.date(from: meet.meet_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(meet.performance_rating)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var preparednessChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredmeets = meets.filter { meet in
            if let meetDate = dateFormatter.date(from: meet.meet_date) {
                return meetDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredmeets.compactMap { meet in
                if let date = dateFormatter.date(from: meet.meet_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(meet.physical_preparedness_rating))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for meet in filteredmeets {
                if let date = dateFormatter.date(from: meet.meet_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(meet.physical_preparedness_rating)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var mentalChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredmeets = meets.filter { meet in
            if let meetDate = dateFormatter.date(from: meet.meet_date) {
                return meetDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredmeets.compactMap { meet in
                if let date = dateFormatter.date(from: meet.meet_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double(meet.mental_preparedness_rating))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for meet in filteredmeets {
                if let date = dateFormatter.date(from: meet.meet_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append(meet.mental_preparedness_rating)
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var WLtotalChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredmeets = meets.filter { meet in
            if let meetDate = dateFormatter.date(from: meet.meet_date) {
                return meetDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredmeets.compactMap { meet in
                if let date = dateFormatter.date(from: meet.meet_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double((meet.snatch_best ?? 0) + (meet.cj_best ?? 0)))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for meet in filteredmeets {
                if let date = dateFormatter.date(from: meet.meet_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append((meet.snatch_best ?? 0) + (meet.cj_best ?? 0))
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var PLtotalChartData: [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredmeets = meets.filter { meet in
            if let meetDate = dateFormatter.date(from: meet.meet_date) {
                return meetDate >= cutoffDate
            }
            return false
        }

        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredmeets.compactMap { meet in
                if let date = dateFormatter.date(from: meet.meet_date) {
                    return AggregatedDataPoint(date: date, averageScore: Double((meet.squat_best ?? 0) + (meet.bench_best ?? 0) + (meet.deadlift_best ?? 0)))
                }
                return nil
            }
        } else {
            var groupedData: [DateComponents: [Int]] = [:]
            
            for meet in filteredmeets {
                if let date = dateFormatter.date(from: meet.meet_date) {
                    let components: DateComponents
                    if groupingComponent == .weekOfYear {
                        components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                    } else {
                        components = calendar.dateComponents([.year, .month], from: date)
                    }
                    
                    if groupedData[components] == nil {
                        groupedData[components] = []
                    }
                    groupedData[components]?.append((meet.squat_best ?? 0) + (meet.bench_best ?? 0) + (meet.deadlift_best ?? 0))
                }
            }
            
            return groupedData.compactMap { (components, scores) in
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, averageScore: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var xAxisStride: Calendar.Component {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .month
        case "Last 90 Days":
            return .month
        case "Last 6 Months":
            return .month
        case "Last 1 Year":
            return .month
        case "All Time":
            return .month
        default:
            return .month
        }
    }
    
    var xAxisFormat: Date.FormatStyle {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .dateTime.month(.abbreviated)
        case "Last 90 Days":
            return .dateTime.month(.abbreviated)
        case "Last 6 Months", "Last 1 Year":
            return .dateTime.month(.abbreviated)
        case "All Time":
            return .dateTime.month(.abbreviated).year()
        default:
            return .dateTime.month(.abbreviated)
        }
    }
    
    var needsDiagonalLabels: Bool {
        switch selectedTimeFrame {
        case "Last 6 Months", "Last 1 Year", "All Time":
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        VStack{
            HStack {
                Text("Performance Rating")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: performanceChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(performanceChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 1))
            }
            .chartYScale(domain: 1...5)
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        VStack{
            HStack {
                Text("Physical Preparedness")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: preparednessChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(preparednessChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 1))
            }
            .chartYScale(domain: 1...5)
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        VStack{
            HStack {
                Text("Mental Preparedness")
                    .font(.headline.bold())
                
                trendIcon(for: calculateTrend(from: mentalChartData))
            }
            .padding(.bottom)
            Chart {
                ForEach(mentalChartData) { dataPoint in
                    LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                        .foregroundStyle(blueEnergy)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(blueEnergy)
                                .frame(width: 12, height: 12)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                    AxisValueLabel {
                        if needsDiagonalLabels {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(y: 10)
                                    .padding(.vertical)
                            }
                        } else {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(xAxisFormat))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 1))
            }
            .chartYScale(domain: 1...5)
        }
        .frame(height: needsDiagonalLabels ? 250 : 200)
        .cardStyling()
        
        if userSport == "Olympic Weightlifting" {
            VStack{
                HStack {
                    Text("Total")
                        .font(.headline.bold())
                    
                    trendIcon(for: calculateTrend(from: WLtotalChartData))
                }
                .padding(.bottom)
                Chart {
                    ForEach(WLtotalChartData) { dataPoint in
                        LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                            .foregroundStyle(blueEnergy)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 2))
                            .symbol {
                                Circle()
                                    .fill(blueEnergy)
                                    .frame(width: 12, height: 12)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                        AxisValueLabel {
                            if needsDiagonalLabels {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                        .offset(y: 10)
                                        .padding(.vertical)
                                }
                            } else {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 50))
                }
            }
            .frame(height: needsDiagonalLabels ? 250 : 200)
            .cardStyling()
            .padding(.bottom, 30)
        } else {
            VStack{
                HStack {
                    Text("Total")
                        .font(.headline.bold())
                    
                    trendIcon(for: calculateTrend(from: PLtotalChartData))
                }
                .padding(.bottom)
                Chart {
                    ForEach(PLtotalChartData) { dataPoint in
                        LineMark(x: .value("Date", dataPoint.date), y: .value("Readiness", dataPoint.averageScore))
                            .foregroundStyle(blueEnergy)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 2))
                            .symbol {
                                Circle()
                                    .fill(blueEnergy)
                                    .frame(width: 12, height: 12)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                        AxisValueLabel {
                            if needsDiagonalLabels {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                        .offset(y: 10)
                                        .padding(.vertical)
                                }
                            } else {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 50))
                }
            }
            .frame(height: needsDiagonalLabels ? 250 : 200)
            .cardStyling()
            .padding(.bottom, 30)
        }
    }
}

struct OuraGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    var sleepData: [OuraSleep]
    var selectedTimeFrame: String
    
    struct AggregatedDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
    
    enum TrendDirection {
        case up, down, flat
    }
    
    func calculateTrend(from data: [AggregatedDataPoint]) -> TrendDirection {
        guard data.count >= 2 else { return .flat }
        let sortedData = data.sorted { $0.date < $1.date }
        let first = sortedData.first!.value
        let last = sortedData.last!.value
        let threshold = 0.1 // Minimum change to be considered a trend
        
        if last > first + threshold {
            return .up
        } else if last < first - threshold {
            return .down
        } else {
            return .flat
        }
    }
    
    @ViewBuilder
    func trendIcon(for direction: TrendDirection) -> some View {
        switch direction {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
                .font(.headline)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundColor(.red)
                .font(.headline)
        case .flat:
            Image(systemName: "minus")
                .foregroundColor(blueEnergy)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    func trendIconInverted(for direction: TrendDirection) -> some View {
        // For metrics where lower is better (like misses), invert the colors
        switch direction {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundColor(.red) // Up is bad for misses
                .font(.headline)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundColor(.green) // Down is good for misses
                .font(.headline)
        case .flat:
            Image(systemName: "minus")
                .foregroundColor(blueEnergy)
                .font(.headline)
        }
    }
    
    // Helper function to filter and aggregate data based on time frame
    func processData<T>(items: [T], dateKey: (T) -> String?, valueKey: (T) -> Double?) -> [AggregatedDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        
        let cutoffDate: Date
        switch selectedTimeFrame {
        case "Last 30 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 Days":
            cutoffDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Last 1 Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All Time":
            cutoffDate = Date.distantPast
        default:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredItems = items.compactMap { item -> (Date, Double)? in
            guard let dateString = dateKey(item),
                  let value = valueKey(item) else {
                return nil
            }
            
            var date: Date?
            if let parsedDate = dateFormatter.date(from: dateString) {
                date = parsedDate
            } else if let parsedDate = isoFormatter.date(from: dateString) {
                date = parsedDate
            }
            
            guard let validDate = date, validDate >= cutoffDate else {
                return nil
            }
            
            return (validDate, value)
        }
        
        let shouldAggregate: Bool
        let groupingComponent: Calendar.Component
        
        switch selectedTimeFrame {
        case "Last 30 Days":
            shouldAggregate = false
            groupingComponent = .day
        case "Last 90 Days":
            shouldAggregate = true
            groupingComponent = .weekOfYear
        case "Last 6 Months", "Last 1 Year", "All Time":
            shouldAggregate = true
            groupingComponent = .month
        default:
            shouldAggregate = false
            groupingComponent = .day
        }
        
        if !shouldAggregate {
            return filteredItems.map { AggregatedDataPoint(date: $0.0, value: $0.1) }
                .sorted { $0.date < $1.date }
        } else {
            var groupedData: [DateComponents: [Double]] = [:]
            
            for (date, value) in filteredItems {
                let components: DateComponents
                if groupingComponent == .weekOfYear {
                    components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                } else {
                    components = calendar.dateComponents([.year, .month], from: date)
                }
                
                if groupedData[components] == nil {
                    groupedData[components] = []
                }
                groupedData[components]?.append(value)
            }
            
            return groupedData.compactMap { (components, values) in
                let average = values.reduce(0, +) / Double(values.count)
                
                var representativeDate: Date?
                if groupingComponent == .weekOfYear {
                    representativeDate = calendar.date(from: components)
                } else {
                    var monthComponents = components
                    monthComponents.day = 1
                    representativeDate = calendar.date(from: monthComponents)
                }
                
                if let date = representativeDate {
                    return AggregatedDataPoint(date: date, value: average)
                }
                return nil
            }.sorted { $0.date < $1.date }
        }
    }
    
    var sleepChartData: [AggregatedDataPoint] {
        processData(
            items: sleepData,
            dateKey: { $0.day },
            valueKey: { $0.sleepDurationHours }
        )
    }
    
    var hrvChartData: [AggregatedDataPoint] {
        processData(
            items: sleepData,
            dateKey: { $0.day },
            valueKey: { $0.hrv }
        )
    }
    
    var heartRateChartData: [AggregatedDataPoint] {
        processData(
            items: sleepData,
            dateKey: { $0.day },
            valueKey: { $0.averageHeartRate }
        )
    }
    
    var readinessChartData: [AggregatedDataPoint] {
        processData(
            items: sleepData,
            dateKey: { $0.day },
            valueKey: { Double($0.readinessScore ?? 0) }
        )
    }
    
    var xAxisStride: Calendar.Component {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .month
        case "Last 90 Days":
            return .month
        case "Last 6 Months", "Last 1 Year":
            return .month
        case "All Time":
            return .month
        default:
            return .month
        }
    }
    
    var xAxisFormat: Date.FormatStyle {
        switch selectedTimeFrame {
        case "Last 30 Days":
            return .dateTime.month(.abbreviated)
        case "Last 90 Days":
            return .dateTime.month(.abbreviated)
        case "Last 6 Months", "Last 1 Year", "All Time":
            return .dateTime.month().year()
        default:
            return .dateTime.month(.abbreviated)
        }
    }
    
    var needsDiagonalLabels: Bool {
        switch selectedTimeFrame {
        case "Last 6 Months", "Last 1 Year", "All Time":
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack{
                HStack {
                    Text("Sleep Duration")
                        .font(.headline.bold())
                    
                    trendIcon(for: calculateTrend(from: sleepChartData))
                }
                .padding(.bottom)
                Chart {
                    ForEach(sleepChartData) { dataPoint in
                        LineMark(x: .value("Date", dataPoint.date), y: .value("Hours", dataPoint.value))
                            .foregroundStyle(blueEnergy)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 2))
                            .symbol {
                                Circle()
                                    .fill(blueEnergy)
                                    .frame(width: 12, height: 12)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                        AxisValueLabel {
                            if needsDiagonalLabels {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                        .offset(y: 10)
                                        .padding(.vertical)
                                }
                            } else {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 2))
                }
                .chartYScale(domain: [4, 12])
            }
            .frame(height: needsDiagonalLabels ? 250 : 200)
            .cardStyling()
            
            VStack{
                HStack {
                    Text("HRV (Heart Rate Variability)")
                        .font(.headline.bold())
                    
                    trendIcon(for: calculateTrend(from: hrvChartData))
                }
                .padding(.bottom)
                Chart {
                    ForEach(hrvChartData) { dataPoint in
                        LineMark(x: .value("Date", dataPoint.date), y: .value("HRV (ms)", dataPoint.value))
                            .foregroundStyle(blueEnergy)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 2))
                            .symbol {
                                Circle()
                                    .fill(blueEnergy)
                                    .frame(width: 12, height: 12)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                        AxisValueLabel {
                            if needsDiagonalLabels {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                        .offset(y: 10)
                                        .padding(.vertical)
                                }
                            } else {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .trailing)
                }
            }
            .frame(height: needsDiagonalLabels ? 250 : 200)
            .cardStyling()
            
            VStack{
                HStack {
                    Text("Average Heart Rate")
                        .font(.headline.bold())
                    
                    trendIconInverted(for: calculateTrend(from: heartRateChartData))
                }
                .padding(.bottom)
                Chart {
                    ForEach(heartRateChartData) { dataPoint in
                        LineMark(x: .value("Date", dataPoint.date), y: .value("BPM", dataPoint.value))
                            .foregroundStyle(blueEnergy)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 2))
                            .symbol {
                                Circle()
                                    .fill(blueEnergy)
                                    .frame(width: 12, height: 12)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                        AxisValueLabel {
                            if needsDiagonalLabels {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                        .offset(y: 10)
                                        .padding(.vertical)
                                }
                            } else {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 5))
                }
                .chartYScale(domain: [30, 70])
            }
            .frame(height: needsDiagonalLabels ? 250 : 200)
            .cardStyling()
            
            VStack{
                HStack {
                    Text("Readiness Score")
                        .font(.headline.bold())
                    
                    trendIcon(for: calculateTrend(from: readinessChartData))
                }
                .padding(.bottom)
                Chart {
                    ForEach(readinessChartData) { dataPoint in
                        LineMark(x: .value("Date", dataPoint.date), y: .value("Score", dataPoint.value))
                            .foregroundStyle(blueEnergy)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 2))
                            .symbol {
                                Circle()
                                    .fill(blueEnergy)
                                    .frame(width: 12, height: 12)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .stride(by: xAxisStride)) { value in
                        AxisValueLabel {
                            if needsDiagonalLabels {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                        .offset(y: 10)
                                        .padding(.vertical)
                                }
                            } else {
                                if let date = value.as(Date.self) {
                                    Text(date.formatted(xAxisFormat))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 10))
                }
                .chartYScale(domain: [40, 100])
            }
            .frame(height: needsDiagonalLabels ? 250 : 200)
            .cardStyling()
        }
        .padding(.bottom, 30)
    }
}

#Preview {
    TrendsView()
}
