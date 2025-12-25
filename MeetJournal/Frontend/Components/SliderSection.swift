//
//  SliderSection.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct SliderSection: View {
    var colorScheme: ColorScheme
    var title: String
    @Binding var value: Int
    var minString: String
    var maxString: String
    
    @State private var dragOffset: CGFloat = 0
    @State private var lineWidth: CGFloat = 0
    
    let minValue = 1
    let maxValue = 5
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline.bold())
            
            Text("\(value)")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(blueEnergy)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(blueEnergy.opacity(0.2))
                        .frame(height: 8)
                    
                    HStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { position in
                            Circle()
                                .fill(value == position ? blueEnergy : blueEnergy.opacity(0.3))
                                .frame(width: 12, height: 12)
                            
                            if position < 5 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Circle()
                        .fill(blueEnergy)
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .offset(x: circlePosition(in: geometry.size.width))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    let totalWidth = geometry.size.width - 40
                                    let newOffset = gesture.location.x - 20
                                    dragOffset = min(max(newOffset, 0), totalWidth)
                                    
                                    let segmentWidth = totalWidth / CGFloat(maxValue - minValue)
                                    let newValue = Int(round(dragOffset / segmentWidth)) + minValue
                                    value = min(max(newValue, minValue), maxValue)
                                }
                                .onEnded { _ in
                                    dragOffset = 0
                                }
                        )
                }
                .frame(height: 40)
                .onAppear {
                    lineWidth = geometry.size.width
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 20)
            
            HStack {
                Text(minString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(maxString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .foregroundStyle(colorScheme == .light ? .black : .white)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .light ? .white : .black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(colorScheme == .light ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private func circlePosition(in width: CGFloat) -> CGFloat {
        let totalWidth = width - 40
        let segmentWidth = totalWidth / CGFloat(maxValue - minValue)
        return CGFloat(value - minValue) * segmentWidth
    }
}
