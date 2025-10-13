# Pocket Penguin - Setup Guide

Complete installation guide for Pocket Penguin development.

> **Development Status:** This app is in early development. You'll be able to run it, but most features don't work yet.

---

## Table of Contents

- [System Requirements](#system-requirements)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [Verification](#verification)
- [Common Issues](#common-issues)

---

## System Requirements

### Operating System
- **macOS**: 10.14+ (for iOS development)
- **Windows**: 10+ (web development only)
- **Linux**: Ubuntu 18.04+ (web development only)

### Required Software
- **Python**: 3.11 or higher
- **Flutter**: 3.16.9 (exact version)
- **Dart**: 3.2.6+ (included with Flutter)
- **Git**: Latest stable version
- **Xcode**: 12.0+ (macOS only, for iOS)
- **Chrome**: Latest (for web testing)

### Optional Software
- **Docker Desktop**: For containerized development
- **VSCode** or **Android Studio**: Recommended IDEs
- **Postman**: For API testing (when API exists)

---

## Backend Setup

### 1. Clone the Repository

```bash
git clone https://github.com/wkeav/Pocket_Penguin.git
cd Pocket_Penguin
```

### 2. Navigate to Backend Directory

```bash
cd backend
```

### 3. Create Virtual Environment

**macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

You should see `(venv)` in your terminal prompt.

### 4. Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**For development (includes testing/linting tools):**
```bash
pip install -r requirements-dev.txt
```

### 5. Run Migrations

This creates the database and tables:

```bash
python manage.py migrate
```

Expected output:
```
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying penguin_app.0001_initial... OK
  ...
```

### 6. Create Admin User (Optional but Recommended)

```bash
python manage.py createsuperuser
```

Follow prompts:
- **Email**: your-email@example.com
- **Username**: admin
- **Password**: (enter a secure password)

### 7. Run Development Server

```bash
python manage.py runserver
```

You should see:
```
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

### 8. Verify Backend Works

**In a new terminal:**
```bash
curl http://127.0.0.1:8000/
# Output: Hello World
```

**Or open in browser:**
- Go to: `http://127.0.0.1:8000/`
- You should see: "Hello World"

**Access admin panel:**
- Go to: `http://127.0.0.1:8000/admin/`
- Login with superuser credentials
- You can view/create Users and User Game Profiles

---

## Frontend Setup

### 1. Check Flutter Installation

```bash
flutter --version
```

Expected output:
```
Flutter 3.16.9 • channel stable
Framework • revision 41456452f2
Engine • revision f40e976bed
Tools • Dart 3.2.6 • DevTools 2.28.5
```

**If Flutter is not installed:**
1. Download from: https://docs.flutter.dev/get-started/install
2. Install version **3.16.9** (stable channel)
3. Add to PATH

### 2. Run Flutter Doctor

```bash
flutter doctor
```

Fix any issues indicated by the tool.

**Common fixes:**
- Install Xcode (macOS)
- Accept Android licenses: `flutter doctor --android-licenses`
- Install Chrome for web development

### 3. Navigate to Frontend Directory

```bash
cd frontend/pocket_penguin_app
```

### 4. Install Dependencies

```bash
flutter pub get
```

Expected output:
```
Running "flutter pub get" in pocket_penguin_app...
Resolving dependencies... 
+ cupertino_icons 1.0.2
+ http 1.2.0
+ provider 6.1.5+1
+ shared_preferences 2.2.3
...
Got dependencies!
```

### 5. Enable Platforms

**For Web:**
```bash
flutter config --enable-web
```

**For iOS (macOS only):**
```bash
flutter config --enable-macos-desktop
```

### 6. Check Available Devices

```bash
flutter devices
```

You should see:
```
Chrome (web) • chrome • web-javascript • Google Chrome
macOS (desktop) • macos • darwin-x64 • macOS (if on Mac)
```

### 7. Run the Application

**Web (Chrome):**
```bash
flutter run -d chrome
```

**iOS (macOS testing):**
```bash
flutter run -d macos
```

The app should launch and you can navigate through the UI screens.

> **Important:** The UI works, but nothing is connected to the backend yet. You can't create actual habits, save data, or login.

---

## Verification

### Backend Verification

1. **Server is running:**
   ```bash
   curl http://127.0.0.1:8000/
   # Output: Hello World
   ```

2. **Admin panel works:**
   - Navigate to: `http://127.0.0.1:8000/admin/`
   - Login with superuser credentials
   - You should see Django admin interface

3. **Database exists:**
   ```bash
   cd backend
   ls db.sqlite3
   # Should show: db.sqlite3
   ```

4. **Run tests:**
   ```bash
   python manage.py test
   ```

### Frontend Verification

1. **Flutter is configured:**
   ```bash
   flutter doctor
   # All important checks should pass
   ```

2. **Dependencies installed:**
   ```bash
   cd frontend/pocket_penguin_app
   flutter pub get
   # Should complete without errors
   ```

3. **Code analysis passes:**
   ```bash
   flutter analyze
   # Should show: No issues found!
   ```

4. **App builds:**
   ```bash
   flutter build web --release
   # Should complete successfully
   ```

---

## Common Issues

### Backend Issues

**Problem:** `ModuleNotFoundError: No module named 'django'`

**Solution:**
```bash
# Ensure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

---

**Problem:** `django.db.utils.OperationalError: no such table: users`

**Solution:**
```bash
# Run migrations
python manage.py migrate

# If still failing, delete database and start fresh
rm db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

---

**Problem:** `Error: That port is already in use`

**Solution:**
```bash
# Find and kill process on port 8000
lsof -ti:8000 | xargs kill -9  # macOS/Linux

# Or use different port
python manage.py runserver 8001
```

---

**Problem:** `ImportError: cannot import name 'get_user_model'`

**Solution:**
```bash
# Clear Python cache
find . -type d -name __pycache__ -exec rm -r {} +
find . -type f -name "*.pyc" -delete

# Restart server
python manage.py runserver
```

---

### Frontend Issues

**Problem:** `flutter: command not found`

**Solution:**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Make permanent (macOS/Linux)
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Windows: Add to System Environment Variables
```

---

**Problem:** `pub get failed`

**Solution:**
```bash
# Clear pub cache
flutter pub cache repair

# Try again
flutter clean
flutter pub get
```

---

**Problem:** `Version mismatch: Dart SDK 3.x.x`

**Solution:**
```bash
# Switch to correct Flutter version
flutter channel stable
flutter upgrade  # Or: flutter downgrade 3.16.9
flutter doctor
```

---

**Problem:** `Web build fails`

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release

# If still failing, check for errors in code
flutter analyze
```

---

**Problem:** `CocoaPods not installed` (macOS)

**Solution:**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Install pods for iOS
cd ios
pod install
cd ..

# Rebuild
flutter clean
flutter pub get
flutter run
```

---

### macOS Specific (iOS Development)

1. **Install Xcode** from App Store (this takes a while!)

2. **Install Command Line Tools:**
   ```bash
   xcode-select --install
   ```

3. **Accept Xcode license:**
   ```bash
   sudo xcodebuild -license accept
   ```

4. **Install CocoaPods:**
   ```bash
   sudo gem install cocoapods
   ```

5. **Verify:**
   ```bash
   flutter doctor
   # iOS toolchain should pass
   ```

---

## What Works vs What Doesn't

### What Works After Setup

**Backend:**
- Django server runs
- Admin panel accessible
- Can create users via admin
- Can create user game profiles via admin
- Database models exist
- "Hello World" endpoint works

**Frontend:**
- Flutter app launches
- All UI screens display
- Navigation works
- Dark/light mode switching
- Responsive design

### What Doesn't Work

**Backend:**
- No API endpoints (except Hello World)
- No authentication API
- No habit/todo/journal models
- No ViewSets

**Frontend:**
- No backend connection
- Can't create habits
- Can't save data
- No login/register screens
- No actual data persistence

**Integration:**
- Frontend and backend not connected
- No API calls
- No authentication flow

---

## Next Steps for Developers

After setup, if you want to contribute:

1. **Backend Development:**
   - Complete UserRegistrationSerializer
   - Create authentication ViewSets
   - Implement JWT authentication
   - Create Habit/Todo/Journal models

2. **Frontend Development:**
   - Create API service layer
   - Implement state management
   - Build login/register screens
   - Connect screens to backend

3. **Testing:**
   - Write backend unit tests
   - Write frontend widget tests
   - Integration testing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

---

## Development Tools Setup

### VSCode Extensions

**Backend (Python):**
- Python (Microsoft)
- Pylance
- Django (Baptiste Darthenay)

**Frontend (Flutter):**
- Flutter (Dart Code)
- Dart (Dart Code)
- Flutter Widget Snippets

### Recommended Settings

**VSCode settings.json:**
```json
{
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.rulers": [80]
  }
}
```

---

## Docker Setup (Optional)

### Backend Docker

**Build:**
```bash
cd backend
docker build -t pocket-penguin-backend .
```

**Run:**
```bash
docker run -p 8000:8000 pocket-penguin-backend
```

**Note:** Docker setup exists but API development should be done locally for faster iteration.

---

**Need help?** Open an issue: https://github.com/wkeav/Pocket_Penguin/issues
