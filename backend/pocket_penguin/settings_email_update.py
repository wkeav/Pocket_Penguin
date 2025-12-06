# Email Configuration - SendGrid (Production-ready)
# 
# Development: Set EMAIL_BACKEND to console if SENDGRID_API_KEY is not set
# Production: Use SendGrid with API key from environment

SENDGRID_API_KEY = config('SENDGRID_API_KEY', default=None)

if SENDGRID_API_KEY:
    # Production: Use SendGrid
    EMAIL_BACKEND = 'sendgrid_backend.SendgridBackend'
else:
    # Development: Use console (emails print to terminal)
    EMAIL_BACKEND = config('EMAIL_BACKEND', default='django.core.mail.backends.console.EmailBackend')

DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default='noreply@pocketpenguin.com')

# Frontend URL for verification link (used in email templates)
FRONTEND_URL = config('FRONTEND_URL', default='http://localhost:3000')
