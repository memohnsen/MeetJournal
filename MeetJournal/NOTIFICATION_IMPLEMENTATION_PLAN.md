# Notification Implementation Plan

## Overview
Based on your training days schedule from the database, we'll implement three types of notifications:

1. **Daily Check-In Notification** - At the user's training time
2. **Session Reflection Notification** - 2 hours after training time
3. **Competition Reflection Notification** - At 5pm on meet day

All notifications will only fire if the user hasn't submitted the form for that day.

### AppStorage vs Database
**Why use AppStorage for notification scheduling?**
- Training days and meet date are set during onboarding and cannot be updated through the UI
- AppStorage provides offline access to notification schedule data
- Faster scheduling - no need to fetch from database every time
- Reduces database load
- Notifications continue to work even if database is temporarily unavailable
- Since there's no UI to update training_days after onboarding, AppStorage is appropriate

**What data comes from database?**
- Actual form submissions (check-in, session, comp reports) - queried to check if user already submitted today
- User profile data - fetched once after onboarding and stored to AppStorage

**What data stays in AppStorage?**
- Training days and times (for scheduling notifications)
- Meet date and name (for scheduling competition notification)
- Notifications enabled/disabled flag

---

## Implementation Architecture

### New File Structure
```
MeetJournal/Frontend/Logic/NotificationManager.swift
MeetJournal/Frontend/Views/Components/NotificationPermissionModal.swift (optional)
```

### Modified Files
```
MeetJournal/Frontend/Views/Tabs/HomeView.swift (add AppStorage storage logic)
MeetJournal/Frontend/Views/Tabs/SettingsView.swift (add notification toggle)
```

### AppStorage Keys
Add the following AppStorage values to persist notification settings and training schedule locally:

```swift
@AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
@AppStorage("trainingDays") var trainingDays: String = ""  // JSON-encoded [String: String]
@AppStorage("meetDate") var meetDate: String = ""  // "yyyy-MM-dd" format
@AppStorage("meetName") var meetName: String = ""
```

### Key Components

#### 1. NotificationManager Class
- Singleton pattern for centralized notification control
- Methods:
  - `requestPermission()` - Request notification permission from user
  - `scheduleNotifications()` - Main entry point to schedule all notifications
  - `cancelAll()` - Cancel all scheduled notifications
  - `scheduleDailyNotifications(trainingDays: [String: String])` - Schedule daily check-in and session notifications
  - `scheduleCompNotification(meetDate: String)` - Schedule competition reflection notification
- Integrates with UserNotifications framework
- Reads training_days from AppStorage (not database) for scheduling

#### 2. DB Check Methods
- `hasCheckInToday()` - Queries `journal_daily_checkins` for today's entry
- `hasSessionToday()` - Queries `journal_session_report` for today's entry
- `hasCompToday()` - Queries `journal_comp_report` for meet date entry

#### 3. Scheduling Logic (from AppStorage)
```
For each training_day in AppStorage.trainingDays:
  - Parse day name (Monday, Tuesday, etc.)
  - Parse time (e.g., "4:00 PM")
  - Convert to Date with user's timezone
  - Schedule check-in notification at that time (repeats weekly)
  - Schedule session notification at time + 2 hours (repeats weekly)
  - Only schedule if no existing submission for today
```

#### 4. Meet Day Notification (from AppStorage)
```
If today == AppStorage.meetDate:
  - Schedule comp reflection at 5:00 PM user's timezone (one-time)
  - Only if no comp report exists for this meet
```

#### 5. Settings Toggle
- Add notification toggle switch in SettingsView
- Toggles `@AppStorage("notificationsEnabled")`
- When enabled: Request permissions (if needed) and schedule notifications
- When disabled: Cancel all scheduled notifications

---

## Integration Points

### HomeView.swift (after onboarding)
- Show notification permission explanation modal on first visit after onboarding completes
- Request permissions on user acceptance
- **Store training_days to AppStorage** when user data is fetched from database (first time after onboarding)
- **Store meet_date and meet_name to AppStorage** when user data is fetched
- Call `NotificationManager.shared.scheduleNotifications()` after permissions granted
- Use AppStorage `notificationsEnabled` flag to check if we should prompt user

### HomeView `.task` block
- After fetching user data and permissions are enabled
- Check if `@AppStorage("trainingDays")` is empty (first-time setup)
- If empty, encode and store `user.training_days`, `user.next_competition_date`, and `user.next_competition` to AppStorage
- If `notificationsEnabled` is true, schedule notifications from AppStorage values

### SettingsView.swift
- Add notification toggle section with `@AppStorage("notificationsEnabled")`
- When user enables notifications:
  - Request permission if not already granted
  - Call `NotificationManager.shared.scheduleNotifications()`
- When user disables notifications:
  - Call `NotificationManager.shared.cancelAll()`
- Display current notification settings (training days/times stored in AppStorage)

### Meet Date Update Flow
- When user updates meet date in HomeView (editMeetSheetShown):
  - Update AppStorage `meetDate` and `meetName`
  - Cancel all existing notifications
  - Re-schedule notifications from AppStorage values if `notificationsEnabled` is true

---

## Timezone Handling

- Use `Calendar.current.timeZone` to get user's local timezone
- Store times as user's local time in training_days
- When scheduling, ensure dates are created in the correct timezone
- This keeps notifications firing at the correct local time regardless of device location changes

---

## Notification Content

### Check-In
```
Title: "Time for your daily check-in!"
Body: "Track your readiness before today's session."
```

### Session Reflection
```
Title: "How did your session go?"
Body: "Reflect on your training to optimize future performance."
```

