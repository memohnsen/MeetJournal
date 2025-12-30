//
//  AnalyticsManager.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/30/25.
//

import Foundation
import PostHog

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    // MARK: - Screen Views
    func trackScreenView(_ screenName: String, properties: [String: Any]? = nil) {
        PostHogSDK.shared.screen(screenName, properties: properties)
    }

    // MARK: - User Authentication
    func trackUserSignedUp(method: String) {
        PostHogSDK.shared.capture("user_signed_up", properties: ["method": method])
    }

    func trackUserSignedIn(method: String) {
        PostHogSDK.shared.capture("user_signed_in", properties: ["method": method])
    }

    func trackUserSignedOut() {
        PostHogSDK.shared.capture("user_signed_out")
    }

    // MARK: - Onboarding
    func trackOnboardingStarted() {
        PostHogSDK.shared.capture("onboarding_started")
    }

    func trackOnboardingCompleted() {
        PostHogSDK.shared.capture("onboarding_completed")
    }

    func trackOnboardingPageViewed(pageNumber: Int, totalPages: Int) {
        PostHogSDK.shared.capture("onboarding_page_viewed", properties: [
            "page_number": pageNumber,
            "total_pages": totalPages
        ])
    }

    // MARK: - Check-Ins
    func trackCheckInStarted() {
        PostHogSDK.shared.capture("checkin_started")
    }

    func trackCheckInSubmitted(lift: String, intensity: String, overallScore: Int) {
        PostHogSDK.shared.capture("checkin_submitted", properties: [
            "lift": lift,
            "intensity": intensity,
            "overall_score": overallScore
        ])
    }

    func trackCheckInViewed(checkInId: Int) {
        PostHogSDK.shared.capture("checkin_viewed", properties: [
            "checkin_id": checkInId
        ])
    }

    func trackCheckInDeleted(checkInId: Int) {
        PostHogSDK.shared.capture("checkin_deleted", properties: [
            "checkin_id": checkInId
        ])
    }

    // MARK: - Session Reflections
    func trackSessionReflectionStarted() {
        PostHogSDK.shared.capture("session_reflection_started")
    }

    func trackSessionReflectionSubmitted(lift: String, intensity: String, rpe: Int) {
        PostHogSDK.shared.capture("session_reflection_submitted", properties: [
            "lift": lift,
            "intensity": intensity,
            "session_rpe": rpe
        ])
    }

    func trackSessionReflectionViewed(sessionId: Int) {
        PostHogSDK.shared.capture("session_reflection_viewed", properties: [
            "session_id": sessionId
        ])
    }

    func trackSessionReflectionDeleted(sessionId: Int) {
        PostHogSDK.shared.capture("session_reflection_deleted", properties: [
            "session_id": sessionId
        ])
    }

    // MARK: - Competition Reflections
    func trackCompReflectionStarted() {
        PostHogSDK.shared.capture("comp_reflection_started")
    }

    func trackCompReflectionSubmitted(meetName: String, meetType: String, performanceRating: Int) {
        PostHogSDK.shared.capture("comp_reflection_submitted", properties: [
            "meet_name": meetName,
            "meet_type": meetType,
            "performance_rating": performanceRating
        ])
    }

    func trackCompReflectionViewed(compId: Int) {
        PostHogSDK.shared.capture("comp_reflection_viewed", properties: [
            "comp_id": compId
        ])
    }

    func trackCompReflectionDeleted(compId: Int) {
        PostHogSDK.shared.capture("comp_reflection_deleted", properties: [
            "comp_id": compId
        ])
    }

    // MARK: - History & Browse
    func trackHistoryFilterChanged(filter: String) {
        PostHogSDK.shared.capture("history_filter_changed", properties: [
            "filter": filter
        ])
    }

    func trackHistoryItemViewed(type: String, itemId: Int) {
        PostHogSDK.shared.capture("history_item_viewed", properties: [
            "type": type,
            "item_id": itemId
        ])
    }

    func trackHistoryDeleted(type: String, count: Int) {
        PostHogSDK.shared.capture("history_deleted", properties: [
            "type": type,
            "count": count
        ])
    }

    func trackHistoryExported(format: String, itemCount: Int) {
        PostHogSDK.shared.capture("history_exported", properties: [
            "format": format,
            "item_count": itemCount
        ])
    }

    // MARK: - Trends
    func trackTrendsFilterChanged(filter: String) {
        PostHogSDK.shared.capture("trends_filter_changed", properties: [
            "filter": filter
        ])
    }

    func trackTrendsTimeFrameChanged(timeFrame: String) {
        PostHogSDK.shared.capture("trends_timeframe_changed", properties: [
            "timeframe": timeFrame
        ])
    }

    func trackAIAnalysisRequested(filter: String) {
        PostHogSDK.shared.capture("ai_analysis_requested", properties: [
            "filter": filter
        ])
    }

    func trackAIAnalysisCompleted(filter: String, dataPoints: Int) {
        PostHogSDK.shared.capture("ai_analysis_completed", properties: [
            "filter": filter,
            "data_points": dataPoints
        ])
    }

    // MARK: - Tab Navigation
    func trackTabSwitched(fromTab: String, toTab: String) {
        PostHogSDK.shared.capture("tab_switched", properties: [
            "from_tab": fromTab,
            "to_tab": toTab
        ])
    }

    // MARK: - Meet Management
    func trackMeetUpdated(meetName: String, meetDate: String) {
        PostHogSDK.shared.capture("meet_updated", properties: [
            "meet_name": meetName,
            "meet_date": meetDate
        ])
    }

    func trackMeetDaysUpdated(trainingDaysCount: Int) {
        PostHogSDK.shared.capture("meet_days_updated", properties: [
            "training_days_count": trainingDaysCount
        ])
    }

    // MARK: - Notifications
    func trackNotificationPermissionRequested() {
        PostHogSDK.shared.capture("notification_permission_requested")
    }

    func trackNotificationPermissionGranted() {
        PostHogSDK.shared.capture("notification_permission_granted")
    }

    func trackNotificationPermissionDenied() {
        PostHogSDK.shared.capture("notification_permission_denied")
    }

    func trackNotificationEnabled(enabled: Bool) {
        PostHogSDK.shared.capture("notification_enabled", properties: [
            "enabled": enabled
        ])
    }

    func trackNotificationSettingsViewed() {
        PostHogSDK.shared.capture("notification_settings_viewed")
    }

    func notificationTrainingDaysUpdated(trainingDaysCount: Int) {
        PostHogSDK.shared.capture("notification_training_days_updated", properties: [
            "training_days_count": trainingDaysCount
        ])
    }

    // MARK: - Settings
    func trackSettingsViewed() {
        PostHogSDK.shared.capture("settings_viewed")
    }

    func trackDataExported(format: String) {
        PostHogSDK.shared.capture("data_exported", properties: [
            "format": format
        ])
    }

    func trackCustomerSupportAccessed() {
        PostHogSDK.shared.capture("customer_support_accessed")
    }

    func trackFeedbackSubmitted() {
        PostHogSDK.shared.capture("feedback_submitted")
    }

    func trackGitHubLinkOpened() {
        PostHogSDK.shared.capture("github_link_opened")
    }

    func trackAllDataDeleted() {
        PostHogSDK.shared.capture("all_data_deleted")
    }

    // MARK: - App Lifecycle
    func trackAppOpened(fromNotification: Bool = false) {
        PostHogSDK.shared.capture("app_opened", properties: [
            "from_notification": fromNotification
        ])
    }

    // MARK: - Monetization
    func trackSubscriptionStarted(tier: String) {
        PostHogSDK.shared.capture("subscription_started", properties: [
            "tier": tier
        ])
    }

    func trackSubscriptionCancelled() {
        PostHogSDK.shared.capture("subscription_cancelled")
    }

    func trackSubscriptionRestored() {
        PostHogSDK.shared.capture("subscription_restored")
    }

    func trackCustomerCenterViewed() {
        PostHogSDK.shared.capture("customer_center_viewed")
    }

    // MARK: - Content Sharing
    func trackContentShared(type: String, method: String) {
        PostHogSDK.shared.capture("content_shared", properties: [
            "type": type,
            "method": method
        ])
    }

    // MARK: - User Properties
    func setUserProperties(_ properties: [String: Any]) {
        PostHogSDK.shared.capture("$set", properties: properties)
    }

    func setOnboardingCompleted(_ completed: Bool) {
        setUserProperties(["onboarding_completed": completed])
    }

    func setNotificationEnabled(_ enabled: Bool) {
        setUserProperties(["notification_enabled": enabled])
    }
}
