# 🎵 How to Set Up Spotify for Music Globe

Complete step-by-step guide to configure Spotify integration.

---

## 📋 Prerequisites

- Spotify account (free or premium)
- Spotify Developer account (free - we'll set this up)

---

## 🚀 Step-by-Step Setup

### **Step 1: Create Spotify Developer App**

1. **Go to Spotify Developer Dashboard**
   - Visit: https://developer.spotify.com/dashboard
   - Log in with your Spotify account

2. **Create a New App**
   - Click the **"Create app"** button
   - Fill in the form:
   
   ```
   App Name: Music Globe
   App Description: 3D visualization of my music listening history
   Website: (leave blank or add your GitHub)
   Redirect URI: musicglobe://callback
   ```
   
   ⚠️ **IMPORTANT:** The redirect URI must be **exactly** `musicglobe://callback`

3. **Accept Terms**
   - Check the boxes for terms of service
   - Click **"Save"**

4. **Get Your Client ID**
   - You'll be taken to your app dashboard
   - Copy the **Client ID** (it looks like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)
   - **DO NOT** share this publicly!

---

### **Step 2: Add Client ID to App**

1. **Open the Project**
   ```bash
   cd /Users/anuragsingh/Documents/musicglobe
   ```

2. **Edit SpotifyAuthManager.swift**
   - Open: `musicglobe/Services/SpotifyAuthManager.swift`
   - Find line 17 (or search for `YOUR_SPOTIFY_CLIENT_ID`)
   - Replace with your actual Client ID:
   
   ```swift
   // BEFORE:
   private let clientId = "YOUR_SPOTIFY_CLIENT_ID"
   
   // AFTER (example):
   private let clientId = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
   ```

3. **Save the file**

---

### **Step 3: Configure Info.plist**

You need to add URL schemes so iOS can redirect back to your app after Spotify authentication.

#### **Option A: Using Xcode GUI (Easier)**

1. Open the project in Xcode
2. Select the **musicglobe** target (in the left sidebar)
3. Go to the **Info** tab
4. Scroll to **URL Types** section
5. Click the **+** button to add a new URL Type
6. Fill in:
   - **Identifier:** `com.musicglobe.auth`
   - **URL Schemes:** `musicglobe` (just this word, no `://`)
   - **Role:** Editor
7. Scroll down to **Queried URL Schemes**
8. Click **+** and add: `spotify`

#### **Option B: Manual XML Edit**

1. Open `musicglobe/Info.plist` in Xcode
2. Right-click and select **"Open As" → "Source Code"**
3. Add this before the closing `</dict>` tag:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.musicglobe.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>musicglobe</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>spotify</string>
</array>
```

---

### **Step 4: Verify Configuration**

#### **Check 1: Client ID**
```bash
# Should show your actual Client ID (not YOUR_SPOTIFY_CLIENT_ID)
grep "clientId" musicglobe/Services/SpotifyAuthManager.swift
```

#### **Check 2: URL Schemes**
```bash
# Should show musicglobe URL scheme
defaults read /Users/anuragsingh/Documents/musicglobe/musicglobe/Info.plist CFBundleURLTypes
```

---

### **Step 5: Build and Test**

1. **Build the app**
   ```bash
   xcodebuild -project musicglobe.xcodeproj \
     -scheme musicglobe \
     -destination 'platform=iOS Simulator,name=iPhone 17'
   ```

2. **Run on Simulator**
   - Open Xcode
   - Select iPhone simulator
   - Press **Cmd + R**

3. **Test Authentication**
   - App should show "Connect to Spotify" banner
   - Tap the banner
   - Browser opens to Spotify login
   - After login, you'll be redirected back to the app ✅

---

## ⚠️ Common Issues & Solutions

### **Issue 1: "Invalid Client ID"**
**Solution:** 
- Double-check your Client ID in SpotifyAuthManager.swift
- Make sure there are no extra spaces or quotes
- Verify it matches your Spotify Dashboard

### **Issue 2: "Redirect URI Mismatch"**
**Solution:**
- Go back to Spotify Developer Dashboard
- Edit your app settings
- Ensure Redirect URI is exactly: `musicglobe://callback`
- No trailing slashes or extra characters

### **Issue 3: "App doesn't open after login"**
**Solution:**
- Check Info.plist has correct URL schemes
- Verify `musicglobe` is added (not `musicglobe://`)
- Rebuild the app after changing Info.plist

### **Issue 4: "No active device found"**
**Solution:**
- Open Spotify app on your device/computer
- Play any song
- Return to Music Globe
- Try again

### **Issue 5: "Empty globe / No albums"**
**Solution:**
- Make sure you have listening history on Spotify
- Try playing a few songs
- Reconnect to Music Globe
- Pull to refresh

---

## 🔐 Security Best Practices

✅ **DO:**
- Keep your Client ID in the code (it's public anyway)
- Store tokens in Keychain (app does this automatically)
- Use PKCE flow (no client secret needed)

❌ **DON'T:**
- Share your Client Secret (we don't use it, but don't share if you have one)
- Commit credentials to Git (already in .gitignore)
- Share refresh tokens

---

## 📊 What Data is Accessed

The app requests these Spotify permissions:

| Permission | Purpose |
|-----------|---------|
| `user-read-recently-played` | To show your recently played albums |
| `user-top-read` | To show your top artists/albums |
| `user-library-read` | To access saved albums |
| `user-read-playback-state` | To show what's currently playing |
| `user-modify-playback-state` | To play tracks from the app |

**All data stays on your device.** No server backend required.

---

## ✅ Checklist

Before running the app, verify:

- [ ] Created Spotify Developer App
- [ ] Copied Client ID
- [ ] Added Client ID to `SpotifyAuthManager.swift`
- [ ] Configured `musicglobe://callback` redirect URI
- [ ] Added URL Schemes to Info.plist
- [ ] Added `spotify` to Queried URL Schemes
- [ ] Built app successfully
- [ ] Have listening history on Spotify

---

## 🎉 You're All Set!

Once configured:
1. Launch the app
2. Tap "Connect to Spotify"
3. Authorize the app
4. Watch your music globe populate!

**Enjoy exploring your musical universe! 🌍🎵✨**

---

## 📞 Need Help?

If you're stuck:
1. Check the [Common Issues](#-common-issues--solutions) section above
2. Review the [Spotify Developer Docs](https://developer.spotify.com/documentation/web-api)
3. Open an issue on GitHub with details

---

*Last updated: December 2024*
