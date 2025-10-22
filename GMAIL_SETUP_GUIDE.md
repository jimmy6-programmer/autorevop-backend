# Gmail Setup Guide for Auto RevOp

## 📧 Setting up Gmail for autorevop@gmail.com

### Step 1: Enable 2-Factor Authentication (2FA)
1. Go to [myaccount.google.com](https://myaccount.google.com)
2. Click on "Security" in the left sidebar
3. Under "Signing in to Google", click "2-Step Verification"
4. Follow the steps to enable 2FA

### Step 2: Generate App Password
1. After enabling 2FA, go back to "Security" → "2-Step Verification"
2. Scroll down to "App passwords"
3. Click "App passwords"
4. Select "Mail" and "Other (custom name)"
5. Enter "Auto RevOp" as the custom name
6. Click "Generate"
7. **Copy the 16-character password** (ignore spaces)

### Step 3: Configure Your .env File
Edit `backend/.env` and replace the app password:

```env
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=autorevop@gmail.com
EMAIL_PASS=abcd-efgh-ijkl-mnop  # Your 16-char app password
```

### Step 4: Test the Configuration
1. Start your backend server:
   ```bash
   cd backend
   npm start
   ```

2. Try registering a new user in your app
3. Check if the verification email is sent successfully

## 🔍 Troubleshooting

### "Authentication failed" Error
- Make sure you're using the **app password**, not your regular Gmail password
- Verify 2FA is enabled on the account
- Try generating a new app password

### "Less secure app" Error
- Gmail requires app passwords when 2FA is enabled
- Don't use the "Allow less secure apps" option

### Emails Going to Spam
- This is normal for new Gmail accounts
- Send a few test emails to build reputation
- Consider upgrading to SendGrid for better deliverability

## 📊 Gmail Sending Limits
- **Free Gmail accounts**: 500 emails/day
- **Google Workspace**: 2,000-5,000 emails/day (depending on plan)

## 🚀 Production Recommendation
For production use, consider switching to **SendGrid**:
- Better deliverability
- Professional email reputation
- Advanced analytics
- Higher sending limits

---

**Your Auto RevOp Gmail is now configured! 🎉**