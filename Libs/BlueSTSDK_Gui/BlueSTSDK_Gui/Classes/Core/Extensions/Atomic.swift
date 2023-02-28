//
//  Atomic.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 14/01/21.
//

import Foundation

public class Atomic<A>
{
    private let queue = DispatchQueue(label: "AtomicQueueSerial")
    private var _value: A
    
    public init(_ value: A)
    {
        self._value = value
    }
    
    public var value: A {
        get {
            return queue.sync { self._value }
        }
        set {
            queue.sync { self._value = newValue }
        }
    }
}
