//
//  Utility.swift
//  VibrateExperiment
//
//  Created by Griffen Morrison on 10/30/20.
//  Copyright © 2020 Griffen Morrison. All rights reserved.
//

import Foundation

extension Float {
    func floatToString(digits: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = digits
        formatter.minimumFractionDigits = digits
        formatter.numberStyle = .decimal
        return formatter.string(for: self)
    }
}
