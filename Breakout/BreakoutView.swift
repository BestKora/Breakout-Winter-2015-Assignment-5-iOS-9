//
//  BreakoutView.swift
//  Breakout
//
//  Created by Tatiana Kornilova on 9/4/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit
class BreakoutView: UIView {

  struct Constants {
        static let selfBoundaryId = "selfBoundary"
        static let paddleBoundaryId = "paddleBoundary"
        static let BallSize = CGSize(width: 20, height: 20)
        static let BallSpacing: CGFloat = 3

        static let PaddleBottomMargin: CGFloat = 10.0
        static let PaddleHeight: Int = 15
        static let PaddleColor = UIColor.whiteColor()
        static let BrickHeight: CGFloat = 20.0
        static let BrickSpacing: CGFloat = 5.0
        static let BricksTopSpacing: CGFloat = 20.0
        static let BrickSideSpacing: CGFloat = 10.0
    }
    
 lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self) }()
    var behavior = BreakoutBehavior()
    
    var balls = [BallView]()
    var bricks =  [Int:BrickView]()
    
    lazy var paddle: PaddleView = {
        let width = self.bounds.size.width / 100.0 * CGFloat(self.paddleWidthPercentage) //CGFloat(Settings().paddleWidth)
        let paddleSize = CGSize(width: width, height: CGFloat(Constants.PaddleHeight))

        let frame = CGRect(origin: CGPoint(x: -1, y: -1), size: paddleSize )
        let paddle = PaddleView(frame: frame)
        paddle.backgroundColor = Constants.PaddleColor
        return paddle;
        }()
    
    var columns: Int?
    var level :[[Int]]? {
        didSet {
            if let newLevel = level ,let oldLevel = oldValue{
                if newLevel == oldLevel {return}
            }
            columns = level?[0].count
            reset()
        }
    }
    
    // MARK: - LIFE CYCLE
    
    func initialize() {
        self.backgroundColor = UIColor.blackColor()
        animator.addBehavior(behavior)
     }


    override func layoutSubviews() {
        super.layoutSubviews()
             resetLayout()
    }

    func resetLayout()
    {
        var gameBounds = self.bounds
        gameBounds.size.height *= 2.0
        behavior.addBoundary(UIBezierPath(rect: gameBounds), named: Constants.selfBoundaryId)
        
        resetPaddlePosition()
          // If needed put ball back inside breakoutView after rotation
        for ball in balls {
            if !CGRectContainsRect(gameBounds, ball.frame) {
                placeBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
    }

    
    // Remove all subviews
    func clearView() {
        for subView in subviews {
                subView.removeFromSuperview()
        }
    }

    func reset()
    {
        // reset behavior
        clearView()
        behavior.removeAllBoundaries();
        behavior.removeAllBalls()
        
        // reset vars
        balls = [BallView]()
        bricks = [Int:BrickView]()
        createBricks()
        if !(self.subviews ).contains(paddle)  {
            self.addSubview(paddle)
        }
        resetPaddlePosition()
    }
    
    // MARK: - BALLS
  
    func addBall() {
        let ball = BallView(frame: CGRect(origin: CGPoint(x: paddle.center.x, y: paddle.frame.minY - Constants.BallSize.height), size: Constants.BallSize))
        balls.append(ball)
        self.behavior.addBall(ball)
    }
    
    func removeBall(ball: BallView){
        self.behavior.removeBall(ball)
        if let index = balls.indexOf(ball) {
            balls.removeAtIndex(index)
        }
    }
    
    private func placeBall(ball: UIView) {
        ball.center = self.center
    }
    

    // MARK: - BRICKS

    
    func createBricks() {
        if let arrangement = level {
            
            if arrangement.count == 0 { return }    // no rows
            if arrangement[0].count == 0 { return } // no columns
            
            let rows = arrangement.count
            let columns = arrangement[0].count
            let width = (self.bounds.size.width - 2 * Constants.BrickSpacing) / CGFloat(columns)
            
            for row in 0 ..< rows {
                let columns = arrangement[row].count
                for column in 0 ..< columns {
                    if arrangement[row][column] == 0 { continue }
                    
                    let x = Constants.BrickSpacing + CGFloat(column) * width
                    let y = Constants.BricksTopSpacing + CGFloat(row) * Constants.BrickHeight + CGFloat(row) * Constants.BrickSpacing * 2
                    let hue = CGFloat(row) / CGFloat(rows)
                    createBrick(width, x: x, y: y, hue: hue)
                }
            }
        }
    }
    
    func createBrick(width: CGFloat, x: CGFloat, y: CGFloat, hue: CGFloat) {
        var frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: Constants.BrickHeight))
        frame = CGRectInset(frame, Constants.BrickSpacing, 0)
        
        let brick = BrickView(frame: frame, hue: hue)
        bricks[bricks.count] = brick
        
        addSubview(brick)
        behavior.addBoundary( UIBezierPath(roundedRect: brick.frame, cornerRadius: brick.layer.cornerRadius), named: (bricks.count - 1) )
    }

    
    func removeBrick(brickIndex: Int) {
        behavior.removeBoundary(brickIndex)
        
        if let brick = bricks[brickIndex] {
            UIView.transitionWithView(brick, duration: 0.3, options: .TransitionFlipFromBottom, animations: {
                brick.alpha = 0.5
                }, completion: { (success) -> Void in
                    UIView.animateWithDuration(1.0, animations: {
                        brick.alpha = 0.0
                        }, completion: { (success) -> Void in
                            brick.removeFromSuperview()
                    })
            })
            
            bricks.removeValueForKey(brickIndex)
        }
    }
    
    func removeBrickWithoutAnimation(brickIndex: Int) {
        behavior.removeBoundary(brickIndex)
        
        if let brick = bricks[brickIndex] {
                brick.removeFromSuperview()
                bricks.removeValueForKey(brickIndex)
        }
    }
    
    func resetBricks(){
        let activeBricksSet = Set(bricks.keys)
        removeBricks()
        createBricks()
        for brick in bricks {
            let index = brick.0
             if  !activeBricksSet.contains(index) {
                 removeBrickWithoutAnimation(brick.0)
            }
        }
    }
    
    private func removeBricks() {
        if bricks.count == 0 {return}
        for brick in bricks {
            removeBrickWithoutAnimation(brick.0)
        }
    }
    
    // MARK: - PADDLE

 
    var paddleWidthPercentage = 33 {
        didSet{
            paddle.bounds.size.width = self.bounds.size.width / 100.0 * CGFloat(paddleWidthPercentage)
         }
    }
    
    private var paddleSize : CGSize {
        let width = self.bounds.size.width / 100.0 * CGFloat(paddleWidthPercentage)
        return CGSize(width: width, height: CGFloat(Constants.PaddleHeight))
    }

    func translatePaddle(translation: CGPoint) {
        var newFrame = paddle.frame
        newFrame.origin.x = max( min(newFrame.origin.x + translation.x, self.bounds.maxX - paddle.bounds.size.width), 0.0)         
        for ball in balls {
            if CGRectContainsRect(newFrame, ball.frame) {
                return
            }
        }
        paddle.frame = newFrame;
        updatePaddleBoundary()
    }
    
 func resetPaddlePosition() {
       paddle.frame.size = paddleSize
       if !CGRectContainsRect(self.bounds, paddle.frame) {
            paddle.center = CGPoint(x: self.bounds.midX, y: self.bounds.maxY - paddle.bounds.height - Constants.PaddleBottomMargin)
        } else {
            paddle.center = CGPoint(x: paddle.center.x, y: self.bounds.maxY - paddle.bounds.height - Constants.PaddleBottomMargin)
        }
        
        updatePaddleBoundary()
    }
    
    func updatePaddleBoundary() {
        behavior.addBoundary(UIBezierPath(ovalInRect: paddle.frame), named: Constants.paddleBoundaryId)
    }

}
