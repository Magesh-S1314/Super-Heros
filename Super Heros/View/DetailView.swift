//
//  DetailView.swift
//  Super Heros
//
//  Created by magesh on 02/03/21.
//

import SwiftUI

struct DetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var hero: SuperHeroModel!
    @State var image: Image?
    
    
    var body: some View {
        ScrollView(){
            HStack(){
                Image("leftArrow").resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                    .cornerRadius(25)
                    .shadow(color: Color(.gray), radius: 4, x: 0, y: 4)
                    .onTapGesture(perform: {
                        presentationMode.wrappedValue.dismiss()
                    })
                Spacer()
                Text(hero.name)
                    .foregroundColor(.white)
                    .bold()
                    .font(.system(size: 50))
                    .shadow(color: Color(.gray), radius: 4, x: 0, y: 4)
            }.padding()
            .padding(.top, 20)
            VStack(){
                Group{
                    image ?? Image("PlaceHolder").resizable()
                }.scaledToFit().padding(12).cornerRadius(5)
                    
            }
            .onAppear(perform: {
                self.getImage(url: hero.image.url)
            })
            .background(Color.white)
            .cornerRadius(5)
            .padding()
            .shadow(color: Color(.gray), radius: 4, x: 0, y: 4)
            
            
            Group{
                
                VStack(alignment: .leading, spacing: 18){
                    
                        Text("Power Stats")
                            .bold()
                            .font(.title)
                    HStack(alignment: .center){
                        Spacer()
                        VStack(alignment: .center, spacing: 18){
                            ProgressBar(progress: Float((Int(hero.powerstats.intelligence) ?? 0 / 100) * 100), color: .blue)
                                .frame(width: 89, height: 89)
                                .padding()
                            Text("Intelligence").bold().font(.title2)
                        }
                        Spacer()
                        VStack(alignment: .center, spacing: 18){
                            ProgressBar(progress: Float((Int(hero.powerstats.power) ?? 0 / 100) * 100), color: .red)
                                .frame(width: 89, height: 89)
                                .padding()
                            Text("Power").bold().font(.title2)
                        }
                        Spacer()
                    }
                    HStack(alignment: .center){
                        Spacer()
                        VStack(alignment: .center, spacing: 18){
                            ProgressBar(progress: Float((Int(hero.powerstats.speed) ?? 0 / 100) * 100), color: .orange)
                                .frame(width: 89, height: 89)
                                .padding()
                            Text("Speed").bold().font(.title2)
                        }
                        Spacer()
                        VStack(alignment: .center, spacing: 18){
                            ProgressBar(progress: Float((Int(hero.powerstats.strength) ?? 0 / 100) * 100), color: .green)
                                .frame(width: 89, height: 89)
                                .padding()
                            Text("Strength").bold().font(.title2)
                        }
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 18){
                    Text("Apperance")
                        .bold()
                        .font(.title)
                    HStack(){
                        Text("Gender")
                        Spacer()
                        Text(hero.appearance.gender)
                            .foregroundColor(Color(.systemGray))
                    }
                    
                    HStack(){
                        Text("Race")
                        Spacer()
                        Text(hero.appearance.race)
                            .foregroundColor(Color(.systemGray))
                    }
                    HStack(){
                        Text("Height")
                        Spacer()
                        Text(hero.appearance.height[1])
                            .foregroundColor(Color(.systemGray))
                    }
                    HStack(){
                        Text("Weight")
                        Spacer()
                        Text(hero.appearance.weight[1])
                            .foregroundColor(Color(.systemGray))
                    }
                }
                
                    VStack(alignment: .leading, spacing: 18){
                        Text("Biography")
                            .bold()
                            .font(.title)
                        HStack(){
                            Text("Full name")
                            Spacer()
                            Text(hero.biography.fullName)
                                .foregroundColor(Color(.systemGray))
                        }
                        
                        HStack(){
                            Text("Place of birth")
                            Spacer()
                            Text(hero.biography.placeOfBirth)
                                .foregroundColor(Color(.systemGray))
                        }
                        HStack(){
                            Text("Publisher")
                            Spacer()
                            Text(hero.biography.placeOfBirth)
                                .foregroundColor(Color(.systemGray))
                        }
                        HStack(){
                            Text("Alignment")
                            Spacer()
                            Text(hero.biography.alignment)
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(5)
            .padding()
            .shadow(color: Color(.gray), radius: 4, x: 0, y: 4)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .statusBar(hidden: true)
        
        .background(Image("BackGround").resizable().overlay(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.2), Color.black.opacity(0.5), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)).edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
    
    
    func getImage(url: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            ImageSourceHandler.loadImageUsingCacheWithUrlString(urlString: url) { (image) in
                if let image = image{
                    DispatchQueue.main.async {
                        self.image = Image(uiImage: image).resizable()
                    }
                }
            }
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(hero: <#SuperHeroModel#>, image: <#Image#>)
//    }
//}


struct ProgressBar: View {
    var progress: Float
    var color: Color = Color.red
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.title3)
                .bold()
        }
    }
}
