//
//  VibrationViewModel.swift
//  VibrateExperiment
//
//  Created by Griffen Morrison on 10/30/20.
//  Copyright © 2020 Griffen Morrison. All rights reserved.
//

import Foundation
import CoreHaptics

//MARK: VibrationViewModel
class VibrationViewModel {
    
    var vibrations: [VibrationModel] = []
    
    func add(vibration: VibrationModel) {
        vibrations.append(vibration)
    }
    
    func delete(index: Int) {
        vibrations.remove(at: index)
    }
    
    func createPattern() -> CHHapticPattern? {
        var events: [CHHapticEvent] = []
        
        var time: Float = 0
        
        for vibration in vibrations {
            let intensityPar = CHHapticEventParameter(parameterID: .hapticIntensity, value: vibration.intensity)//0 to 1
            let sharpnessPar = CHHapticEventParameter(parameterID: .hapticSharpness, value: vibration.sharpness)//0 to 1
            let attackPar = CHHapticEventParameter(parameterID: .attackTime, value: vibration.attack) //-1 to 1
            let decayPar = CHHapticEventParameter(parameterID: .decayTime, value: vibration.decay)// -1 to 1
            let releasePar = CHHapticEventParameter(parameterID: .releaseTime, value: vibration.release)
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityPar, sharpnessPar, attackPar, decayPar, releasePar], relativeTime: TimeInterval(time))
            
            time += vibration.duration
            
            events.append(event)
        }
        return try? CHHapticPattern(events: events, parameters: [])
    }
    
}

//MARK: Vibration Model
class VibrationModel {
    var duration: Float = 0.1
    var intensity: Float = 0.0
    var sharpness: Float = 0.0
    var attack: Float = 0.0
    var decay: Float = 0.0
    var release: Float = 0.0
    
    init(duration: Float, intensity: Float, sharpness: Float, attack: Float, decay: Float, release: Float) {
        self.duration = duration
        self.intensity = intensity
        self.sharpness = sharpness
        self.attack = attack
        self.decay = decay
        self.release = release
    }
    
}
