# Pocket Penguin 

Pocket Penguin is a wellness / habit-gamification mobile app built by Team K for CS-3203 Fall 2025. It aims to help users build daily habits, track progress, and engage with habit formation through playful, penguin-themed interactive features. It is a full stack mobile application, development using Django for backend and Flutter for frontend. 

## Features

### Core Features

####  **Habit Tracking**
- **To-Do Lists** - Individual habit management with customizable tasks
- **Streak Tracking** - Monitor consecutive days of habit completion
- **Journal Entries** - Reflect on progress and document your wellness journey
- **Progress Analytics** - Visual insights into habit formation patterns

#### **User Interface & Experience**
- **Avatar Customization** - Personalize your penguin companion with unique styles
- **Adaptive Themes** - Light ↔ Dark mode for comfortable viewing
- **Calendar View** - Plan and track habits with intuitive calendar interface
- **Cross-platform Support** - Seamless experience on iOS and Android

#### **User Authentication**
- **Secure Registration & Login** - Protected user accounts with Django authentication
- **Email Verification** - Account validation for enhanced security
- **Profile Management** - Customize user preferences and settings

#### **Game Elements**
- **Dynamic Penguin Avatar** - Your penguin companion reflects your progress and achievements
- **Custom Environments** - Unlock unique backgrounds and "homes" for your penguin
- **Achievement System** - Earn rewards for consistent habit completion
- **Progress Visualization** - See your wellness journey through your penguin's growth

### Technical Features 

- **RESTful API Backend** - Django REST Framework with SQLite database
- **Real-time Updates** - Live penguin interactions and progress updates
- **Docker Containerization** - Easy deployment and development setup
- **Admin Interface** - Django admin panel for data management
- **Hot Reload Development** - Fast iteration during development

### Future Features 

#### **AI-Powered Insights**
- **Preset Analysis** - AI-driven habit recommendations based on user patterns
- **Smart Scheduling** - Optimal timing suggestions for habit completion
- **Personalized Tips** - Contextual advice for habit formation

#### **Advanced Functionality**
- **Food Scanner** - Nutrition tracking with camera-based food recognition
- **Standby Penguin Mode** - Interactive background companion when app is inactive
- **Social Features** - Connect with friends and share progress
- **Wearable Integration** - Sync with fitness trackers and smartwatches

#### **Enhanced Gamification**
- **Penguin Evolution** - Advanced growth stages based on long-term progress
- **Mini-Games** - Interactive activities to earn rewards and maintain engagement
- **Seasonal Events** - Limited-time challenges and themed content
- **Leaderboards** - Friendly competition with other users

## Architecture

```
Pocket Penguin/
├── backend/           # Django REST API
│   ├── pocket_penguin/    # Main Django project
│   ├── penguin_app/       # Django app
│   ├── Dockerfile         # Backend containerization
│   └── requirements.txt   # Python dependencies
├── frontend/          # Flutter mobile app
│   └── pocket_penguin_app/
│       ├── lib/           # Dart source code
│       ├── android/       # Android platform files
│       ├── ios/           # iOS platform files
│       ├── Dockerfile     # Frontend containerization
│       └── pubspec.yaml   # Flutter dependencies
└── README.md          # This file
```

## Prerequisites

### For Local Development
- **Python 3.9+** - Backend development
- **Flutter SDK 3.2.6+** - Mobile app development
- **Git** - Version control
- **Docker** (optional) - Containerized deployment

### For Docker Development
- **Docker Desktop** - Container management
- **Docker Compose** (optional) - Multi-container orchestration

## Installation

### Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone https://github.com/wkeav/Pocket_Penguin.git
   cd Pocket_Penguin
   ```

2. **Build and run backend**
   ```bash
   cd backend
   docker build -t pocket-penguin-backend .
   docker run -p 8000:8000 pocket-penguin-backend
   ```

3. **Build and run frontend**
   ```bash
   cd ../frontend/pocket_penguin_app
   docker build -t pocket-penguin-flutter .
   docker run -it pocket-penguin-flutter bash
   ```

### Local Development Setup

#### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up database**
   ```bash
   python manage.py migrate
   python manage.py createsuperuser  # Optional: Create admin user
   ```

5. **Start development server**
   ```bash
   python manage.py runserver
   ```

The backend will be available at `http://127.0.0.1:8000/`

#### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend/pocket_penguin_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Enable desktop support** (for testing)
   ```bash
   flutter config --enable-macos-desktop
   flutter config --enable-windows-desktop
   flutter config --enable-linux-desktop
   ```

4. **Run the app**
   ```bash
   # For mobile (requires emulator/device)
   flutter run
   
   # For desktop testing
   flutter run -d macos      # macOS
   flutter run -d windows    # Windows
   flutter run -d linux      # Linux
   
   # For web testing
   flutter run -d chrome
   ```

## Usage

### Backend API

Once the Django server is running, you can:

- **Access the API root**: `http://127.0.0.1:8000/`
- **Admin interface**: `http://127.0.0.1:8000/admin/`
- **API documentation**: `http://127.0.0.1:8000/api/docs/` (if configured)

### Mobile App

The Flutter app connects to the Django backend to provide a comprehensive wellness experience:

#### 🐧 **Penguin Companion System**
- Your penguin avatar grows and evolves based on habit completion
- Customize appearance, accessories, and living environment
- Interactive responses to your daily progress

#### 📋 **Habit Management Workflow**
1. **Create Habits** - Set up daily, weekly, or custom recurring tasks
2. **Track Progress** - Mark habits as complete and build streaks
3. **Journal Reflection** - Document thoughts and insights about your journey
4. **View Analytics** - Monitor patterns and celebrate achievements

#### 🎮 **Gamification Experience**
- Earn points and unlock rewards for consistent habit completion
- Watch your penguin's happiness and health reflect your wellness journey
- Unlock new environments and customization options as you progress

### Docker Commands

```bash
# Build backend image
docker build -t pocket-penguin-backend ./backend

# Run backend container
docker run -p 8000:8000 pocket-penguin-backend

# Build frontend image
docker build -t pocket-penguin-flutter ./frontend/pocket_penguin_app

# Run frontend container for building APK
docker run -v $(pwd)/frontend/pocket_penguin_app:/app pocket-penguin-flutter \
  bash -c "flutter build apk --release"
```

## Development

### Backend Development

- **Models**: Define in `backend/penguin_app/models.py`
- **Views**: Create API endpoints in `backend/penguin_app/views.py`
- **URLs**: Configure routes in `backend/pocket_penguin/urls.py`
- **Settings**: Modify `backend/pocket_penguin/settings.py`

### Frontend Development

- **Main app**: `frontend/pocket_penguin_app/lib/main.dart`
- **Screens**: Add new screens in `lib/screens/`
- **Services**: API calls in `lib/services/`
- **Models**: Data models in `lib/models/`

### Testing

#### Backend Tests
```bash
cd backend
python manage.py test
```

#### Frontend Tests
```bash
cd frontend/pocket_penguin_app
flutter test
```

### Code Quality

```bash
# Backend linting
cd backend
flake8 .

# Frontend analysis
cd frontend/pocket_penguin_app
flutter analyze
```

## API Documentation

### Endpoints

- `GET /` - Health check
- `GET /admin/` - Django admin interface
- `GET /api/` - API root (when implemented)

### Authentication

[Describe authentication method when implemented]

## Deployment

### Production Deployment

1. **Set environment variables**
2. **Configure production database**
3. **Set `DEBUG=False` in Django settings**
4. **Use production WSGI server** (gunicorn, uwsgi)
5. **Build Flutter release APK/AAB**

### Environment Variables

Create a `.env` file in the backend directory:

