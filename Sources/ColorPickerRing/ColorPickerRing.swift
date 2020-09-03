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

@available(iOS 14.0, *)
public struct ColorPickerRing<Medalion> : View
	where Medalion : View
{
	@Binding public var color : DynamicColor
	public var strokeWidth: CGFloat
	public var medalion : Medalion?
	
    public var body: some View {
		ColorPickerRingImpl(components: ColorManipulator(color: $color), ringWidth: self.strokeWidth, medalion: medalion)
	}

	public init(color: Binding<DynamicColor>, strokeWidth: CGFloat = 30.0) {
		self._color = color
		self.strokeWidth = strokeWidth
		self.medalion = nil
	}
	
	public init(color: Binding<DynamicColor>, strokeWidth: CGFloat = 30.0, @ViewBuilder around medalion: () -> Medalion)
	{
		self.init(color: color, strokeWidth: strokeWidth)
		self.medalion = medalion()
	}
}

@available(iOS 14.0, *)
public struct ColorPickerRingImpl<Medalion> : View
	where Medalion : View
{
	@StateObject public var components : ColorManipulator
	public var ringWidth: CGFloat = 30
	public var medalion : Medalion?

	private var medalionView : AnyView {
		if let _medalion = self.medalion {
			return AnyView(_medalion)
		} else {
			return AnyView(EmptyView())
		}
	}
	
	public var body: some View {
		VStack {
			GeometryReader {
				ColorWheel(components: self.components, frame: $0.frame(in: .local), strokeWidth: self.ringWidth)
					.overlay(self.medalionView)
			}
			.aspectRatio(1, contentMode: .fit)
			HStack {
				Text("Saturation").font(.caption)
				Slider(value: self.$components.saturation, in: 0...1.0,
					   minimumValueLabel: Text("0.0" ).font(.caption),
					   maximumValueLabel: Text("1.0" ).font(.caption), label: { EmptyView() })
				Text("= \(self.components.saturation, specifier: "%.2f")").font(.caption)
			}
			HStack {
				Text("Brightness").font(.caption)
				Slider(value: self.$components.brightness, in: 0...1.0,
					   minimumValueLabel: Text("0.0" ).font(.caption),
					   maximumValueLabel: Text("1.0" ).font(.caption),
					   label: {
						Text("label is never displayed?!")
				})
				Text("= \(self.components.brightness, specifier: "%.2f")").font(.caption)
			}
			HStack {
				Text("Alpha").font(.caption)
				Slider(value: self.$components.alpha, in: 0...1.0,
					   minimumValueLabel: Text("0.0" ).font(.caption),
					   maximumValueLabel: Text("1.0" ).font(.caption),
					   label: {
						Text("label is never displayed?!")
				})
				Text("= \(self.components.alpha, specifier: "%.2f")").font(.caption)
			}
		}
	}
}

public struct ColorWheel: View {
	@ObservedObject public var components : ColorManipulator
	
    public var frame: CGRect
    public var strokeWidth: CGFloat
    
    public var body: some View {
			ZStack(alignment: .center) {
				// Color Gradient
				Circle()
					.strokeBorder(AngularGradient.hue(base: self.components.color),
								  lineWidth: strokeWidth)
					.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
								.onChanged(self.update(value:))
					)
				// Color Selection Indicator
				Reticle(angle: self.components.angularHue, wheelWidth: strokeWidth)
					.foregroundColor(self.components.color.native)
					.overlay(
						Reticle(angle: self.components.angularHue, wheelWidth: strokeWidth)
							.stroke(Color(UIColor.label), lineWidth: 2)
					)
			}
    }
    
    func update(value: DragGesture.Value) {
		self.components.angularHue = Angle(radians: radCenterPoint(value.location, frame: self.frame))
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
