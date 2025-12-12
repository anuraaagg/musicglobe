# Music Globe 🌍

An interactive 3D iOS application that visualizes your Spotify listening history on a spinning globe. Exploring your music taste has never been this immersive!

## Features ✨

*   **3D Music Globe**: Your top tracks and playlists orbit a beautiful SceneKit globe.
*   **Spotify Integration**: Connects securely to your Spotify account to fetch your unique music data.
*   **In-App Previews**: Tap any node to instantly play a 30-second audio preview (native playback).
*   **Liquid Glass UI**: Stunning glassmorphism design for a premium, modern aesthetic.
*   **Interactive Gestures**: Pinch to zoom, pan to rotate, and explore your musical universe.

## Getting Started 🚀

### Prerequisites
*   Xcode 15+
*   iOS 17+ Simulator or Device
*   A Spotify Developer Account

### Setup
1.  Clone this repository.
2.  Open `musicglobe.xcodeproj`.
3.  **Important**: You need to configure your own Spotify Client ID.
    *   Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard).
    *   Create an app and get your `Client ID`.
    *   Add `musicglobe://spotify-login-callback` to your Redirect URIs.
    *   Update `SpotifyAuthManager.swift` or `Info.plist` with your Client ID.

### Building
Just hit **Run (Cmd+R)** in Xcode!

## Contributing 🤝
This project is open source and we'd love your help!
*   **Ideas**: Want to add genre-based coloring? Search functionality?
*   **Fixes**: Found a bug? Open an issue or PR.
*   **Styling**: Improve the shader or glass effects.

Let's build the ultimate music explorer together. 🎵
