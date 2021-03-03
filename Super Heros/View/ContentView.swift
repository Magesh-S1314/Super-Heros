//
//  ContentView.swift
//  Super Heros
//
//  Created by magesh on 02/03/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var isActive:Bool = false
    @State private var image: Image = Image("img1")
    @StateObject var UIState = UIStateModel()
    
    var body: some View {
        NavigationView{
            VStack {
                if self.isActive {
                    HerosCarousel()
                        .environmentObject(UIState)
                } else {
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
                        image
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .scaledToFill()
                        Text("Super Heros")
                            .foregroundColor(.white)
                            .font(Font.system(size: 60))
                            .bold()
                            .padding(.bottom, 50)
                    }).onAppear(perform: {
                        self.animate()
                    })
                }
            }
        }
        .statusBar(hidden: true)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        
    }
    
    private func animate() {
        var imageIndex: Int = 0
        let imageCount = 10
        
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            if imageIndex < imageCount {
                imageIndex += 1
                self.image = Image("img\(imageIndex)")
            }
            else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isActive = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
