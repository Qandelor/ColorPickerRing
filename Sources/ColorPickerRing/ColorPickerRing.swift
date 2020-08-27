//
//  ColorPickerRing.swift
//  ColorPickerRing
//
//  Created by Hendrik Ulbrich on 15.07.19.
//
//  This code uses:
//    https://developer.apple.com/documentation/swiftui/gestures/composing_swiftui_gestures
//  and
//    https://developer.apple.com/wwdc19/237

import SwiftUI
import DynamicColor

public struct ColorPickerRing : View {
    public var color: Binding<DynamicColor>
    public var strokeWidth: CGFloat = 30
    
    public var body: some View {
        GeometryReader {
            ColorWheel(color: self.color, frame: $0.frame(in: .local), strokeWidth: self.strokeWidth)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    public init(color: Binding<DynamicColor>, strokeWidth: CGFloat) {
       self.color = color
       self.strokeWidth = strokeWidth
    }
}

public struct ColorWheel: View {
    public var color: Binding<DynamicColor>
    public var frame: CGRect
    public var strokeWidth: CGFloat
    
    public var body: some View {
        let indicatorOffset = CGSize(
            width: cos(color.wrappedValue.angle.radians) * Double(frame.midX - strokeWidth / 2),
            height: sin(color.wrappedValue.angle.radians) * Double(frame.midY - strokeWidth / 2))
        return
			ZStack(alignment: .center) {
				// Color Gradient
				Circle()
					.strokeBorder(AngularGradient.conic, lineWidth: strokeWidth)
					.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
								.onChanged(self.update(value:))
					)
				// Color Selection Indicator
				Circle()
					.fill(Color(color.wrappedValue))
					.frame(width: strokeWidth, height: strokeWidth, alignment: .center)
					.fixedSize()
					.offset(indicatorOffset)
					.allowsHitTesting(false)
					.overlay(
						Circle()
							.stroke(Color(UIColor.label), lineWidth: 3)
							.offset(indicatorOffset)
							.allowsHitTesting(false)
					)
			}
    }
    
    public init(color: Binding<DynamicColor>, frame: CGRect, strokeWidth: CGFloat) {
       self.frame = frame
       self.color = color
       self.strokeWidth = strokeWidth
    }
    
    func update(value: DragGesture.Value) {
        self.color.wrappedValue = Angle(radians: radCenterPoint(value.location, frame: self.frame)).color
    }
    
	/// Convert location in view space to an angle in polar space.
	/// View space has origin in top,left with increase Y going "down"
	/// Polar space has origin in center of view with X and Y axis swapped
    func radCenterPoint(_ point: CGPoint, frame: CGRect) -> Double {
		let polarLocation = CGPoint(x: point.x - frame.midX, y: point.y - frame.midY)
		let adjustedRadians = atan2(Double(polarLocation.y), Double(polarLocation.x))
        return adjustedRadians < 0 ? adjustedRadians + .pi * 2 : adjustedRadians
    }
}

