//
//  SearchBar.swift
//  Super Heros
//
//  Created by magesh on 02/03/21.
//

import SwiftUI
 
struct SearchBar: View {
    @Binding var text: String
    @Binding var filter: Int
 
    @State private var isEditing = false
    @State private var showingActionSheet = false
 
    var body: some View {
        HStack {
 
            TextField("Search", text: $text)
                .foregroundColor(.black)
                .frame(height: 40)
                .padding(8)
                .padding(.leading, 30)
                .background(Color(.white))
                .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
             
                    if isEditing {
                        Button(action: {
                            self.text = ""
                            self.isEditing = false
                            UIApplication.shared.endEditing()
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                }
            )
                .onTapGesture {
                    self.isEditing = true
                }
            
            
            Image("filter").resizable().scaledToFit().frame(width: 50, height: 25, alignment: .center)
                .onTapGesture {
                    showingActionSheet.toggle()
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Select Gender"), message: Text(""), buttons: [
                        .default(Text("Male")) { self.filter = 1 },
                        .default(Text("Female")) { self.filter = 2 },
                        .default(Text("All")) { self.filter = 0 },
                        .cancel()
                    ])
                }
        }
    }
}

//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar(text: .constant(""))
//    }
//}


struct MyCard: View {
    let item: SuperHeroModel
    @State var image: Image?

    init(item: SuperHeroModel) {
        self.item = item
    }
   var body: some View {
    
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 25
        let cardHeight: CGFloat = 430
    
        VStack(spacing: 0) {
            image ?? Image("PlaceHolder")
                .resizable()
                
            Text(item.name)
                .bold()
                .font(.title)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                .frame(width: UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2))
                .background(Color.black.opacity(0.9))

        }
        .onAppear(perform: {
            self.getImage(url: item.image.url)
        })
        .padding(12)
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

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
