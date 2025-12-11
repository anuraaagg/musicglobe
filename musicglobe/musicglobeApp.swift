//
//  musicglobeApp.swift
//  musicglobe
//
//  Created by Anurag Singh on 11/12/25.
//

import SwiftUI

@main
struct musicglobeApp: App {
  @StateObject private var appState = AppState()

  var body: some Scene {
    WindowGroup {
      GlobeView()
        .environmentObject(appState)
    }
  }
}
