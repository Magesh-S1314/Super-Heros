//
//  HerosCarousel.swift
//  Super Heros
//
//  Created by magesh on 02/03/21.
//

import SwiftUI
import UIKit

struct HerosCarousel: View {
    @EnvironmentObject var UIState: UIStateModel
    @State var searchText = ""
    @State var filter = 0
    
    @State var showModel: Bool = false
    
    let networkManager = NetworkManager()
    let queue = DispatchQueue.global(qos: .userInteractive)
    let semaPhore = DispatchSemaphore(value: 0)
    
    @State var heros: [SuperHeroModel] = []
    
    @State var tempHeros: [SuperHeroModel] = []
    @State var tempHero2: [SuperHeroModel] = []
    @State var templastId: Int = 1
    
    @State private var shouldAnimate = true
    
    
    @State var isSearch: Bool? = nil
    @State var didStarted = false
    @State var isLoading = false
    
    @State var lastId: Int = 1
    @State var newCount = 0
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 15
        let cardHeight: CGFloat = 420
        
        
        return NavigationView {
            Canvas {
                VStack(alignment: .center){
                    SearchBar(text: $searchText, filter: $filter)
                        .foregroundColor(.white)
                        .background(Color.white)
                        .cornerRadius(5)
                        .frame(width: UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2))
                        .padding(.top, 30)
                        .padding(.bottom, 10)
                    Spacer()
                    Group{
                        if heros.isEmpty{
                            ActivityIndicator(shouldAnimate: $shouldAnimate).frame(width: 60, height: 60, alignment: .center)
                        }else{
                            Carousel(
                                numberOfItems: CGFloat(tempHero2.count),
                                spacing: spacing,
                                widthOfHiddenCards: widthOfHiddenCards
                            ) {
                                ForEach(tempHero2, id: \.id) { item in
                                    Item(
                                        _id: tempHero2.firstIndex(of: item) ?? 0,
                                        spacing: spacing,
                                        widthOfHiddenCards: widthOfHiddenCards,
                                        cardHeight: cardHeight
                                    ) {
                                        MyCard(item: item)
                                    }
                                    .environmentObject(UIState)
                                    .foregroundColor(Color.white)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color(.gray), radius: 4, x: 0, y: 4)
                                    .animation(.spring())
                                    .onTapGesture(perform: {
                                        showModel.toggle()
                                        UIApplication.shared.endEditing()
                                    })
                                    
                                        .fullScreenCover(isPresented: $showModel, content: {
                                            DetailView(hero: tempHero2[UIState.activeCard])
                                        })
                                    
                                }
                            }
                            .onAppear() {
                                self.shouldAnimate = false
                            }
                        }
                    }
                    
                    Spacer()
                    Text("Super Heros").bold().font(.system(size: 60)).foregroundColor(.white)
                        .padding(.bottom, 40)
                }
            }
            .onAppear(perform: LoadData)
            .onChange(of: UIState.activeCard){ (value) in
                guard isSearch == nil else { return }
                if value + 3 >= heros.count && !isLoading{
                    didStarted = false
                    LoadData()
                }
            }
            .onChange(of: isSearch){ (value) in
                if let value = value{
                    if value{
                        tempHeros = heros
                        templastId = lastId
                        UIState.activeCard = 0
                    }else{
                        heros = tempHeros
                        lastId = templastId
                        isSearch = nil
                        UIState.activeCard = 0
                    }
                }
            }
            .onChange(of: searchText){ value in
                tempHero2.removeAll()
                if !value.isEmpty{
                    if isSearch == nil{
                        isSearch = true
                    }
                    SearchData(string: value)
                }else{
                    isSearch = false
                }
            }
            .onChange(of: filter) { (_) in
                UIState.activeCard = 0
            }
            .onChange(of: heros) { (heros) in
                tempHero2.removeAll()
                tempHero2 = heros.filter({ (data) -> Bool in
                        switch filter{
                        case 1: return data.appearance.gender == "Male"
                        case 2: return data.appearance.gender == "Female"
                        default:
                            return true
                        }
                    })
            }
        }
        .navigationBarHidden(true)
    }
    
    func SearchData(string: String) {
        
        
        queue.async {
            networkManager.get(query: ["search" : string]){ (result: Result<SuperHeroSearchModel, Error>) in
            switch result {
            case .success(let data):
                print(data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    heros = data.results
                })
            case .failure(let error) :
                print(error)
            }
            semaPhore.signal()
            
            }
            
            semaPhore.wait()
        }
    }
    
    func LoadData() {
        print("******** LastId ********", lastId)
        guard isSearch == nil else {
            isLoading = false
            return
        }
        if didStarted {
            return
        }else{
            didStarted = true
            isLoading = true
        }
        
        var superHeros: [SuperHeroModel] = []
        
        let LocallastId = lastId + 1
        queue.async {
            for id in lastId...LocallastId {
                networkManager.get(data: id) { (result: Result<SuperHeroModel, Error>) in
                    switch result {
                    case .success(let data):
                        print(data)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            superHeros.append(data)
                        })
                    case .failure(let error) :
                        print(error)
                    }
                    
                    semaPhore.signal()
                }
                
                semaPhore.wait()
            }
            
            restoreArray(superHeros: superHeros)
        }
    }
    
    
    func restoreArray(superHeros: [SuperHeroModel]?) {
        
        var NewArray = superHeros?.sorted(by: { Int($0.id)! < Int($1.id)! }) ?? []
        let lastId = Int(NewArray.last?.id ?? "0")
        
        if let newId = lastId, self.lastId != newId {
            self.lastId = newId
        }else{
            self.lastId = self.lastId + 1
        }
        
        if self.heros.last?.id == NewArray.first?.id && !NewArray.isEmpty{
            NewArray.removeFirst()
        }
        
        newCount = newCount + NewArray.count
        
        self.heros.append(contentsOf: NewArray)
        
        if lastId != nil && newCount < 15{
            didStarted = false
            LoadData()
        }else{
            newCount = 0
            isLoading = false
        }
    }
}




