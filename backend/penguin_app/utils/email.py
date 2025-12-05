"""
Email utility functions for Pocket Penguin.

Handles sending verification emails and other email communications.
Uses SendGrid for production, console backend for development.

Author: Astra
"""

from django.core.mail import send_mail
from django.conf import settings
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.contrib.auth.tokens import default_token_generator
import logging

logger = logging.getLogger(__name__)


def send_verification_email(user):
    """
    Send email verification link to user after registration.
    
    This function:
    - Generates a secure, one-time-use token (valid for 24 hours)
    - Encodes the user ID safely for URL inclusion
    - Constructs verification link with frontend URL
    - Sends HTML-friendly email with clear call-to-action
    
    Args:
        user: The User instance that just registered
        
    Raises:
        Exception: If email sending fails (caught by caller)
        
    """
    
    # Generate secure token (never stored raw in DB - checked against user state)
    token = default_token_generator.make_token(user)
    
    # Encode user ID to base64 for safe URL inclusion
    uidb64 = urlsafe_base64_encode(force_bytes(user.pk))
    
    # Build verification link that frontend will redirect to backend
    verification_link = f"{settings.FRONTEND_URL}/verify-email/?uid={uidb64}&token={token}"
    
    # Email subject
    subject = "Verify Your Pocket Penguin Email"
    
    # Plain text fallback message
    plain_message = f"""
Hello {user.username},

Welcome to Pocket Penguin! 

Please verify your email by clicking the link below:

{verification_link}

This verification link will expire in 24 hours.

If you didn't create this account, please ignore this email.

Best regards,
Pocket Penguin Team
    """
    
    # HTML email message (more professional)
    html_message = f"""
    <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h1 style="color: #4a90e2; margin-bottom: 20px;">Welcome to Pocket Penguin! 🐧</h1>
                
                <p>Hi {user.username},</p>
                
                <p>Thank you for signing up! To get started, please verify your email address by clicking the button below:</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{verification_link}" style="background-color: #4a90e2; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; font-weight: bold;">
                        Verify Email
                    </a>
                </div>
                
                <p>Or copy and paste this link in your browser:</p>
                <p style="word-break: break-all; background-color: #f5f5f5; padding: 10px; border-radius: 3px;">
                    {verification_link}
                </p>
                
                <p style="color: #666; font-size: 12px; margin-top: 20px;">
                    This link will expire in 24 hours. If you didn't create this account, please ignore this email.
                </p>
                
                <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                
                <p style="color: #999; font-size: 12px;">
                    Best regards,<br>
                    Pocket Penguin Team
                </p>
            </div>
        </body>
    </html>
    """
    
    try:
        # Send email with both plain text and HTML versions
        send_mail(
            subject,
            plain_message,
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            html_message=html_message,
            fail_silently=False,
        )
        logger.info(f"Verification email sent to {user.email}")
        
    except Exception as e:
        # Log the error for debugging/monitoring
        logger.error(f"Failed to send verification email to {user.email}: {str(e)}")
        # Re-raise so caller knows to handle it
        raise
