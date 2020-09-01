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
	@Binding public var color : DynamicColor
    public var strokeWidth: CGFloat = 30
    
    public var body: some View {
        GeometryReader {
            ColorWheel(color: self.$color, frame: $0.frame(in: .local), strokeWidth: self.strokeWidth)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    public init(color: Binding<DynamicColor>, strokeWidth: CGFloat) {
		self._color = color
		self.strokeWidth = strokeWidth
    }
}

public struct ColorWheel: View {
	@Binding public var color : DynamicColor
    public var frame: CGRect
    public var strokeWidth: CGFloat
    
    public var body: some View {
			ZStack(alignment: .center) {
				// Color Gradient
				Circle()
					.strokeBorder(AngularGradient.conic, lineWidth: strokeWidth)
					.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
								.onChanged(self.update(value:))
					)
				// Color Selection Indicator
				Reticle(angle: color.angle, wheelWidth: strokeWidth)
					.foregroundColor(Color(color))
					.overlay(
						Reticle(angle: color.angle, wheelWidth: strokeWidth)
							.stroke(Color(UIColor.label), lineWidth: 2)
							.allowsHitTesting(false)
					)
			}
    }
    
    func update(value: DragGesture.Value) {
        self.color = Angle(radians: radCenterPoint(value.location, frame: self.frame)).color
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

struct Reticle : Shape {
	public var angle : Angle
	public var wheelWidth : CGFloat

	func path(in rect: CGRect) -> Path {
		var p = Path()
		
		let wheelCenter = CGPoint(x: rect.midX, y: rect.midY)
		let wheelRadius = rect.width / 2.0
		// calculate the angle that makes the reticle fill a circle with a diameter is equal to the wheel width.
		let delta = Angle(radians: asin(Double(wheelWidth / (wheelRadius - (wheelWidth / 2.0)) / 2.0)))

		p.addArc(center: wheelCenter, radius: wheelRadius, startAngle: angle + delta, endAngle: angle - delta, clockwise: true)
		p.addArc(center: wheelCenter, radius: wheelRadius - wheelWidth, startAngle: angle - delta, endAngle: angle + delta, clockwise: false)
		p.closeSubpath()
		
		return p
	}
}
