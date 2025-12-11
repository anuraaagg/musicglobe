# 🎵 Plan: Show Individual Tracks Instead of Albums

## 🎯 Objective
Display **individual songs/tracks** on the globe instead of just albums to:
- Show MUCH more data (50 tracks vs 10 albums)
- More granular visualization of listening history
- Better representation of your actual music taste

---

## 📊 Current vs Proposed

### **Current (Albums)**
- Fetches: ~10-20 unique albums
- Shows: Album cover on each node
- Click: Opens album with track list
- Problem: Not enough nodes, sparse globe

### **Proposed (Tracks)**
- Fetches: 50+ individual tracks
- Shows: Album cover from track's album
- Click: Opens track player or album with track highlighted
- Benefit: Dense, beautiful globe with more interaction

---

## 🔧 Implementation Plan

### **Step 1: Modify Data Models**

#### **Create TrackNode.swift** (new file)
```swift
struct TrackNode: Identifiable, Codable, Equatable {
    let id: String
    let trackId: String
    let trackName: String
    let artistName: String
    let albumName: String
    let coverArtURL: URL?
    let genreTags: [String]
    let playedAt: Date
    let duration: String
    let popularity: Int  // 0-100
    
    // 3D Position (same as AlbumNode)
    var position: SIMD3<Float>
    var latitude: Float
    var longitude: Float
    var radius: Float
    
    // Visual properties based on popularity
    var nodeSize: Float {
        let baseSize: Float = 0.6
        let scaleFactor = 1.0 + (Float(popularity) / 200.0)
        return baseSize * scaleFactor
    }
    
    var glowColor: SIMD3<Float> {
        // Same genre-based colors as albums
        // ...
    }
}
```

### **Step 2: Update SpotifyAPIClient.swift**

Add method to fetch recently played **tracks** (not albums):

```swift
func fetchRecentTracks(limit: Int = 50) async throws -> [TrackPlayData] {
    let endpoint = "https://api.spotify.com/v1/me/player/recently-played?limit=\(limit)"
    
    // ... request code ...
    
    let response = try JSONDecoder().decode(RecentlyPlayedTracksResponse.self, from: data)
    
    // Convert to TrackPlayData with metadata
    return response.items.map { item in
        TrackPlayData(
            trackId: item.track.id,
            trackName: item.track.name,
            artistName: item.track.artists.first?.name ?? "Unknown",
            albumName: item.track.album.name,
            coverArtURL: item.track.album.images.first?.url,
            genreTags: [], // Would need to fetch separately or use cache
            playedAt: item.playedAt,
            duration: formatDuration(item.track.durationMs),
            popularity: item.track.popularity
        )
    }
}
```

### **Step 3: Update AppState.swift**

Change from `albumNodes` to `trackNodes`:

```swift
@MainActor
class AppState: ObservableObject {
    @Published var trackNodes: [TrackNode] = []  // Changed!
    @Published var selectedTrack: TrackNode?    // Changed!
    
    func loadUserData() async {
        print("🎵 Fetching recent tracks...")
        let tracks = try await spotifyAPI.fetchRecentTracks(limit: 50)
        print("✅ Got \(tracks.count) tracks from Spotify")
        
        // Place track nodes on globe
        let placementEngine = TrackPlacementEngine()
        trackNodes = placementEngine.placeNodes(for: tracks)
    }
}
```

### **Step 4: Create TrackPlacementEngine.swift**

Similar to NodePlacementEngine, but for tracks:

```swift
class TrackPlacementEngine {
    func placeNodes(for tracks: [TrackPlayData]) -> [TrackNode] {
        // Sort by play time
        let sortedTracks = tracks.sorted { $0.playedAt < $1.playedAt }
        
        // Calculate positions
        return sortedTracks.enumerated().map { index, track in
            // Latitude based on time (older = higher latitude)
            let timeProgress = Float(index) / Float(max(tracks.count - 1, 1))
            let latitude = (timeProgress * 150) - 75 // -75° to 75°
            
            // Longitude based on... 
            // Option 1: Popularity (more popular = east, less = west)
            let longitude = Float(track.popularity - 50) * 3.6 // -180° to 180°
            
            // Option 2: Artist name hash (cluster by artist)
            // Option 3: Time of day played
            // Option 4: Energy/tempo (would need audio features API)
            
            let position = sphericalToCartesian(lat: latitude, lon: longitude)
            
            return TrackNode(
                id: UUID().uuidString,
                trackId: track.trackId,
                trackName: track.trackName,
                artistName: track.artistName,
                albumName: track.albumName,
                coverArtURL: track.coverArtURL,
                genreTags: track.genreTags,
                playedAt: track.playedAt,
                duration: track.duration,
                popularity: track.popularity,
                position: position,
                latitude: latitude,
                longitude: longitude,
                radius: 5.2
            )
        }
    }
}
```