public class UIStateModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat //= 8
    let spacing: CGFloat //= 16
    let widthOfHiddenCards: CGFloat //= 32
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: UIStateModel
        
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
        
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
                
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)

        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
            
        }.onEnded { value in
            self.UIState.screenDrag = 0

                    
                    if (value.translation.width < -50) &&  self.UIState.activeCard < Int(numberOfItems) - 1 {
                          self.UIState.activeCard = self.UIState.activeCard + 1
                          let impactMed = UIImpactFeedbackGenerator(style: .medium)
                          impactMed.impactOccurred()
                    }
                    
                    if (value.translation.width > 50) && self.UIState.activeCard > 0 {
                          self.UIState.activeCard = self.UIState.activeCard - 1
                          let impactMed = UIImpactFeedbackGenerator(style: .medium)
                          impactMed.impactOccurred()
                    }
            
                }
        )
    }
}

struct Canvas<Content : View> : View {
    let content: Content
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }.navigationBarHidden(true)
            
            
            .background(Image("BackGround").resizable().overlay(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.2), Color.black.opacity(0.5), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)).edgesIgnoringSafeArea(.all))
    }
}

struct Item<Content: View>: View {
    @EnvironmentObject var UIState: UIStateModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var _id: Int
    var content: Content

    @inlinable public init(
        _id: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
        self.cardHeight = cardHeight
        self._id = _id
    }

    var body: some View {
        content
            .frame(width: cardWidth, height: _id == UIState.activeCard ? cardHeight : cardHeight - 60, alignment: .center)
    }
}

struct HerosCarousel_Previews: PreviewProvider {
    static var state = UIStateModel()
    static var previews: some View {
        HerosCarousel().preferredColorScheme(.light).environmentObject(state)
    }
}
