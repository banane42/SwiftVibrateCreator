//
//  ViewController.swift
//  VibrateExperiment
//
//  Created by Griffen Morrison on 10/28/20.
//  Copyright © 2020 Griffen Morrison. All rights reserved.
//

import UIKit
import CoreHaptics

class ViewController: UIViewController {

    var engine: CHHapticEngine?
    
    var intensity: Float = 0.0
    var sharpness: Float = 0.0
    var attack: Float = 0.0
    var decay: Float = 0.0
    var release: Float = 0.0
    
    let viewModel = VibrationViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notSupportedView: UIView!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var sharpnessSlider: UISlider!
    @IBOutlet weak var attackSlider: UISlider!
    @IBOutlet weak var decaySlider: UISlider!
    @IBOutlet weak var releaseSlider: UISlider!
    
    @IBOutlet weak var intensityValueLabel: UILabel!
    @IBOutlet weak var sharpnessValueLabel: UILabel!
    @IBOutlet weak var attackValueLabel: UILabel!
    @IBOutlet weak var decayValueLabel: UILabel!
    @IBOutlet weak var releaseValueLabel: UILabel!
    
    @IBAction func testButtonTapped(_ sender: Any) {
        print("intensity: \(intensity)")
        print("sharpness: \(sharpness)")
        print("attack: \(attack)")
        print("decay: \(decay)")
        print("release: \(release)")
        
        let intensityPar = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)//0 to 1
        let sharpnessPar = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)//0 to 1
        let attackPar = CHHapticEventParameter(parameterID: .attackTime, value: -1) //-1 to 1
        let decayPar = CHHapticEventParameter(parameterID: .decayTime, value: -1)// -1 to 1
        let releasePar = CHHapticEventParameter(parameterID: .releaseTime, value: 1)// 0 to 1
        //        let sustainPar = CHHapticEventParameter(parameterID: .sustained, value: Float(true))
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityPar, sharpnessPar, attackPar, decayPar, releasePar], relativeTime: 0)
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityPar, sharpnessPar, attackPar, decayPar, releasePar], relativeTime: 1)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityPar, sharpnessPar, attackPar, decayPar, releasePar], relativeTime: 2)
        
        do {
            let pattern = try CHHapticPattern(events: [event, event1, event2], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error).")
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func intensityValueChanged(_ sender: Any) {
        let val = intensitySlider.value
        intensity = val
        updateValueLabel(value: val, label: intensityValueLabel)
    }
    
    @IBAction func sharpnessValueChanged(_ sender: Any) {
        let val = sharpnessSlider.value
        sharpness = val
        updateValueLabel(value: val, label: sharpnessValueLabel)
    }
    
    @IBAction func attackValueChanged(_ sender: Any) {
        let val = attackSlider.value
        attack = val
        updateValueLabel(value: val, label: attackValueLabel)
    }
    
    @IBAction func decayValueChanged(_ sender: Any) {
        let val = decaySlider.value
        decay = val
        updateValueLabel(value: val, label: decayValueLabel)
    }
    
    @IBAction func releaseValueChanged(_ sender: Any) {
        let val = releaseSlider.value
        release = val
        updateValueLabel(value: val, label: releaseValueLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testButton.layer.cornerRadius = 5
        
        if configureHapticEngine() {
            
        } else {
            notSupportedView.isHidden = false
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateValueLabel(value: intensitySlider.value, label: intensityValueLabel)
        updateValueLabel(value: sharpnessSlider.value, label: sharpnessValueLabel)
        updateValueLabel(value: attackSlider.value, label: attackValueLabel)
        updateValueLabel(value: decaySlider.value, label: decayValueLabel)
        updateValueLabel(value: releaseSlider.value, label: releaseValueLabel)
    }
    
    func configureHapticEngine() -> Bool {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                engine = try CHHapticEngine()
            } catch {
                print("Error starting haptice engine. \(error)")
            }
            
            engine?.stoppedHandler = { reason in
                print("Engine stopped for \(reason)")
            }
            
            engine?.resetHandler = { [weak self] in
                print("Engine restarting...")
                do {
                    try self?.engine?.start()
                } catch {
                    print("Error starting haptice engine. \(error)")
                }
            }
                        
            engine?.notifyWhenPlayersFinished(finishedHandler: { error in
                print("We done playing")
                return .leaveEngineRunning
            })
            
            engine?.playsHapticsOnly = true
            
            engine?.start(completionHandler: { error in
                print("Engine started")
            })
        } else {
            print("Cannot support haptics")
        }
        return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    func updateValueLabel(value: Float, label: UILabel) {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.numberStyle = .decimal
        label.text = formatter.string(for: value)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.vibrations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VibrationTableViewCell", for: indexPath) as? VibrationTableViewCell else {
            fatalError()
        }
        
        cell.configure(model: viewModel.vibrations[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { _, _, completionHandler in
            self.viewModel.delete(index: indexPath.row)
            completionHandler(true)
        })
        deleteAction.image = UIImage(named: "")
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}

class VibrationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var intensityValueLabel: UILabel!
    @IBOutlet weak var sharpnessValueLabel: UILabel!
    @IBOutlet weak var attackValueLabel: UILabel!
    @IBOutlet weak var decayValueLabel: UILabel!
    @IBOutlet weak var releaseValueLabel: UILabel!
    
    func configure(model: VibrationModel) {
        intensityValueLabel.text = String(model.intensity)
        sharpnessValueLabel.text = String(model.sharpness)
        attackValueLabel.text = String(model.attack)
        decayValueLabel.text = String(model.decay)
        releaseValueLabel.text = String(model.release)
    }
    
}

class VibrationViewModel {
    
    var vibrations: [VibrationModel] = []
    
    func add(vibration: VibrationModel) {
        vibrations.append(vibration)
    }
    
    func delete(index: Int) {
        vibrations.remove(at: index)
    }
    
}

class VibrationModel {
    var intensity: Float = 0.0
    var sharpness: Float = 0.0
    var attack: Float = 0.0
    var decay: Float = 0.0
    var release: Float = 0.0
    
    init(intensity: Float, sharpness: Float, attack: Float, decay: Float, release: Float) {
        self.intensity = intensity
        self.sharpness = sharpness
        self.attack = attack
        self.decay = decay
        self.release = release
    }
    
}
