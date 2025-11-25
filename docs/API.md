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
- User registration/login API

### What's NOT Working
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

> **Note:** These endpoints follow REST best practices:
> - Resources are nouns (users, tokens, habits)
> - HTTP methods are verbs (GET, POST, PUT, DELETE)
> - Authentication uses `/api/auth/token/` (industry standard)
> - User management uses `/api/users/` (RESTful)

### Base URL

**Development:** `http://127.0.0.1:8000/api/`  
**Production:** TBD

### Authentication (Planned)

```
POST   /api/users/                  # Register new user (create user resource)
GET    /api/users/me/               # Get current user profile
PUT    /api/users/me/               # Update current user profile
PATCH  /api/users/me/               # Partial update of current user
DELETE /api/users/me/               # Delete current user account
GET    /api/users/me/game-profile/  # Get current user's game profile
```

### Authentication Tokens

```
POST   /api/auth/token/             # Login - obtain JWT tokens
POST   /api/auth/token/refresh/     # Refresh access token
POST   /api/auth/token/revoke/      # Logout - revoke token
DELETE /api/auth/token/             # Alternative logout endpoint
```

### Authentication Actions 

```
POST   /api/auth/verify-email/      # Verify email address
POST   /api/auth/reset-password/    # Request password reset
POST   /api/auth/reset-password/confirm/  # Confirm password reset
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

### Phase 1: Authentication 

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

**UserRegistrationSerializer** (Complete):
- Located in: `backend/penguin_app/serializers/user_serializers.py`
- Status: Complete
- Features: Password validation, email validation, username validation, password confirmation, automatic UserGameProfile creation

### API Views (In Progress)

- Views defined in: `backend/penguin_app/views/user_views.py`
- Status: 🚧 In Development
- Need to create views for:
  -  User registration (UserRegistrationView)
  - User login (TokenObtainView)
  - Token refresh (TokenRefreshView)
  - Current user profile (CurrentUserView)
  - Habits CRUD
  - Todos CRUD
  - Journal CRUD

### No URLs Configured

- Only admin and root path exist
- Need to add `/api/` URL routing
- Need to include DRF router

---

## Example: How API Will Work (Future)

### User Registration Flow (Planned)

```bash
# 1. Register user (POST to /api/users/ - creates user resource)
curl -X POST http://127.0.0.1:8000/api/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "penguin_user",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!"
  }'

# Response (201 Created):
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "username": "penguin_user",
  "message": "User created successfully"
}

# 2. Login (POST to /api/auth/token/ - creates token resource)
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'

# Response (201 Created):
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "username": "penguin_user",
    "is_verified": false
  }
}

# 3. Get current user (GET /api/users/me/ - retrieve user resource)
curl -X GET http://127.0.0.1:8000/api/users/me/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."

# Response (200 OK):
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "username": "penguin_user",
  "is_verified": false,
  "created_at": "2025-01-15T10:00:00Z",
  "profile_picture": null,
  "bio": null
}

# 4. Refresh token (POST /api/auth/token/refresh/)
curl -X POST http://127.0.0.1:8000/api/auth/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
  }'

# Response (200 OK):
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...new_token..."
}

# 5. Logout (POST /api/auth/token/revoke/ - revoke token)
curl -X POST http://127.0.0.1:8000/api/auth/token/revoke/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -d '{
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
  }'

# Response (204 No Content)
```
---

**Questions?** Open an issue: https://github.com/wkeav/Pocket_Penguin/issues

