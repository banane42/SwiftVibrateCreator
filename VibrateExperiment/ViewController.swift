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
    
    var duration: Float = 0.1
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
    
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var sharpnessSlider: UISlider!
    @IBOutlet weak var attackSlider: UISlider!
    @IBOutlet weak var decaySlider: UISlider!
    @IBOutlet weak var releaseSlider: UISlider!
    
    @IBOutlet weak var durationValueLabel: UILabel!
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
        let attackPar = CHHapticEventParameter(parameterID: .attackTime, value: attack) //-1 to 1
        let decayPar = CHHapticEventParameter(parameterID: .decayTime, value: decay)// -1 to 1
        let releasePar = CHHapticEventParameter(parameterID: .releaseTime, value: release)// 0 to 1
        //        let sustainPar = CHHapticEventParameter(parameterID: .sustained, value: Float(true))
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityPar, sharpnessPar, attackPar, decayPar, releasePar], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play vibration: \(error).")
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if let pattern = viewModel.createPattern() {
            do {
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Failed to play pattern: \(error).")
            }
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let newVibraiton = VibrationModel(duration: duration, intensity: intensity, sharpness: sharpness, attack: attack, decay: decay, release: release)
        viewModel.add(vibration: newVibraiton)
        tableView.reloadData()
    }
    
    @IBAction func durationValueChagned(_ sender: Any) {
        let val = durationSlider.value
        duration = val
        updateValueLabel(value: val, label: durationValueLabel)
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
            tableView.dataSource = self
            tableView.delegate = self
        } else {
            notSupportedView.isHidden = false
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateValueLabel(value: durationSlider.value, label: durationValueLabel)
        updateValueLabel(value: intensitySlider.value, label: intensityValueLabel)
        updateValueLabel(value: sharpnessSlider.value, label: sharpnessValueLabel)
        updateValueLabel(value: attackSlider.value, label: attackValueLabel)
        updateValueLabel(value: decaySlider.value, label: decayValueLabel)
        updateValueLabel(value: releaseSlider.value, label: releaseValueLabel)
        duration = durationSlider.value
        intensity = intensitySlider.value
        sharpness = sharpnessSlider.value
        attack = attackSlider.value
        decay = decaySlider.value
        release = releaseSlider.value
    }
    
    //MARK: Functions
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
        label.text = value.floatToString(digits: 2)
    }
    
}

//MARK: TableView Delegate
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
            self.tableView.reloadData()
            completionHandler(true)
        })
        deleteAction.image = UIImage(named: "")
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}

//MARK: VibrationTableViewCell
class VibrationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var intensityValueLabel: UILabel!
    @IBOutlet weak var sharpnessValueLabel: UILabel!
    @IBOutlet weak var attackValueLabel: UILabel!
    @IBOutlet weak var decayValueLabel: UILabel!
    @IBOutlet weak var releaseValueLabel: UILabel!
    
    func configure(model: VibrationModel) {
        durationValueLabel.text = model.duration.floatToString(digits: 2)
        intensityValueLabel.text = model.intensity.floatToString(digits: 2)
        sharpnessValueLabel.text = model.sharpness.floatToString(digits: 2)
        attackValueLabel.text = model.attack.floatToString(digits: 2)
        decayValueLabel.text = model.decay.floatToString(digits: 2)
        releaseValueLabel.text = model.release.floatToString(digits: 2)
    }
}

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

extension Float {
    func floatToString(digits: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = digits
        formatter.minimumFractionDigits = digits
        formatter.numberStyle = .decimal
        return formatter.string(for: self)
    }
}
