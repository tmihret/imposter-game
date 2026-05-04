// ImpostorGameApp.swift
import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct imposterFinalProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthService()  // ← move here
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .background(AppTheme.background)
                .tint(AppTheme.accent)
                .environmentObject(auth)  // ← inject globally
        }
    }
}
