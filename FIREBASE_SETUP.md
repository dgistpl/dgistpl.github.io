# Firebase View Counter Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name (e.g., "minseok-blog-views")
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Set up Realtime Database

1. In Firebase console, go to "Realtime Database"
2. Click "Create Database"
3. Choose "Start in test mode" (for now)
4. Select your preferred location
5. Click "Done"

## Step 3: Get Firebase Configuration

1. In Firebase console, click the gear icon → "Project settings"
2. Scroll down to "Your apps" section
3. Click "Web app" icon (</>) 
4. Register your app with name (e.g., "Blog View Counter")
5. Copy the configuration object

## Step 4: Update _config.yml

Replace the Firebase section in `_config.yml` with your actual values:

```yaml
firebase:
  api_key: "AIzaSyDGf7VklgsmmFMzSaQj0mHVQIPHZw2pcRY"  # Your API key
  auth_domain: "myhomepage-78f7b.firebaseapp.com"
  database_url: "https://myhomepage-78f7b-default-rtdb.firebaseio.com"
  project_id: "your-project"
  storage_bucket: "your-project.appspot.com"
  messaging_sender_id: "123456789"
  app_id: "1:123456789:web:abcdef123456"
```

## Step 5: Set Database Rules (Optional - for security)

In Firebase console → Realtime Database → Rules, you can set:

```json
{
  "rules": {
    "views": {
      ".read": true,
      ".write": true,
      "$page": {
        ".validate": "newData.isNumber() && newData.val() >= data.val()"
      }
    }
  }
}
```

## Step 6: Test

1. Build your Jekyll site: `bundle exec jekyll serve`
2. Visit a post page
3. Check browser console for any errors
4. View count should appear and increment on new visits
5. Check Firebase console → Realtime Database to see stored data

## Features

- **Global view counts**: Shared across all visitors
- **Session-based**: One count per session per page
- **Fallback**: Uses localStorage if Firebase fails
- **Real-time**: Updates immediately in Firebase
- **Error handling**: Graceful degradation

## Troubleshooting

- Check browser console for Firebase errors
- Verify Firebase config values are correct
- Ensure database rules allow read/write
- Test with different browsers/incognito mode
