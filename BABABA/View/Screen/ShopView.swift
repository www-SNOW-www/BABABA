//
//  ShopView.swift
//  BABABA
//
//  Created by Snow on 2023/02/24.
//

import SwiftUI

struct ShopView: View {
    // MARK: Gesture Properties
    @State var offsetY: CGFloat = 0
    @State var currentIndex: CGFloat = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            // MARK: Since Card Size is the Size of the Screen Width
            let cardSize = size.width
            
//            LinearGradient(colors: [
//                .clear,
//                Color(.gray).opacity(0.2),
//                Color(.gray).opacity(0.45),
//                Color(.gray).opacity(0.7)
//            ], startPoint: .top, endPoint: .bottom)
//            .frame(height: 300)
//            .frame(maxHeight: .infinity, alignment: .bottom)
//            .ignoresSafeArea()
            
            HeaderView()
            
            VStack(spacing: 0) {
                ForEach(shoe) { shoe in
                    ShoeView(shoe: shoe, size: size)
                }
            }
            .frame(width: size.width)
            .padding(.top, size.height - cardSize)
            .offset(y: offsetY)
            .offset(y: -currentIndex * cardSize)
        }
        .padding(.bottom, 100)
        .coordinateSpace(name: "SCROLL")
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged({ value in
                    // Slowing Down The Gesture
                    offsetY = value.translation.height * 0.4
                }).onEnded({ value in
                    let translation = value.translation.height
                    
                    withAnimation(.easeInOut) {
                        if translation > 0 {
                            // 250 -> Update it for your Own Usage
                            if currentIndex > 0 && translation > 250 {
                                currentIndex -= 1
                            }
                        } else {
                            if currentIndex < CGFloat(shoe.count - 1) && -translation > 250 {
                                currentIndex += 1
                            }
                        }
                        offsetY = .zero
                    }
                })
        )
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack {
            Link(destination: URL(string: "https://www.nike.com/jp/en/w/basketball-shoes-3glsmzy7ok")!, label: {
                Image(systemName: "cart")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
            })
            .padding(.vertical, 15)
            
            // Animated Slider
            GeometryReader {
                let size = $0.size
                
                HStack(spacing: 0) {
                    ForEach(shoe) {shoe in
                        VStack(spacing: 15) {
                            Text(shoe.title)
                                .font(.custom("BIZUDPGothic-Bold", size: 24))
                                .multilineTextAlignment(.center)
                            
                            Text(shoe.price)
                                .font(.custom("BIZUDPGothic-Regular", size: 20))
                        }
                        .frame(width: size.width)
                    }
                }
                .offset(x: currentIndex * -size.width)
                .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8), value: currentIndex)
            }
            .padding(.top, -5)
        }
        .padding(15)
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}

// MARK: Shoe View
struct ShoeView: View {
    var shoe: Shoe
    var size: CGSize
    var body: some View {
        let cardSize = size.width
        // Since I want to show Three max cards on the display
        let maxCardsDisplaySize = size.width * 2
        GeometryReader {proxy in
            let _size = proxy.size
            // MARK: Scaling Animation
            // Current Card Offset
            let offset = proxy.frame(in: .named("SCROLL")).minY-(size.height - cardSize)
            let scale = offset <= 0 ? (offset / maxCardsDisplaySize) : 0
            let reducedScale = 1 + scale
            let currentCardScale = offset / cardSize
            
            Image(shoe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width, height: _size.height)
                // To Avoid Warning
                // MARK: Updating Anchor Based on the Current Card Scale
                .scaleEffect(reducedScale < 0 ? 0.001 : reducedScale, anchor: .init(x: 0.5, y: 1 - (currentCardScale / 2.5)))
                // MARK: When it's Coming from bottom Animating the Scale Large to Actual
                .scaleEffect(offset > 0 ? 1 + currentCardScale : 1, anchor: .top)
                // MARK: To Remove the Excess Next View Using Offest to Move the View in Real Time
                .offset(y: offset > 0 ? currentCardScale * 200 : 0)
                // Making it More Compact
                .offset(y: currentCardScale * -130)
            
        }
        .frame(height: cardSize)
    }
}
