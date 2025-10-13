# Pocket Penguin - Troubleshooting Guide

Common issues and solutions for Pocket Penguin development.

---

## Table of Contents

- [Backend Issues](#backend-issues)
- [Frontend Issues](#frontend-issues)
- [Database Issues](#database-issues)
- [Docker Issues](#docker-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Getting Help](#getting-help)

---

## Backend Issues

### Django Not Found

**Error:** `ModuleNotFoundError: No module named 'django'`

**Solution:**
```bash
# Ensure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

---

### Database Errors

**Error:** `django.db.utils.OperationalError: unable to open database file`

**Solution:**
```bash
# Check file permissions
ls -la db.sqlite3

# If missing, run migrations
python manage.py migrate

# If corrupted, reset database
rm db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

---

### Port Already in Use

**Error:** `Error: That port is already in use.`

**Solution:**
```bash
# Find process using port 8000
lsof -ti:8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill the process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Or use a different port
python manage.py runserver 8001
```

---

### CORS Errors

**Error:** `Access to fetch at 'http://localhost:8000' has been blocked by CORS policy`

**Solution:**
```python
# backend/pocket_penguin/settings.py

# Ensure django-cors-headers is installed
pip install django-cors-headers

# Add to INSTALLED_APPS
INSTALLED_APPS = [
    ...
    'corsheaders',
]

# Add to MIDDLEWARE (must be before CommonMiddleware)
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    ...
]

# Configure allowed origins
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:8000",
]

# For development only (NOT production)
# CORS_ALLOW_ALL_ORIGINS = True
```

---

### Secret Key Errors

**Error:** `django.core.exceptions.ImproperlyConfigured: The SECRET_KEY setting must not be empty.`

**Solution:**
```bash
# Generate a new secret key
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Add to .env file
echo "SECRET_KEY=your-generated-key-here" >> backend/.env

# Update settings.py
from decouple import config
SECRET_KEY = config('SECRET_KEY')
```

---

### Import Errors

**Error:** `ImportError: cannot import name 'X' from 'Y'`

**Solution:**
```bash
# Clear Python cache
find . -type d -name __pycache__ -exec rm -r {} +
find . -type f -name "*.pyc" -delete

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

---

## Frontend Issues

### Flutter Command Not Found

**Error:** `flutter: command not found`

**Solution:**
```bash
# Check Flutter installation
which flutter

# Add Flutter to PATH (macOS/Linux)
export PATH="$PATH:/path/to/flutter/bin"
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Windows: Add to System Environment Variables
# System Properties → Environment Variables → Path → Add flutter/bin
```

---

### Pub Get Fails

**Error:** `pub get failed (server unavailable) -- attempting retry 1...`

**Solution:**
```bash
# Check internet connection
ping pub.dev

# Clear pub cache
flutter pub cache repair

# Try again
flutter clean
flutter pub get

# If still failing, use a VPN or change DNS
```

---

### Version Mismatch

**Error:** `The current Dart SDK version is 3.x.x. Because ... requires SDK version 3.2.6...`

**Solution:**
```bash
# Check current version
flutter --version

# Switch to stable channel
flutter channel stable

# Upgrade/downgrade to specific version
flutter upgrade  # Latest stable
# Or for specific version:
flutter downgrade 3.16.9

# Verify
flutter doctor
```

---

### Build Errors

**Error:** Various build errors

**Solution:**
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run

# For persistent issues, clear all caches
rm -rf build/
rm -rf .dart_tool/
flutter pub cache clean
flutter pub get
```

---

### Web Build Fails

**Error:** `Failed to compile application for the Web`

**Solution:**
```bash
# Ensure web is enabled
flutter config --enable-web

# Check for web support
flutter devices

# Build with verbose output
flutter build web --release --verbose

# Common fix: Update web packages
flutter pub upgrade
flutter pub get
```

---

### iOS Build Issues (macOS)

**Error:** `CocoaPods not installed`

**Solution:**
```bash
# Install CocoaPods
sudo gem install cocoapods

# If permission issues
sudo gem install cocoapods --user-install

# Install pods
cd ios
pod install
cd ..

# Rebuild
flutter clean
flutter pub get
flutter run
```

**Error:** `Xcode not installed or needs update`

**Solution:**
```bash
# Install from App Store
# Then install command line tools
xcode-select --install

# Accept license
sudo xcodebuild -license accept

# Verify
flutter doctor
```

---

## Database Issues

### Database Locked

**Error:** `database is locked`

**Solution:**
```bash
# Close all connections to database
# Stop Django server (Ctrl+C)

# Check for hanging processes
lsof db.sqlite3

# If found, kill them
kill -9 <PID>

# Restart server
python manage.py runserver
```

---

### Migration Conflicts

**Error:** `Conflicting migrations detected`

**Solution:**
```bash
# List migrations
python manage.py showmigrations

# Fake merge if needed
python manage.py migrate --fake <app_name> <migration_name>

# Or reset migrations (development only!)
rm -rf penguin_app/migrations/
python manage.py makemigrations penguin_app
python manage.py migrate
```

---

### Data Loss After Migration

**Solution:**
```bash
# Always backup before migrations
python manage.py dumpdata > backup.json

# If data lost, restore from backup
python manage.py loaddata backup.json
```

---

## Docker Issues

### Build Fails

**Error:** Docker build errors

**Solution:**
```bash
# Clear Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -t pocket-penguin-backend ./backend

# Check Dockerfile syntax
docker build -t test --target <stage-name> ./backend
```

---

### Container Won't Start

**Error:** Container exits immediately

**Solution:**
```bash
# Check container logs
docker ps -a
docker logs <container-id>

# Run interactively for debugging
docker run -it pocket-penguin-backend /bin/bash

# Check port conflicts
lsof -i :8000
```

---

### Volume Permission Issues

**Error:** Permission denied for volumes

**Solution:**
```bash
# Fix permissions (Linux/macOS)
sudo chown -R $USER:$USER ./

# Or run with user flag
docker run --user $(id -u):$(id -g) ...
```

---

## Platform-Specific Issues

### macOS Issues

**Xcode Build Errors:**
```bash
# Clean build folder
cd ios
rm -rf Pods/ Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

**Permission Issues:**
```bash
# Fix homebrew permissions
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib

# Fix Python permissions
sudo chown -R $(whoami) ~/.local
```

---

### Windows Issues

**Line Ending Issues:**
```bash
# Configure Git to use LF
git config --global core.autocrlf input

# Fix existing files
dos2unix <file>  # If dos2unix installed
# Or use VSCode to change line endings
```

**Path Too Long:**
```bash
# Enable long paths in Git
git config --system core.longpaths true

# Enable in Windows registry
# Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem
# Set LongPathsEnabled to 1
```

---

### Linux Issues

**Flutter Desktop:**
```bash
# Install required libraries
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

**Python SSL Errors:**
```bash
# Update certificates
sudo apt-get update
sudo apt-get install --reinstall ca-certificates
```

---

## Performance Issues

### Slow Backend Response

**Diagnosis:**
```bash
# Enable Django Debug Toolbar (development only)
pip install django-debug-toolbar

# Check database queries
python manage.py shell
from django.db import connection
print(len(connection.queries))
```

**Solutions:**
- Add database indexes
- Use select_related() / prefetch_related()
- Implement caching
- Optimize serializers

---

### Slow Frontend Performance

**Diagnosis:**
```dart
// Use Flutter DevTools
flutter run --profile
// Press 'P' to open DevTools
```

**Solutions:**
- Use const constructors where possible
- Implement lazy loading
- Optimize widget rebuilds
- Use RepaintBoundary for expensive widgets

---

## Environment Issues

### Environment Variables Not Loading

**Error:** Settings using default values instead of .env

**Solution:**
```bash
# Verify .env file location
ls -la backend/.env

# Install python-decouple
pip install python-decouple

# Update settings.py
from decouple import config
DEBUG = config('DEBUG', default=False, cast=bool)

# Restart server after .env changes
```

---

## Testing Issues

### Tests Failing

**Backend:**
```bash
# Run with verbose output
python manage.py test --verbosity=2

# Run specific test
python manage.py test penguin_app.tests.TestClassName.test_method

# Check test database
python manage.py test --keepdb
```

**Frontend:**
```bash
# Run with verbose output
flutter test --verbose

# Run specific test file
flutter test test/widget_test.dart

# Update golden files (if using)
flutter test --update-goldens
```

---

## Network Issues

### Cannot Connect Frontend to Backend

**Checklist:**
- [ ] Backend server is running (`http://127.0.0.1:8000/`)
- [ ] CORS is configured correctly
- [ ] Firewall is not blocking port 8000
- [ ] Using correct URL (localhost vs 127.0.0.1)
- [ ] No proxy interfering

**Debug:**
```bash
# Test backend directly
curl http://127.0.0.1:8000/

# Check from Flutter app
flutter run --verbose
```

---

## Getting Help

### Before Asking for Help

1. **Search existing issues**: https://github.com/wkeav/Pocket_Penguin/issues
2. **Check documentation**: Review relevant docs
3. **Run diagnostics**:
   ```bash
   # Backend
   python manage.py check
   
   # Frontend
   flutter doctor -v
   flutter analyze
   ```

### How to Ask for Help

**Include:**
- Operating system and version
- Python/Flutter versions
- Full error message with stack trace
- Steps to reproduce
- What you've already tried

**Template:**
```markdown
## Environment
- OS: macOS 13.0
- Python: 3.11.2
- Flutter: 3.16.9
- Django: 4.2.7

## Issue
Brief description

## Steps to Reproduce
1. ...
2. ...
3. ...

## Error Message
```
Full error with stack trace
```

## What I've Tried
- Tried X, result was Y
- Checked Z, found A
```

---

**Still stuck?** Open an issue: https://github.com/wkeav/Pocket_Penguin/issues

