# Music Globe - UX & QA Flows 🌍

## 1. UX Philosophy
**"Liquid & Luminescent"**
The Music Globe experience is designed to be immersive, fluid, and visually premium. 
*   **Aesthetics**: Glassmorphism (Liquid Glass), Vibrant Gradients, Breathing Animations.
*   **Interaction**: Direct manipulation (Spin globe, tap nodes, playful bounce).
*   **Feedback**: Instant auditory (previews) and visual (badges, glowing buttons) response.

---

## 2. Core User Flows (Happy Paths)

### Flow A: Onboarding
1.  **Launch**: User sees "Welcome to Music Globe" with a breathing, glowing aura.
2.  **Action**: User taps the centered **"Connect with Spotify"** button (Green Liquid Glass).
3.  **Result**: Spotify Auth launches. Upon success, the Globe loads with user's music history.

### Flow B: Exploration & Playback
1.  **Explore**: User spins the 3D globe. Nodes represent tracks.
2.  **Select**: User taps a node.
3.  **Detail View**: A sheet opens with blurred album art background.
4.  **Play**: User taps "**Play Preview**" (Green Liquid Button).
    *   *Result*: 30s preview plays immediately. Sheet remains open. Mini Player appears.
5.  **Dismiss**: User swipes down sheet to return to Globe.
6.  **Background Play**: Music continues. Mini Player shows track info + waveform.

### Flow C: Mini Player Control
1.  **Context**: Audio is playing while on the Globe.
2.  **Pause**: User taps **Pause** on the Mini Player.
    *   *Result*: Audio stops. **Player REMAINS visible** (does not disappear).
3.  **Resume**: User taps Play to resume.
4.  **Close**: User taps **X (Close)** button.
    *   *Result*: Audio stops, player dismisses, state clears.

---

## 3. QA Test Plan

### Test Case 1: Visual Consistency
*   [ ] **Buttons**: Verify "Connect" and "Play" buttons share the exact same Green Liquid Glass style (Capsule, Green Gradient, Glow).
*   [ ] **Shadows**: Ensure no "rectangular" shadow artifacts behind pill-shaped buttons.
*   [ ] **Text**: Ensure all text on glass backgrounds is legible (high contrast).

### Test Case 2: Playback Logic
*   [ ] **Preview Priority**: Verify that tracks with previews are loaded first.
*   [ ] **Pause Persistence**: Pause the track. Verify Mini Player stays on screen.
*   [ ] **Close Action**: Tap 'X' on Mini Player. Verify it disappears.

### Test Case 3: Spotify Remote Fallback
*   [ ] **Scenario**: Track has no preview.
*   [ ] **Action**: Tap "Play on Spotify".
*   [ ] **Result**: Spotify App opens (Deep Link). Mini Player updates to "Playing on Spotify".

---
**Design Token Definitions**
*   **Glass Material**: `.ultraThinMaterial` for backgrounds, `.regularMaterial` for interactive elements.
*   **Green Accent**: Spotify Green (`#1DB954`) used in gradients.
*   **Typography**: System font, rounded/soft weights where possible.