### **Step 5: Update GlobeScene.swift**

Minimal changes - it already creates cards from nodes:

```swift
// Already works! Just needs TrackNode instead of AlbumNode
private func createAlbumSphereNode(for track: TrackNode) -> SCNNode {
    // Same code, just different input type
    // ...
}
```

### **Step 6: Create TrackDetailView.swift**

Instead of showing album with tracks, show track detail:

```swift
struct TrackDetailView: View {
    let track: TrackNode
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Large album art
                AsyncImage(url: track.coverArtURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 20)
                
                // Track info
                VStack(spacing: 8) {
                    Text(track.trackName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(track.artistName)
                        .font(.system(size: 18))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Text(track.albumName)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.4))
                }
                
                // Stats
                HStack(spacing: 20) {
                    StatBadge(icon: "clock", value: track.duration)
                    StatBadge(icon: "star.fill", value: "\(track.popularity)")
                    StatBadge(icon: "calendar", value: track.playedAt.formatted(.dateTime.month().day()))
                }
                
                Spacer()
                
                // Play button
                Button {
                    // Play this specific track
                    appState.playTrackDirectly(track)
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play on Spotify")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.11, green: 0.73, blue: 0.33))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
        }
    }
}
```

---

## 🎨 Visualization Ideas

### **Position Strategy Options:**

| Axis | Option 1 | Option 2 | Option 3 |
|------|----------|----------|----------|
| **Latitude** | Play time (chronological) | Popularity | Energy level |
| **Longitude** | Artist clustering | Genre clustering | Time of day |
| **Node Size** | Popularity | Play count | Duration |
| **Node Color** | Genre | Artist | Mood/tempo |

### **Recommended: Chrono + Artist**
- **Latitude:** When you played it (timeline)
- **Longitude:** Group by artist
- **Size:** Track popularity
- **Color:** Genre

---

## 📈 Expected Results

### **Before (Albums)**
```
10-20 nodes total
Sparse globe
Limited interaction
```

### **After (Tracks)**
```
50+ nodes (can go up to 100)
Dense, beautiful globe
Each click = instant track info
More engaging visualization
```

---

## 🚀 Implementation Steps (Prioritized)

### **Phase 1: Basic Track Fetching** (30 mins)
1. ✅ Add `fetchRecentTracks()` to SpotifyAPIClient
2. ✅ Create `TrackNode` model
3. ✅ Update AppState to use trackNodes
4. ✅ Test: Should see 50 nodes appear

### **Phase 2: Track Detail View** (20 mins)
1. ✅ Create TrackDetailView
2. ✅ Add track playback method
3. ✅ Update tap handler
4. ✅ Test: Tap node → See track detail

### **Phase 3: Advanced Placement** (15 mins)
1. ✅ Create TrackPlacementEngine
2. ✅ Implement positioning logic
3. ✅ Add visual variety
4. ✅ Test: Nodes spread nicely

### **Phase 4: Polish** (15 mins)
1. ✅ Add track-specific stats
2. ✅ Improve loading UX
3. ✅ Add filters (optional)
4. ✅ Test: End-to-end flow

---

## 🎯 Benefits

✅ **More Data:** 50-100 nodes instead of 10-20  
✅ **Better Visualization:** Denser, more beautiful globe  
✅ **Faster Loading:** Single API call for 50 tracks  
✅ **Direct Playback:** Click → Play immediately  
✅ **More Granular:** See actual listening patterns  

---

## ⚡ Quick Win Alternative

Don't have time for full refactor? Try this:

### **Hybrid Approach: Tracks from Albums**
```swift
func fetchRecentAlbums() async throws -> [AlbumPlayData] {
    // Fetch 50 recently played tracks
    let tracks = try await fetchRecentTracks(limit: 50)
    
    // Group by album, but keep track info
    var albumMap: [String: [Track]] = [:]
    for track in tracks {
        albumMap[track.albumId, default: []].append(track)
    }
    
    // Create album nodes, but with more of them
    return albumMap.values.map { tracks in
        AlbumPlayData(from: tracks)
    }
}
```

This gives you more nodes without changing the data model!

---

## 🤔 Which Approach?

| Approach | Nodes | Effort | Detail Level |
|----------|-------|--------|--------------|
| **Current (Albums)** | 10-20 | ✅ Done | Album-level |
| **Hybrid (Tracks→Albums)** | 20-40 | 🟡 30 min | Album-level |
| **Full (Individual Tracks)** | 50-100 | 🟡 1-2 hrs | Track-level |

---

**My recommendation:** Start with **Phase 1** to get 50 tracks showing, then add detail view. Total time: ~1 hour for huge improvement!

Want me to implement the track-based approach now? 🚀
