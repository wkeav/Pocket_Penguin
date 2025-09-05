# Backend Setup Guide

## Prerequisites
- Python 3.9+
- Git
- Virtual environment (venv)

## Installation

### 1. Clone Repository
```bash
git clone [repository-url]
cd pocket_penguin/backend
```

### 2. Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Set Up Database
```bash
python manage.py migrate
python manage.py createsuperuser
```

### 5. Start Development Server
```bash
python manage.py runserver
```

## Environment Variables
Create `.env` file in backend directory:
```env
DEBUG=True
SECRET_KEY=your-secret-key
DATABASE_URL=sqlite:///db.sqlite3
```

## Testing
```bash
python manage.py test
```

## Common Issues
- **Virtual environment not activated**: Make sure you see `(venv)` in your prompt
- **Django not found**: Run `pip install -r requirements.txt`
- **Database errors**: Run `python manage.py migrate`