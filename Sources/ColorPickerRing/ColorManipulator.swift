//
//  ColorManipulator.swift
//  
//
//  Created by Philippe Peirano on 2020-09-03.
//

import SwiftUI
import Combine
import DynamicColor

/// Allows to mamipulate the component of a color binding
/// Requires Combine to avoid infinte loop (changing hue -> changes bould color -> redraw view -> set hue)
public class ColorManipulator : ObservableObject
{
	public init(color boundColor: Binding<DynamicColor>) {
		self.color = boundColor.wrappedValue
		self._boundColor = boundColor
		
		// do this before setting up the publishers
		let components = self.color.toHSBComponents()
		self.hue = components.h
		self.saturation = components.s
		self.brightness = components.b
		self.alpha = color.alphaComponent

		self.setupPublishers()
	}
	
	
	// Angle to Hue conversion
	public var angularHue: Angle {
		get {
			Angle(turn: Double(self.hue))
		}
		set(angle) {
			self.hue = CGFloat(angle.turn)
		}
	}
	
	// MARK:- SwiftUI interface
	// those properties will be kept in sýnc with boundColor
	@Published public var hue : CGFloat = 1.0
	@Published public var saturation : CGFloat = 1.0
	@Published public var brightness : CGFloat = 1.0
	@Published public var alpha : CGFloat = 1.0
	@Published var color : DynamicColor
	
	// MARK:- Output
	@Binding public var boundColor : DynamicColor

	// MARK:- Publishers
	private var cancellables : Set<AnyCancellable> = []

	// Compute a new color when any of the components changes
	private var colorPublisher : AnyPublisher<DynamicColor, Never> {
		Publishers.CombineLatest4(self.$hue, self.$saturation, self.$brightness, self.$alpha)
			.map { h, s, b, a in
				return DynamicColor(hue: h, saturation: s, brightness: b, alpha: a)
		}.eraseToAnyPublisher()
	}
	
	func setupPublishers()
	{
		self.colorPublisher
			.receive(on: RunLoop.main)
			.sink {
				self.color = $0
				self.boundColor = $0
			}
			.store(in: &self.cancellables)
	}
}
