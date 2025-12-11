# Music Globe Setup Guide

## 🎵 Welcome to Music Globe!

Your 3D interactive music history visualization powered by Spotify.

---

## 📋 Prerequisites

1. **Xcode 15+** with iOS 17+ SDK
2. **Spotify Developer Account** (free)
3. **Active Spotify Premium Account** (for playback features)

---

## 🔧 Setup Instructions

### Step 1: Create Spotify App

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Click **"Create App"**
3. Fill in:
   - **App Name:** Music Globe
   - **App Description:** 3D visualization of music history
   - **Redirect URI:** `musicglobe://callback`
4. Click **"Save"**
5. Copy your **Client ID**

### Step 2: Configure the App

1. Open `SpotifyAuthManager.swift`
2. Replace `YOUR_SPOTIFY_CLIENT_ID` with your actual Client ID:
   ```swift
   private let clientId = "your_actual_client_id_here"
   ```

### Step 3: Add Info.plist Entries

1. Open your project in Xcode
2. Select the `musicglobe` target
3. Go to the **Info** tab
4. Add these URL Types:
   - **Identifier:** `com.musicglobe.auth`
   - **URL Schemes:** `musicglobe`
5. Add to Queried URL Schemes:
   - `spotify`

Or manually add to Info.plist:

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

### Step 4: Build and Run

1. Open `musicglobe.xcodeproj` in Xcode
2. Select your device or simulator
3. Press **Cmd + R** to build and run
4. Tap **"Connect to Spotify"** when the app launches
5. Log in with your Spotify credentials
6. Watch your music history come to life! 🌍✨

---

## 🎮 How to Use

### Globe Screen
- **Drag** → Rotate the globe
- **Pinch** → Zoom in/out
- **Tap a node** → View album details

### Album Detail Screen
- **Scroll** → Browse tracks
- **Tap a track** → Play on Spotify
- **Swipe back** → Return to globe

---

## 🎨 Features

✅ **3D Interactive Globe** with your music history
✅ **Smart Node Placement** based on:
   - Timeline (latitude)
   - Genre clustering (longitude)
   - Play frequency (size)
✅ **Beautiful Animations** - nodes hover and glow
✅ **Genre Color Coding** - different colors per genre
✅ **Spotify Integration** - full playback control
✅ **Album Details** - cover art, track list, stats

---

## 🐛 Troubleshooting

### "Failed to connect to Spotify"
- Make sure your Client ID is correct
- Check that redirect URI matches exactly: `musicglobe://callback`
- Verify URL schemes are added to Info.plist

### "No active device"
- Open Spotify app on your device
- Start playing any song
- Return to Music Globe and try again

### "Failed to load music data"
- Check your internet connection
- Make sure you have listening history on Spotify
- Try logging out and back in

### Album covers not loading
- This is normal - they load progressively
- Check your internet connection

---

## 🚀 Next Steps

Want to enhance your Music Globe? Try:

- Add more scopes for saved albums
- Implement search functionality
- Add timeline filtering
- Create custom color palettes
- Add audio visualizations

---

## 📝 File Structure

```
musicglobe/
├── App/
│   ├── AppState.swift              # Central state manager
│   └── musicglobeApp.swift         # App entry point
├── Models/
│   ├── AlbumNode.swift             # 3D node model
│   └── SpotifyModels.swift         # API response models
├── Services/
│   ├── SpotifyAuthManager.swift    # OAuth PKCE auth
│   ├── SpotifyAPIClient.swift      # API requests
│   ├── ImageCache.swift            # Image caching
│   └── NodePlacementEngine.swift   # Placement logic
├── Globe/
│   ├── GlobeScene.swift            # SceneKit 3D scene
│   ├── GlobeView.swift             # SwiftUI wrapper
│   └── GlobeViewModel.swift        # Globe logic
├── AlbumDetail/
│   ├── AlbumDetailView.swift       # Detail screen
│   └── AlbumDetailViewModel.swift  # Detail logic
└── UIComponents/
    ├── LoadingView.swift           # Loading state
    ├── NowPlayingBadge.swift       # Now playing UI
    └── SpotifyConnectBanner.swift  # Connect button
```

---

## 🔐 Security Notes

- Access tokens are stored in **Keychain** (secure)
- PKCE flow is used (no client secret needed)
- No server required
- All data stays on device

---

## 📄 License

This is a demo app for learning purposes.
Make sure to comply with Spotify's Developer Terms of Service.

---

## 🎉 Enjoy Your Music Globe!

Questions? Check the code comments - they're comprehensive!

Happy exploring! 🌍🎵✨
