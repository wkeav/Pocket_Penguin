# Pocket Penguin - API Documentation

Current API reference for Pocket Penguin backend.

> **Development Status:** API is in early development. Most endpoints are NOT yet implemented.

---

## Table of Contents

- [Current Status](#current-status)
- [Implemented Endpoints](#implemented-endpoints)
- [Database Models](#database-models)
- [Planned API Structure](#planned-api-structure)

---

## Current Status

### What's Working

- Django server runs successfully
- Database models defined
- Admin panel accessible
- Basic "Hello World" endpoint

### What's NOT Working

- No authentication endpoints
- No user registration/login API
- No habit endpoints
- No todo endpoints
- No journal endpoints
- No API documentation (Swagger/OpenAPI)

---

## Implemented Endpoints

### Health Check / Hello World

Simple endpoint to verify server is running.

**Endpoint:** `GET /`

**Authentication:** None required

**Response:** `200 OK`
```
Hello World
```

**Example:**
```bash
curl http://127.0.0.1:8000/
# Output: Hello World
```

---

### Django Admin

Access Django admin panel for database management.

**Endpoint:** `GET /admin/`

**Authentication:** Admin credentials required

**Access:**
- Navigate to: `http://127.0.0.1:8000/admin/`
- Login with superuser credentials

**Available Models:**
- Users
- User Game Profiles

---

## Database Models

### User Model

Custom user model with enhanced security features.

**Fields:**
```python
{
  "id": "uuid",                      # UUID primary key
  "email": "string",                 # Unique, used for login
  "username": "string",              # Display name
  "password": "hashed_string",       # PBKDF2 hashed
  "is_verified": "boolean",          # Email verification status
  "verification_token": "string",    # Email verification token
  "password_reset_token": "string",  # Password reset token
  "password_reset_expires": "datetime",
  "profile_picture": "url",
  "bio": "text",
  "date_of_birth": "date",
  "failed_login_attempts": "integer",
  "locked_until": "datetime",
  "last_login_ip": "ip_address",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

**Access:** Via Django Admin only (no API endpoint yet)

---

### UserGameProfile Model

User's game statistics and settings.

**Fields:**
```python
{
  "id": "integer",                   # Auto-increment primary key
  "user": "uuid",                    # Foreign key to User
  "fish_coins": "integer",           # In-game currency (default: 0)
  "level": "integer",                # User level (default: 1)
  "streak_days": "integer",          # Current streak (default: 0)
  "total_habits": "integer",         # Total habits created (default: 0)
  "completed_tasks": "integer",      # Total tasks completed (default: 0)
  "notification_settings": "json",   # Notification preferences
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

**Relationship:** OneToOne with User model

**Access:** Via Django Admin only (no API endpoint yet)

---

## Planned API Structure

> **Note:** These endpoints are NOT implemented yet. This is the planned structure.

### Base URL

**Development:** `http://127.0.0.1:8000/api/`  
**Production:** TBD

### Authentication (Planned)

```
POST   /api/auth/register/          # Register new user
POST   /api/auth/login/             # Login and get token
POST   /api/auth/logout/            # Logout
POST   /api/auth/refresh/           # Refresh access token
POST   /api/auth/verify-email/      # Verify email address
POST   /api/auth/reset-password/    # Request password reset
POST   /api/auth/reset-password-confirm/  # Confirm password reset
```

### User (Planned)

```
GET    /api/users/me/               # Get current user profile
PUT    /api/users/me/               # Update profile
PATCH  /api/users/me/               # Partial update
DELETE /api/users/me/               # Delete account
GET    /api/users/me/game-profile/  # Get game profile
```

### Habits (Planned)

```
GET    /api/habits/                 # List user's habits
POST   /api/habits/                 # Create habit
GET    /api/habits/{id}/            # Get habit detail
PUT    /api/habits/{id}/            # Update habit
PATCH  /api/habits/{id}/            # Partial update
DELETE /api/habits/{id}/            # Delete habit
POST   /api/habits/{id}/complete/   # Mark complete
GET    /api/habits/{id}/history/    # Get completion history
```

### Todos (Planned)

```
GET    /api/todos/                  # List todos
POST   /api/todos/                  # Create todo
GET    /api/todos/{id}/             # Get todo detail
PUT    /api/todos/{id}/             # Update todo
DELETE /api/todos/{id}/             # Delete todo
POST   /api/todos/{id}/complete/    # Mark complete
```

### Journal (Planned)

```
GET    /api/journal/                # List journal entries
POST   /api/journal/                # Create entry
GET    /api/journal/{id}/           # Get entry detail
PUT    /api/journal/{id}/           # Update entry
DELETE /api/journal/{id}/           # Delete entry
```

### Progress (Planned)

```
GET    /api/progress/stats/         # Get overall stats
GET    /api/progress/streaks/       # Get streak information
GET    /api/progress/charts/        # Get chart data
```

---

## Development Roadmap

### Phase 1: Authentication (Current Priority)

- [ ] Implement user registration endpoint
- [ ] Implement login endpoint with JWT
- [ ] Email verification flow
- [ ] Password reset flow
- [ ] Token refresh mechanism

### Phase 2: Core Features

- [ ] Create Habit model
- [ ] Implement habit CRUD endpoints
- [ ] Create Todo model  
- [ ] Implement todo CRUD endpoints
- [ ] Habit completion tracking

### Phase 3: Extended Features

- [ ] Create Journal model
- [ ] Implement journal endpoints
- [ ] Progress statistics endpoints
- [ ] Streak calculation logic

### Phase 4: Polish

- [ ] API documentation (Swagger)
- [ ] Rate limiting
- [ ] Caching layer
- [ ] Performance optimization

---

## How to Test Current API

### 1. Start Django Server

```bash
cd backend
source venv/bin/activate  # macOS/Linux
python manage.py runserver
```

### 2. Test Hello World Endpoint

```bash
curl http://127.0.0.1:8000/
# Output: Hello World
```

### 3. Access Admin Panel

1. Create superuser (if not already created):
   ```bash
   python manage.py createsuperuser
   ```

2. Navigate to: `http://127.0.0.1:8000/admin/`

3. Login with superuser credentials

4. You can now:
   - View/create/edit Users
   - View/create/edit User Game Profiles
   - Explore database tables

---

## Development Notes

### Current Serializers

**UserRegistrationSerializer** (Partial):
- Located in: `backend/penguin_app/serializers.py`
- Status: Incomplete
- Has: Password validation, email validation
- Missing: Complete username validation, create() method

### No ViewSets Yet

- No API views defined in `views.py`
- Need to create ViewSets for:
  - User registration/login
  - Habits
  - Todos
  - Journal

### No URLs Configured

- Only admin and root path exist
- Need to add `/api/` URL routing
- Need to include DRF router

---

## Example: How API Will Work (Future)

### User Registration Flow (Planned)

```bash
# 1. Register user
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "penguin_user",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!"
  }'

# Response:
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "username": "penguin_user",
  "is_verified": false,
  "created_at": "2025-01-15T10:00:00Z"
}

# 2. Login
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'

# Response:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "username": "penguin_user"
  }
}
```

---

## Contributing

Want to help implement the API? See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

**Priority tasks:**
1. Complete UserRegistrationSerializer
2. Create login/registration ViewSets
3. Implement JWT authentication
4. Create Habit model and endpoints

---

**Questions?** Open an issue: https://github.com/wkeav/Pocket_Penguin/issues

