//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Tatiana Kornilova on 9/4/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreMotion

class BreakoutViewController: UIViewController, BreakoutCollisionBehaviorDelegate {
    private struct Const {
        static let gameOverTitle = "Game over!"
        static let congratulationsTitle = "Congratulations!"
        
        static let gamefieldBoundaryId = "gamefieldBoundary"
        static let paddleBoundaryId = "paddleBoundary"
        
        static let minBallLaunchAngle = 210
        static let maxBallLaunchAngle = 330
        static let minLaunchSpeed = CGFloat(0.2)
        static let maxLaunchSpeed = CGFloat(0.8)
        static let pushSpeed = CGFloat(0.05)
        
        static let maxPaddleSpeed = 25.0
    }

    @IBOutlet var breakoutView: BreakoutView!{
        didSet{
            breakoutView.initialize()
            breakoutView.paddleWidthPercentage = settings.paddleWidth
            breakoutView.level = settings.level
            breakoutView.initialize()
     }
    }
    
    @IBOutlet var ballsLeftLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    let motionManager = CMMotionManager()
    let settings = Settings()
    private var firstTimeLoading = true
    private var ballVelocity = [CGPoint]()
    private var gameViewSizeChanged = true

    
    private var launchSpeedModifier = Settings().ballSpeedModifier
    
    private var maxBalls: Int = Settings().maxBalls {
        didSet { ballsLeftLabel?.text = "⦁".`repeat`(maxBalls - ballsUsed) }
    }

    private var ballsUsed = 0 {
        didSet { ballsLeftLabel?.text = "⦁".`repeat`(maxBalls - ballsUsed) }
    }
    
    private var score = 0
        {
        didSet{ scoreLabel?.text = "\(score)" }
    }
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        breakoutView.behavior.breakoutCollisionDelegate = self
        breakoutView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "launchBall:") )
        breakoutView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panPaddle:"))
        motionManager.accelerometerUpdateInterval = 0.01

    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
        // Restart balls when tabbing back to Breakout game
        if !ballVelocity.isEmpty {
            for i in 0..<breakoutView.behavior.balls.count {
                breakoutView.behavior.startBall(breakoutView.behavior.balls[i], velocity: ballVelocity[i])
            }
        }
        

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.Motion.Manager.stopAccelerometerUpdates()
        // Stop balls
        ballVelocity = []
        for ball in breakoutView.behavior.balls {
            ballVelocity.append(breakoutView.behavior.stopBall(ball))
        }
    }

   
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        gameViewSizeChanged = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Reset bricks when rotation changes
        if gameViewSizeChanged {
            gameViewSizeChanged = false
            breakoutView.resetBricks()
        }
    }
    
  // MARK: - Load SEIITINGS
    
   func loadSettings() {
        
        // check if we need to reset the game
        
        // Setup accelerometer
        if settings.controlWithTilt {
            let motionManager = AppDelegate.Motion.Manager
            if motionManager.accelerometerAvailable {
                motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue())
                    { (data, error) -> Void in
                        self.breakoutView.translatePaddle( CGPoint(x: Const.maxPaddleSpeed * data!.acceleration.x, y: 0.0) )
                }
            }
        }
        maxBalls = settings.maxBalls
        launchSpeedModifier =  settings.ballSpeedModifier
        breakoutView.paddleWidthPercentage = settings.paddleWidth
        breakoutView.level = settings.level

        
        
    }
    
    // MARK: - RESET GAME

    func resetGame()
    {
        breakoutView.reset()
        ballsUsed = 0
        score = 0
        breakoutView.resetLayout()
    }
    
    // MARK: - Hit BRICK

    func ballHitBrick(behavior: UICollisionBehavior, ball: BallView, brickIndex: Int) {
       breakoutView.removeBrick(brickIndex)
        score++
        if breakoutView.bricks.count == 0 {
            showGameEndedAlert(true, message: "You beat the game!")
        }
    }
    
    func ballLeftPlayingField(ball: BallView)
    {
        if(ballsUsed == maxBalls) { // the last ball just left the playing field
             showGameEndedAlert(false, message: "You are out of balls!")
        }
        breakoutView.removeBall(ball)
    }
    
    // MARK: - ALERT
    
    func showGameEndedAlert(playerWon: Bool, message: String) {
        let title = playerWon ? Const.congratulationsTitle : Const.gameOverTitle
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .Default) {
            (action) in
              self.resetGame()
            })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
            (action) in
            // do nothing
            })
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    // on device shake
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        pushBalls()
    }

   // MARK: - GESTURES
    
   //---- ОБРАБОТКА ЖЕСТОВ
    func launchBall(gesture: UITapGestureRecognizer){
        if gesture.state == .Ended {
            if ballsUsed < maxBalls {
                ballsUsed++;
                breakoutView.addBall()
                
                let launchSpeed = Const.minLaunchSpeed + (Const.maxLaunchSpeed - Const.minLaunchSpeed) * CGFloat(launchSpeedModifier)
                breakoutView.behavior.launchBall(breakoutView.balls.last!, magnitude: launchSpeed, minAngle: Const.minBallLaunchAngle, maxAngle: Const.maxBallLaunchAngle)
            } else {
                pushBalls()
            }
        }
    }
    
    func pushBalls(){
        for ball in breakoutView.balls {
            breakoutView.behavior.launchBall(ball, magnitude: Const.pushSpeed)
        }
    }
    
    func panPaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            breakoutView.translatePaddle(gesture.translationInView(breakoutView))
            gesture.setTranslation(CGPointZero, inView: breakoutView)
        default: break
        }
    }
}
