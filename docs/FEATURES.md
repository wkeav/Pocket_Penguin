# Pocket Penguin - Feature Documentation

Current features and implementation status.

> **Development Status:** This project is in early development. Most features are UI mockups only.

---

## Table of Contents

- [Implemented Features](#implemented-features)
- [UI Features (No Backend)](#ui-features-no-backend)
- [In Development](#in-development)
- [Planned Features](#planned-features)

---

## Implemented Features

### Backend Database Models

**User Management:**
- Custom User model with UUID primary keys
- Email-based authentication system
- Email verification token system  
- Password reset token system with expiration
- User profile fields (bio, profile picture, date of birth)
- Security features:
  - Failed login attempt tracking
  - Account locking mechanism
  - IP address tracking
  - Secure password hashing (PBKDF2)

**Game Profile System:**
- UserGameProfile model with OneToOne relationship to User
- Fish coins (in-game currency)
- User level tracking
- Streak day counter
- Total habits and completed tasks counters
- JSON-based notification settings

---

### Frontend UI (No Backend Connection)

**Screens Built:**
- Home Screen - Dashboard view
- Habits Screen - Habit list interface
- Calendar Screen - Calendar view for tracking
- Journal Screen - Journal entry interface
- Progress Screen - Progress visualization
- Social Screen - Social features interface
- Achievements Screen - Achievements display
- Todo Screen - Todo list interface

**Theme System:**
- Dark mode support
- Light mode support
- Consistent color scheme
- iOS-style components
- Responsive design helpers

**Platform Support:**
- Web (Chrome) - UI renders correctly
- iOS (macOS) - UI renders correctly with safe area handling

---

### Development Infrastructure

**Backend:**
- Django 4.2.7 project configured
- Django REST Framework installed
- CORS headers configured
- Admin panel accessible
- SQLite database
- Gunicorn for production

**Frontend:**
- Flutter 3.16.9 configured
- Dart 3.2.6+
- HTTP package installed
- Provider package installed (not yet used)
- Shared preferences installed (not yet used)

**DevOps:**
- GitHub Actions CI/CD pipeline
  - Flutter analysis
  - Web build testing
  - iOS compatibility testing
- Docker configuration
- Git version control

---

## UI Features (No Backend)

These features have UI built but NO backend functionality:

### Habit Tracking (UI Only)

**What You See:**
- Habit list screen
- Habit creation interface
- Habit completion checkboxes
- Calendar view

**What Doesn't Work:**
- No actual habit creation
- No data persistence
- No streak calculation
- No backend storage
- Using mock/dummy data

---

### Calendar View (UI Only)

**What You See:**
- Monthly calendar display
- Date selection
- Visual layout

**What Doesn't Work:**
- No habit completion tracking
- No data display on calendar
- No date-based filtering

---

### Journal (UI Only)

**What You See:**
- Journal entry form
- Entry list display

**What Doesn't Work:**
- No entry creation
- No data persistence
- No mood tracking
- No entry retrieval

---

### Progress Analytics (UI Only)

**What You See:**
- Progress screen layout
- Chart placeholders

**What Doesn't Work:**
- No actual data
- No statistics calculation
- No charts/graphs
- No completion rates

---

### Penguin Avatar (Not Implemented)

**Status:** Not started

- No penguin display
- No avatar customization
- No evolution system
- No reactions to progress

---

### Todo Lists (UI Only)

**What You See:**
- Todo screen layout

**What Doesn't Work:**
- No todo creation
- No completion tracking
- No data persistence

---

## In Development

### User Authentication

**Backend:**
- User model created
- Security features implemented
- Registration serializer (partial)
- No ViewSets/API endpoints
- No JWT implementation
- No email verification flow
- No password reset flow

**Frontend:**
- No login screen
- No registration screen
- No authentication state management

---

### API Development

**Current State:**
- Django REST Framework configured
- CORS enabled
- Basic "Hello World" endpoint
- No authentication endpoints
- No CRUD endpoints for habits
- No CRUD endpoints for todos
- No CRUD endpoints for journal

---

## Planned Features

> These are future features, not yet started.

### User Features

- **Habit Tracking**
  - Create, edit, delete habits
  - Mark habits complete
  - Streak tracking
  - Habit history
  
- **Todo Management**
  - Create task lists
  - Task completion
  - Due dates
  - Priorities

- **Journal Entries**
  - Daily reflections
  - Mood tracking
  - Entry search
  - Export entries

### Gamification

- **Penguin Companion**
  - Dynamic avatar
  - Mood changes based on progress
  - Customization options
  - Evolution stages

- **Rewards System**
  - Fish coins
  - Level progression
  - Achievements
  - Unlockables

### Social Features

- Friend connections
- Progress sharing
- Leaderboards
- Challenges

### AI Features

- Habit recommendations
- Pattern analysis
- Smart scheduling
- Personalized tips

### Advanced Features

- Food scanner
- Wearable integration
- Push notifications
- Offline mode

---

## What You Can Actually Do Right Now

### Backend

1. **Run Django Server**
   ```bash
   python manage.py runserver
   ```

2. **Access Admin Panel**
   - Go to: `http://127.0.0.1:8000/admin/`
   - Create/view users
   - Manage user game profiles

3. **View Hello World**
   - Go to: `http://127.0.0.1:8000/`
   - See "Hello World" message

### Frontend

1. **Run Flutter App**
   ```bash
   flutter run -d chrome  # Web
   flutter run -d macos   # iOS (macOS)
   ```

2. **Navigate UI**
   - Explore all screens
   - Test dark/light mode
   - View UI components

3. **What Won't Work**
   - Creating habits (no backend)
   - Logging in (no auth)
   - Saving data (no API)
   - Any data persistence

---

## Development Priorities

To make this app functional, development should focus on:

### Phase 1: Authentication (Priority: HIGH)
1. Complete UserRegistrationSerializer
2. Create registration ViewSet/endpoint
3. Create login ViewSet with JWT
4. Add authentication to frontend
5. Implement login/register screens in Flutter

### Phase 2: Core Functionality (Priority: HIGH)
1. Create Habit model
2. Implement Habit CRUD API
3. Create Todo model
4. Implement Todo CRUD API
5. Connect Flutter to backend APIs
6. Implement state management (Provider)

### Phase 3: Features (Priority: MEDIUM)
1. Journal model and API
2. Progress statistics calculation
3. Streak tracking logic
4. Calendar data integration

### Phase 4: Polish (Priority: LOW)
1. Penguin avatar implementation
2. Rewards system
3. Achievements
4. Social features

---

**Questions?** Open an issue: https://github.com/wkeav/Pocket_Penguin/issues
