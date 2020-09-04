//
//  ColorExtension.swift
//  ColorPickerRing
//
//  Created by Hendrik Ulbrich on 16.07.19.
//

import SwiftUI
import DynamicColor

extension Angle {
	/// See Wikipedia https://en.wikipedia.org/wiki/Turn_(geometry)
	/// 1 = 360 degrees, 0.5 = 180 degrees, etc...
	var turn : Double {
		get {
			self.radians / (2 * .pi)
		}
		set(v) {
			self.radians =  Double(2 * .pi * v)
		}
	}
	
	public init(turn: Double) {
		self.init(radians: Double(2 * .pi * turn))
	}
}

extension DynamicColor {

	var native : Color {
		return Color(self)
	}
}


extension AngularGradient {
	static func hue(base: DynamicColor) -> AngularGradient {
		return AngularGradient(gradient: .angularHue(from: base), center: .center)
	}
}

extension Gradient {
	static func angularHue(from color: DynamicColor) -> Gradient {
		let components = color.toHSBComponents()
		let s = Double(components.s)
		let b = Double(components.b)
		let a = Double(color.alphaComponent)
		
		return
			Gradient(colors: [
				Color(hue: Angle(radians: 0/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 1/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 2/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 3/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 4/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 5/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 6/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 7/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 8/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians: 9/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians:10/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians:11/6 * .pi).turn, saturation: s, brightness: b, opacity: a),
				Color(hue: Angle(radians:12/6 * .pi).turn, saturation: s, brightness: b, opacity: a)
						])
	}
}