```env
DEBUG=False
SECRET_KEY=your-production-secret-key
DATABASE_URL=your-production-database-url
ALLOWED_HOSTS=your-domain.com,www.your-domain.com
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Run tests** and ensure they pass
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### Code Style

- **Python**: Follow PEP 8
- **Dart/Flutter**: Follow Dart style guide
- **Git commits**: Use conventional commits format

## Technology Stack

### Backend
- **Django 4.2.7** - Web framework
- **Django REST Framework 3.14.0** - API framework
- **SQLite** - Database (development)
- **Python 3.9+** - Programming language

### Frontend
- **Flutter 3.2.6+** - Mobile framework
- **Dart** - Programming language
- **HTTP package** - API communication
- **Provider** - State management

### DevOps
- **Docker** - Containerization
- **Git** - Version control

## Troubleshooting

### Common Issues

#### Backend Issues
- **Django not found**: Ensure virtual environment is activated and dependencies installed
- **Database errors**: Run `python manage.py migrate`
- **Import errors**: Check `PYTHONPATH` and installed packages

#### Frontend Issues
- **Flutter command not found**: Ensure Flutter SDK is in PATH
- **Pub get fails**: Check internet connection and Flutter version
- **Build errors**: Run `flutter clean` and `flutter pub get`

#### Docker Issues
- **Build fails**: Check Dockerfile syntax and base image availability
- **Container won't start**: Check logs with `docker logs <container-id>`
- **Port conflicts**: Ensure ports 8000 and 3000 are available

## Support

- **Issues**: [GitHub Issues](https://github.com/wkeav/Pocket_Penguin/issues)
- **Documentation**: Check `/backend/docs/` for additional setup guides
- **Community**: [Add community links if available]

## Roadmap

### Phase 1: Core Development (Current Sprint)
- [ ] **User Authentication System** - Registration, login, email verification
- [ ] **Basic Habit Tracking** - CRUD operations for habits and to-do lists
- [ ] **Penguin Avatar System** - Basic customization and progress reflection
- [ ] **Streak Tracking** - Daily habit completion monitoring
- [ ] **Database Models** - User profiles, habits, progress tracking

### Phase 2: Enhanced Features
- [ ] **Journal Entries** - Reflection and progress documentation
- [ ] **Calendar Integration** - Visual habit planning and tracking
- [ ] **Theme System** - Light/Dark mode implementation
- [ ] **Progress Analytics** - Charts and insights dashboard
- [ ] **Achievement System** - Rewards and milestone tracking

### Phase 3: Gamification & Polish
- [ ] **Advanced Avatar Features** - Multiple customization options
- [ ] **Environment System** - Unlockable backgrounds and penguin homes
- [ ] **Mini-Games** - Interactive elements for engagement
- [ ] **Social Features** - Friend connections and progress sharing

### Phase 4: Advanced Features (Stretch Goals)
- [ ] **AI Preset Analysis** - Smart habit recommendations
- [ ] **Food Scanner Integration** - Camera-based nutrition tracking
- [ ] **Standby Penguin Mode** - Background companion functionality
- [ ] **Wearable Integration** - Fitness tracker synchronization

### Technical Roadmap
- [ ] **API Documentation** - Swagger/OpenAPI implementation
- [ ] **Automated Testing** - Unit and integration test coverage
- [ ] **CI/CD Pipeline** - Automated deployment and testing
- [ ] **Performance Optimization** - Database and app performance tuning
- [ ] **Production Deployment** - Scalable hosting solution

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- **Astra** - [wkeav](https://github.com/wkeav)
- **Thien** - [SenPr](https://github.com/SenPr)
- **Kaitlyn** - [ktnngn] (https://github.com/ktnngn)
- **Sneha** - [CtrlChieftainMsSneha] (https://github.com/CtrlChieftainMsSneha)
- **Brandon** - [bbloob] (https://github.com/bbloob)
- **Jack** - [jacknguyen1918] (https://github.com/jacknguyen1918)

## Acknowledgments

- Django community for excellent documentation
- Flutter team for the amazing cross-platform framework
- [Make a README](https://www.makeareadme.com/) for README best practices

---
