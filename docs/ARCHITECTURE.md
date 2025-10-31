# Pocket Penguin - Architecture Documentation

Current system architecture and technology stack.

> **Development Status:** This project is in early development. This document reflects the CURRENT state, not planned features.

---

## Table of Contents

- [System Overview](#system-overview)
- [Technology Stack](#technology-stack)
- [Current Implementation](#current-implementation)
- [Database Schema](#database-schema)
- [Frontend Structure](#frontend-structure)
- [Security Implementation](#security-implementation)
- [Design Decisions](#design-decisions)

---

## System Overview

Pocket Penguin is a **full-stack mobile application** with:
- **Backend**: Django REST Framework API (in development)
- **Frontend**: Flutter mobile app with UI mockups
- **Database**: SQLite for development
- **Architecture**: Client-server with REST API

```
┌─────────────────────────────────────────────┐
│           Frontend (Flutter)                │
│  - UI Screens (built)                       │
│  - Models defined                           │
│  - Theme system                             │
│  - No backend integration yet               │
└─────────────────────────────────────────────┘
                  ↓ (Not connected yet)
┌─────────────────────────────────────────────┐
│           Backend (Django)                  │
│  - User model (complete)                    │
│  - UserGameProfile model (complete)         │
│  - Serializers (partial)                    │
│  - No API endpoints yet                     │
│  - Admin panel available                    │
└─────────────────────────────────────────────┘
                  ↓
            SQLite Database
```

---

## Technology Stack

### Backend

| Technology | Version | Status |
|------------|---------|--------|
| **Python** | 3.11+ | Active |
| **Django** | 4.2.7 | Configured |
| **Django REST Framework** | 3.14.0 | Installed |
| **django-cors-headers** | 4.3.1 | Configured |
| **python-decouple** | 3.8 | Available |
| **Gunicorn** | 21.2.0 | Installed |
| **SQLite** | 3.x | Active |

### Frontend

| Technology | Version | Status |
|------------|---------|--------|
| **Flutter** | 3.16.9 | Active |
| **Dart** | 3.2.6+ | Active |
| **http** | ^1.2.0 | Installed |
| **provider** | ^6.1.5+1 | Installed |
| **shared_preferences** | ^2.2.3 | Installed |
| **cupertino_icons** | ^1.0.2 | Installed |

### DevOps

| Technology | Status |
|------------|--------|
| **Docker** | Dockerfile present |
| **GitHub Actions** | CI/CD configured |
| **Git** | Version control |

---

**Questions?** Open an issue: https://github.com/wkeav/Pocket_Penguin/issues
