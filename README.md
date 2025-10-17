# Pocket Penguin

<img src="https://media.discordapp.net/attachments/1409584507237044415/1415797929427468388/image.png?ex=68c52cd2&is=68c3db52&hm=f2af49d2b3fbe3d054efa6506f9284a934079e6093a0997ac8a90f90172fb894&=&format=webp&quality=lossless&width=640&height=640" width=150 height=150>

**A gamified wellness and habit-tracking mobile app that makes building healthy habits fun with your personal penguin companion.It aims to help users build daily habits, track progress, and engage with habit formation through playful, penguin-themed interactive features.**

Built with Django REST Framework (backend) and Flutter (mobile app) by Team K for CS-3203 Fall 2025.

[![Flutter CI](https://github.com/wkeav/Pocket_Penguin/workflows/Flutter%20CI/badge.svg)](https://github.com/wkeav/Pocket_Penguin/actions)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.16.9-02569B?logo=flutter)](https://flutter.dev)
[![Django Version](https://img.shields.io/badge/Django-4.2.7-092E20?logo=django)](https://www.djangoproject.com/)

---

## Features

- **Habit Tracking** - Create and manage daily habits with streak tracking
- **Penguin Companion** - Your avatar evolves based on progress
- **Progress Analytics** - Visualize your wellness journey
- **Calendar View** - Plan habits with intuitive scheduling
- **Journal Entries** - Reflect on your habit formation
- **Avatar Customization** - Personalize your penguin's appearance
- **Dark Mode** - Adaptive themes for comfortable viewing
- **Secure Auth** - Protected accounts with Django authentication
- **Cross-Platform** - Currently supports Web (Chrome) and iOS (macOS testing)

[View full feature list →](docs/FEATURES.md)

---

## Quick Start

### Prerequisites

- **Python 3.11+** | **Flutter 3.16.9** | **Git**

#### Backend (Django)
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```
Backend runs at `http://127.0.0.1:8000/`

#### Frontend (Flutter)
```bash
cd frontend/pocket_penguin_app
flutter pub get
flutter run -d chrome  # For web testing
# Or for iOS testing: flutter run -d macos
```

> **Note:** Currently supports **Web (Chrome)** and **iOS** platforms. Android support coming soon!

**Detailed setup guide:** [docs/SETUP.md](docs/SETUP.md)

### 🌐 Live Demo

**Web App:** [View Live Demo](https://wkeav.github.io/Pocket_Penguin/) 🚀

The app is automatically deployed to GitHub Pages whenever changes are pushed to the main branch.

**Deployment Guide:** [DEPLOYMENT.md](DEPLOYMENT.md)

---

## Documentation

| Document | Description |
|----------|-------------|
| [Setup Guide](docs/SETUP.md) | Detailed installation and configuration |
| [Architecture](docs/ARCHITECTURE.md) | System design and technology decisions |
| [API Reference](docs/API.md) | Backend API endpoints and usage |
| [Deployment](DEPLOYMENT.md) | GitHub Pages deployment instructions |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions |

---

## Technology Stack

**Backend:** Django 4.2.7, Django REST Framework, SQLite  
**Frontend:** Flutter 3.16.9, Dart 3.2.6  
**DevOps:** Docker, GitHub Actions CI/CD

[Full tech stack details →](docs/ARCHITECTURE.md)

---

## Project Structure

```
Pocket_Penguin/
├── backend/              # Django REST API
│   ├── pocket_penguin/  # Django project config
│   ├── penguin_app/     # Main application
│   └── requirements.txt # Python dependencies
├── frontend/             # Flutter mobile app
│   └── pocket_penguin_app/
│       ├── lib/         # Dart source code
│       └── pubspec.yaml # Flutter dependencies
└── docs/                # Documentation
```

---

## Contributing

**Quick contribution steps:**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests and linting
4. Submit a pull request

---

## Testing

```bash
# Backend tests
cd backend
python manage.py test

# Frontend tests
cd frontend/pocket_penguin_app
flutter test
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Authors: Team K

| Name | GitHub | Role |
|------|--------|------|
| Astra | [@wkeav](https://github.com/wkeav) | Developer |
| Thien | [@SenPr](https://github.com/SenPr) | Developer |
| Kaitlyn | [@ktnngn](https://github.com/ktnngn) | Developer |
| Sneha | [@CtrlChieftainMsSneha](https://github.com/CtrlChieftainMsSneha) | Developer |
| Brandon | [@bbloob](https://github.com/bbloob) | Developer |
| Jack | [@jacknguyen1918](https://github.com/jacknguyen1918) | Developer |

---

## Links

- **Issues:** [GitHub Issues](https://github.com/wkeav/Pocket_Penguin/issues)
- **Documentation:** [docs/](docs/)
- **CI/CD:** [GitHub Actions](https://github.com/wkeav/Pocket_Penguin/actions)

---

<p align="center">
  <sub>Built by Team K • CS-3203 Fall 2025</sub>
</p>
