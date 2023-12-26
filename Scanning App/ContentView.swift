import SwiftUI
import RealityKit
import Foundation

struct ContentView: View{
    // Global Varible
    @State var screenSize: CGSize = .zero
    @State private var createdPinEntities : [CreatedPinEntity] = []
    // Customized view holder
    @EnvironmentObject var viewModel: ViewModel
        
    var body: some View {
        ZStack {
            // Fullscreen camera ARView
            ARPin(screenSize: $screenSize, createdPinEntities: $createdPinEntities)
                .edgesIgnoringSafeArea(.all)
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            screenSize = proxy.size
                        }
                    }
                ).onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Lock the rotation to portrait
                    AppDelegate.orientationLock = .portrait
                }.onDisappear {
                    AppDelegate.orientationLock = .all // Disable the rotation lock
                }
            
            // Circle indicator
            Circle()
                .fill(Color.blue.opacity(0.9))
                .frame(width: 7, height: 7)
                .position(CGPoint(x: screenSize.width/2, y: screenSize.height/2))
            
            // Loading view
            ZStack {
                Color.white
                
                Text("Loading Resources...").foregroundColor(Color.black)
            }
            .opacity(viewModel.assetsLoaded ? 0 : 1)
            .ignoresSafeArea()
            .animation(Animation.default.speed(1),
                       value: viewModel.assetsLoaded)
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    @StateObject static var viewModel: ViewModel = {
        return ViewModel()
    }()
    
    static var previews: some View {
        ContentView()
            .environmentObject(viewModel)
    }
}
