//
//  Closures.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

typealias VoidClosure = (() -> Void)
typealias StringClosure = ((String) -> Void)
typealias IntClosure = ((Int) -> Void)
typealias DoubleClosure = ((Double) -> Void)
typealias AnyClosure<T: Any> = ((T) -> Void)
typealias BoolClosure = ((Bool) -> Void)
typealias IndexPathClosure = (([IndexPath]) -> Void)

