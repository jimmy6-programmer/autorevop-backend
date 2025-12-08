# Auto RevOp Email Configuration Guide

This guide will help you set up email functionality for your Auto RevOp marketplace application.

## 📧 Email Setup Overview

Your Auto RevOp app uses email for:
- User registration verification
- Password reset functionality
- Booking confirmations
- Order notifications

## 🔧 Step-by-Step Email Setup

### Step 1: Choose Your Email Service

#### Option A: Gmail (Easiest for Development)
1. **Create a Gmail Account** for your business
2. **Enable 2-Factor Authentication** on the account
3. **Generate an App Password**:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"
   - Use this password (not your regular password)

#### Option B: Outlook/Hotmail (Alternative)
1. Create an Outlook account
2. Use your regular password (no app password needed)

#### Option C: Professional Email Services (Recommended for Production)

**SendGrid (Most Popular)**:
1. Sign up at [sendgrid.com](https://sendgrid.com)
2. Create an API key
3. Use these settings:
   ```
   EMAIL_HOST=smtp.sendgrid.net
   EMAIL_PORT=587
   EMAIL_USER=apikey
   EMAIL_PASS=your-sendgrid-api-key
   ```

**Mailgun (Good Alternative)**:
1. Sign up at [mailgun.com](https://mailgun.com)
2. Verify your domain
3. Get SMTP credentials

### Step 2: Configure Environment Variables

1. **Copy the example file**:
   ```bash
   cp backend/.env.example backend/.env
   ```

2. **Edit the .env file** with your email settings:
   ```env
   # For Gmail
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_SECURE=false
   EMAIL_USER=autorevop.business@gmail.com
   EMAIL_PASS=your-app-password-here

   # For Outlook
   EMAIL_HOST=smtp-mail.outlook.com
   EMAIL_PORT=587
   EMAIL_USER=autorevop@outlook.com
   EMAIL_PASS=your-regular-password

   # For SendGrid
   EMAIL_HOST=smtp.sendgrid.net
   EMAIL_PORT=587
   EMAIL_USER=apikey
   EMAIL_PASS=SG.your-sendgrid-api-key
   ```

### Step 3: Test Email Configuration

1. **Start your backend server**:
   ```bash
   cd backend
   npm install
   npm start
   ```

2. **Test email sending**:
   - Try user registration
   - Check server logs for email sending confirmation
   - Verify emails are received

### Step 4: Production Considerations

#### Security Best Practices:
- ✅ Use environment variables (never hardcode credentials)
- ✅ Use app passwords, not regular passwords
- ✅ Enable SPF/DKIM/DMARC for your domain
- ✅ Use professional email services for production

#### Email Service Recommendations:
- **Development**: Gmail with app password
- **Production**: SendGrid, Mailgun, or AWS SES
- **High Volume**: Consider dedicated email service providers

## 🚨 Important Notes

### Gmail App Passwords:
- Required when 2FA is enabled
- Different from your regular password
- Can be revoked if needed

### Email Deliverability:
- Free email services may have sending limits
- Professional services offer better deliverability
- Always test with real email addresses

### Security:
- Never commit `.env` files to version control
- Use different credentials for development/production
- Rotate passwords regularly

## 🔍 Troubleshooting

### Common Issues:

**"Authentication failed"**:
- Check if app password is correct
- Verify 2FA is enabled for Gmail
- Try using a different email service

**"Emails not sending"**:
- Check server logs for error messages
- Verify SMTP settings
- Test with a different email provider

**"Emails going to spam"**:
- Set up SPF/DKIM records
- Use a professional email service
- Avoid spam trigger words in emails

## 📞 Support

If you encounter issues:
1. Check the server logs in your backend terminal
2. Verify your `.env` file configuration
3. Test with different email services
4. Ensure firewall allows SMTP connections

## 🎯 Next Steps

Once email is configured:
1. Test user registration flow
2. Test password reset functionality
3. Verify booking confirmation emails
4. Set up email templates for better branding

---

**Happy coding with Auto RevOp! 🔧🚗**