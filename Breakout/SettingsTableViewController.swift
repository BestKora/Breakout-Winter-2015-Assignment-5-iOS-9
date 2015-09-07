//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Jeroen Schonenberg on 16/05/15.
//  Copyright (c) 2015 private. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var levelSegmentedControl: UISegmentedControl!

    @IBOutlet weak var paddleWidthSegmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var controlByTiltingSwitch: UISwitch!
    
    @IBOutlet weak var ballCountLabel: UILabel!
    @IBOutlet weak var ballCountStepper: UIStepper!
    @IBOutlet weak var ballSpeedModifierSlider: UISlider!
    
     private let settings = Settings()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ballSpeedModifierSlider.value = settings.ballSpeedModifier
        controlByTiltingSwitch.on = settings.controlWithTilt
        ballCountStepper.value = Double(settings.maxBalls)
        ballCountLabel.text = "\(Int(ballCountStepper.value))"
        
        levelSegmentedControl.selectedSegmentIndex = Levels.levels.find { $0 == self.settings.level } ?? (levelSegmentedControl.numberOfSegments - 1)
        
        switch(settings.paddleWidth){
        case PaddleWidths.Small: paddleWidthSegmentedControl.selectedSegmentIndex = 0
        case PaddleWidths.Medium: paddleWidthSegmentedControl.selectedSegmentIndex = 1
        case PaddleWidths.Large: paddleWidthSegmentedControl.selectedSegmentIndex = 2
        default: paddleWidthSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func PaddleWidthChanged(sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex {
        case 0: settings.paddleWidth = PaddleWidths.Small
        case 1: settings.paddleWidth = PaddleWidths.Medium
        case 2: settings.paddleWidth = PaddleWidths.Large
        default: settings.paddleWidth = PaddleWidths.Medium
        }
    }
    
    @IBAction func levelChanged(sender: UISegmentedControl) {
        
        settings.level = Levels.levels[sender.selectedSegmentIndex]
    }
    
    @IBAction func TiltingChanged(sender: UISwitch)
    {
        settings.controlWithTilt = sender.on
    }
    
    @IBAction func ballCountChanged(sender: UIStepper)
    {
        settings.maxBalls = Int(ballCountStepper.value)
        ballCountLabel.text = "\(Int(ballCountStepper.value))"
    }
    
    @IBAction func ballSpeedModifierChanged(sender: UISlider)
    {
        settings.ballSpeedModifier = ballSpeedModifierSlider.value
    }
    
}

private struct PaddleWidths {
    static let Small = 20
    static let Medium = 33
    static let Large = 50
}
