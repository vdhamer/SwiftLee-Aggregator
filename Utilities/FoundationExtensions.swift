//
//  FoundationExtensions.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 25/06/2022.
//

import Foundation

extension NSPredicate { // just a convenience thing
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}