### Competition
```
Title: "Competition Day Analysis"
Body: "Complete your post-competition reflection."
```

---

## Data Model References

### UserModel.swift:20
```swift
var training_days: [String: String]
```
- Key: Day name (e.g., "Monday")
- Value: Time string (e.g., "4:00 PM")

### OnboardingView.swift:309-310
Time options available from 4:00 AM to 10:00 PM

### AppStorage Encoding/Decoding
Since AppStorage requires String/Bool/Int/etc., we'll encode the training_days dictionary as JSON:

```swift
// Encoding
if let data = try? JSONEncoder().encode(user.training_days),
   let jsonString = String(data: data, encoding: .utf8) {
    trainingDays = jsonString
}

// Decoding
if let data = trainingDays.data(using: .utf8),
   let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
    return decoded
}
```

---

## Implementation Tasks

### Phase 1: Core Notification Infrastructure
- [ ] Create NotificationManager.swift with core notification handling (permission request, scheduling, cancellation)
- [ ] Add DB check methods in NotificationManager to verify if form already submitted for today (check-in, session, comp)
- [ ] Add timezone handling to convert stored times to user's local timezone for scheduling

### Phase 2: Scheduling Logic
- [ ] Implement scheduleDailyNotifications(trainingDays: [String: String]) method - parse from AppStorage, schedule check-in at training time + session reflection 2hrs later (repeating weekly)
- [ ] Implement scheduleCompNotification(meetDate: String) method - schedule comp reflection notification at 5pm on meet day (one-time)
- [ ] Implement scheduleNotifications() main method that calls both daily and comp schedulers

### Phase 3: AppStorage Integration
- [ ] Add @AppStorage keys in NotificationManager: notificationsEnabled, trainingDays, meetDate, meetName
- [ ] In HomeView .task: Store user.training_days to AppStorage if not already set (encode [String: String] as JSON string)
- [ ] In HomeView .task: Store user.next_competition_date and user.next_competition to AppStorage
- [ ] Update meet date editing in HomeView to also update AppStorage values

### Phase 4: User Permissions
- [ ] Create notification permission explanation view/modal to explain benefits before requesting
- [ ] Integrate notification permission prompt in HomeView after onboarding completes
- [ ] Check @AppStorage("notificationsEnabled") to determine if we should prompt user

### Phase 5: Settings Integration
- [ ] Add notification toggle switch in SettingsView with @AppStorage("notificationsEnabled")
- [ ] Handle toggle on state: request permission and schedule notifications
- [ ] Handle toggle off state: cancel all notifications
- [ ] Display current training days and times in Settings (read from AppStorage)

### Phase 6: Testing & Edge Cases
- [ ] Test notification scheduling with different timezone configurations
- [ ] Test notification rescheduling when user toggles settings on/off
- [ ] Test meet date update flow cancels and reschedules notifications

---

## Testing Checklist

- [ ] Check-in notification fires at correct training time
- [ ] Session notification fires 2 hours later
- [ ] Notifications don't fire if form already submitted
- [ ] Comp notification fires at 5pm on meet day
- [ ] Timezone changes handled correctly
- [ ] Notification rescheduling works after user updates settings
- [ ] Permission prompt appears after onboarding in HomeView
- [ ] Notifications properly link to the correct screens (CheckInView, WorkoutReflectionView, CompReflectionView)
- [ ] Training days/times are correctly stored to AppStorage from database
- [ ] Settings toggle properly enables/disables notifications
- [ ] Toggling notifications OFF cancels all scheduled notifications
- [ ] Toggling notifications ON reschedules all notifications from AppStorage
- [ ] Meet date update properly updates AppStorage and reschedules comp notification
- [ ] AppStorage values persist across app restarts
- [ ] Notifications still work if database is unavailable (AppStorage fallback)

---

## User Flow

1. User completes onboarding (sets training_days, meet date, etc.)
2. User navigates to HomeView for the first time
3. HomeView .task block fetches user data from database
4. User training_days, meet_date, and meet_name are stored to AppStorage (one-time setup)
5. App shows permission explanation modal explaining benefits of notifications
6. User grants notification permission, sets @AppStorage("notificationsEnabled") = true
7. App schedules notifications based on AppStorage values (not database)
8. Notifications fire at appropriate times, linking to relevant forms
9. User can toggle notifications on/off in SettingsView
10. When user updates meet date in HomeView, AppStorage is updated and notifications are rescheduled

## Notification Scheduling Triggers

Notifications should be scheduled/rescheduled when:

1. **First-time setup** - After onboarding, when user data is stored to AppStorage
2. **App launch** - Check if `notificationsEnabled` is true, reschedule to ensure consistency
3. **Settings toggle ON** - User enables notifications in SettingsView
4. **Settings toggle OFF** - User disables notifications in SettingsView (cancel all)
5. **Meet date update** - User edits meet date in HomeView (cancel and reschedule comp notification)
6. **Permission granted** - After user accepts notification permission prompt

---

## Edge Cases to Handle

- User declines initial notification permission (AppStorage notificationsEnabled = false)
- User grants permission but later revokes it in system settings
- User changes timezone settings (notifications should still fire at correct local time)
- User toggles notifications off in Settings, then back on (should reschedule)
- User toggles notifications off, updates training data in database, then toggles back on
- App is backgrounded/killed when notification should fire (iOS handles this)
- Multiple devices logged in (clerk user) - notifications only on active device
- Daylight savings time changes
- AppStorage becomes corrupted or empty (should have fallback logic)
- User completes onboarding but training_days is empty in database
- Meet date is in the past (no comp notification should be scheduled)
