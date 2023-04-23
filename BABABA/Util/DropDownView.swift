//
//  DropDownView.swift
//  BABABA
//
//  Created by Snow on 2023/01/17.
//

import SwiftUI

// MARK: Custom View Builder
struct DropDown: View {
    // Drop Down Properties
    var content: [String]
    @Binding var selection: String
    var activeTint: Color
    var inActiveTint: Color
    var dynamic: Bool = true
    // View Properties
    @State private var expandeView: Bool = false
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(alignment: .leading, spacing: 0) {
                if !dynamic {
                    RowView(selection, size)
                }
                ForEach(content.filter {
                    dynamic ? true : $0 != selection
                }, id: \.self) { title in
                    RowView(title, size)
                }
            }
            .background {
                Rectangle()
                    .fill(inActiveTint)
            }
            // Moving View Based on the Selection
            .offset(y: dynamic ? (CGFloat(content.firstIndex(of: selection) ?? 0) * -45) : 0)
        }
        .frame(height: 45)
        .overlay(alignment: .trailing) {
            Image(systemName: "chevron.up.chevron.down")
                .padding(.trailing, 10)
        }
        .mask(alignment: .top) {
            Rectangle()
                .frame(height: expandeView ? CGFloat(content.count) * 45 : 45)
                // Moving the Mask Based on the Selection, so that Every Content Will be Visiable
                .offset(y: dynamic && expandeView ? (CGFloat(content.firstIndex(of: selection) ?? 0) * -45) : 0)
        }
    }
    // Row View
    @ViewBuilder
    func RowView( _ title: String, _ size: CGSize) -> some View {
        Text(title)
            .font(.custom("BIZUDPGothic-Regular", size: 15))
            .font(.callout)
            .padding(.horizontal)
            .frame(width: size.width, height: size.height, alignment: .leading)
            .background {
                if selection == title {
                    Rectangle()
                        .fill(activeTint)
                        .transition(.identity)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                    // If Expanded then Make Selection
                    if expandeView {
                        expandeView = false
                        // Disabling Animation for Non-Dynamic Conents
                        if dynamic {
                            selection = title
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                selection = title
                            }
                        }
                    } else {
                        // Disabling Outside Taps
                        if selection == title {
                            expandeView = true
                        }
                    }
                }
            }
    }
}
