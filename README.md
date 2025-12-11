# 🎵 Music Globe

A beautiful 3D visualization of your Spotify music history using SceneKit and SwiftUI.

![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Features

- 🌍 **3D Interactive Globe** - Rotate, zoom, and explore your music in 3D space
- 🎨 **Minimalist White Theme** - Clean, modern Apple-style design
- 🎴 **Flat Album Cards** - Album covers displayed as elegant flat cards
- 🎵 **Spotify Integration** - OAuth 2.0 with PKCE authentication
- 📊 **Smart Placement** - Albums positioned by genre and listening timeline
- 🎯 **Tap to Explore** - View album details and play tracks
- ⚡ **Performance Optimized** - Actor-based image caching, smooth 60fps

## 📱 Screenshots

*Coming soon - Connect your Spotify to generate personalized screenshots!*

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- Spotify Developer Account (free)
- Active Spotify account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/musicglobe.git
   cd musicglobe
   ```

2. **Open in Xcode**
   ```bash
   open musicglobe.xcodeproj
   ```

3. **Set up Spotify Developer App**
   - Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Click **"Create App"**
   - Fill in:
     - **App Name:** Music Globe
     - **App Description:** 3D visualization of music history
     - **Redirect URI:** `musicglobe://callback`
   - Click **"Save"**
   - Copy your **Client ID**

4. **Add Client ID to the app**
   - Open `musicglobe/Services/SpotifyAuthManager.swift`
   - Replace line 17:
     ```swift
     private let clientId = "YOUR_ACTUAL_CLIENT_ID_HERE"
     ```

5. **Configure Info.plist**
   - Select `musicglobe` target → **Info** tab
   - Add **URL Type**:
     - **Identifier:** `com.musicglobe.auth`
     - **URL Schemes:** `musicglobe`
   - Add **Queried URL Schemes**:
     - `spotify`
   
   Or manually add to Info.plist (see `Info-plist-additions.txt`)

6. **Build and Run**
   ```bash
   # Command + R in Xcode
   # Or via terminal:
   xcodebuild -project musicglobe.xcodeproj -scheme musicglobe -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

## 🎮 Usage

1. Launch the app
2. Tap **"Connect to Spotify"**
3. Authorize the app
4. Watch your music history populate the globe!

**Controls:**
- **Drag** → Rotate the globe
- **Pinch** → Zoom in/out
- **Tap album** → View details & play tracks

## 🏗️ Architecture

```
musicglobe/
├── App/
│   ├── AppState.swift              # Central state management
│   └── musicglobeApp.swift         # App entry point
├── Models/
│   ├── AlbumNode.swift             # 3D album node model
│   └── SpotifyModels.swift         # API response models
├── Services/
│   ├── SpotifyAuthManager.swift    # OAuth 2.0 PKCE auth
│   ├── SpotifyAPIClient.swift      # API client
│   ├── ImageCache.swift            # Actor-based caching
│   └── NodePlacementEngine.swift   # Globe placement logic
├── Globe/
│   ├── GlobeScene.swift            # SceneKit 3D scene
│   ├── GlobeView.swift             # SwiftUI wrapper
│   └── GlobeViewModel.swift        # Interaction logic
├── AlbumDetail/
│   ├── AlbumDetailView.swift       # Detail screen
│   └── AlbumDetailViewModel.swift  # Detail logic
└── UIComponents/
    ├── LoadingView.swift
    ├── NowPlayingBadge.swift
    └── SpotifyConnectBanner.swift
```

**Pattern:** MVVM (Model-View-ViewModel)  
**State:** Combine + ObservableObject  
**3D:** SceneKit  
**UI:** SwiftUI  

## 🎨 Design

- **Theme:** Minimalist white
- **Background:** `#FAFAFA`
- **Typography:** SF Pro (system font)
- **Cards:** Flat album art planes oriented tangent to sphere
- **Animation:** Smooth transitions, hover effects, subtle rotations

## 🔐 Security

- ✅ OAuth 2.0 with PKCE (no client secret needed)
- ✅ Tokens stored in **Keychain** (secure)
- ✅ No server required
- ✅ All data stays on device

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by [Multiple States](https://multiplestates.co.uk/)
- Built with [Spotify Web API](https://developer.spotify.com/documentation/web-api)
- Uses Apple's SceneKit framework

## 📞 Support

For issues or questions:
- Open an [Issue](https://github.com/YOUR_USERNAME/musicglobe/issues)
- Check existing [Discussions](https://github.com/YOUR_USERNAME/musicglobe/discussions)

## 🗺️ Roadmap

- [ ] Add time period filtering
- [ ] Implement search functionality
- [ ] Custom color themes
- [ ] Export as image/video
- [ ] Playlist creation from selection
- [ ] Audio visualization overlay
- [ ] Social sharing

---

**Built with ❤️ using SwiftUI, SceneKit, and the Spotify Web API**

*Visualize your musical journey in 3D* 🌍🎵✨
