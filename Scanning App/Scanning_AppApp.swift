import SwiftUI
import ARKit

@main
struct Scanning_AppApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Customized view holder
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel = ViewModel()
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        print("App did become active")
                        viewModel.resume()
                    case .inactive:
                        print("App did become inactive")
                        viewModel.pause()
                    default:
                        break
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth){
            print("Does not support AR")
        }
        return true
    }
    
    // Lock the orientation to views
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
