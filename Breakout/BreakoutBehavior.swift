//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Tatiana Kornilova on 9/4/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit

     // MARK: - PROTOCOL

    protocol BreakoutCollisionBehaviorDelegate: class {
        func ballHitBrick(behavior: UICollisionBehavior, ball: BallView, brickIndex: Int)
        func ballLeftPlayingField(ball: BallView)
    }

    private struct Constants {
        struct Ball {
            static let MinVelocity = CGFloat(100.0)
            static let MaxVelocity = CGFloat(1000.0)
        }
       }

    // MARK: - CLASS BreakoutBehavior

    class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
        weak var breakoutCollisionDelegate: BreakoutCollisionBehaviorDelegate?
        let gravity = UIGravityBehavior()
        
        var collisionDelegate: UICollisionBehaviorDelegate? {
            didSet { collider.collisionDelegate = collisionDelegate}
        }
        
    // MARK: - COLLIDER
        
    private lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = false
        lazyCollider.collisionDelegate = self
        lazyCollider.action = { [unowned self] in
            for ball in self.balls {
                if !CGRectIntersectsRect(self.dynamicAnimator!.referenceView!.bounds, ball.frame) {
                    self.breakoutCollisionDelegate?.ballLeftPlayingField( ball as BallView)
                }
                 self.ballBehavior.limitLinearVelocity(Constants.Ball.MinVelocity, max: Constants.Ball.MaxVelocity, forItem: ball as BallView)
            }
        }

        return lazyCollider
        }()
        
     // MARK: - ballBehavior

    private lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazyBallBehavior = UIDynamicItemBehavior()
        lazyBallBehavior.allowsRotation = false
        lazyBallBehavior.elasticity = 1.0
        lazyBallBehavior.friction = 0.0
        lazyBallBehavior.resistance = 0.0
        return lazyBallBehavior
        }()
    
    var gravityOn: Bool!
    
    var balls: [BallView] {
        get { return collider.items.filter{$0 is BallView}.map{$0 as! BallView} }
    }
        
   // MARK: - INIT
        
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
        
    // MARK: - BOUNDARIES
   
    func addBoundary(path: UIBezierPath, named identifier: NSCopying) {
        removeBoundary(identifier)
        collider.addBoundaryWithIdentifier(identifier, forPath: path)
    }
    
    func removeBoundary (identifier: NSCopying) {
        collider.removeBoundaryWithIdentifier(identifier)
    }
    func removeAllBoundaries() {
        collider.removeAllBoundaries()
    }

    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier boundaryId: NSCopying?, atPoint p: CGPoint) {
        if let brickIndex = boundaryId as? Int {
            if let ball = item as? BallView {
                self.breakoutCollisionDelegate?.ballHitBrick(behavior, ball: ball, brickIndex: brickIndex)
            }
        }
    }
    // MARK: - BALL
        
     func addBall(ball: UIView) {

        self.dynamicAnimator?.referenceView?.addSubview(ball)
      //  if gravityOn == true { gravity.addItem(ball) }
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        gravity.removeItem(ball)
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }

    func removeAllBalls(){
        for ball in balls {
            ballBehavior.removeItem(ball)
            collider.removeItem(ball)
            gravity.removeItem(ball)
            ball.removeFromSuperview()
        }
    }

    //  тормозим мячик
    func stopBall(ball: UIView) -> CGPoint {
        let linVeloc = ballBehavior.linearVelocityForItem(ball)
        ballBehavior.addLinearVelocity(CGPoint(x: -linVeloc.x, y: -linVeloc.y), forItem: ball)
        return linVeloc
    }
    
    //  запускаем мячик после торможения
    func startBall(ball: UIView, velocity: CGPoint) {
        ballBehavior.addLinearVelocity(velocity, forItem: ball)
    }
    
    //запуск мячика push
    func launchBall(ball: UIView, magnitude: CGFloat, minAngle: Int = 0, maxAngle: Int = 360) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        pushBehavior.magnitude = magnitude
        
        let randomAngle = minAngle + Int( arc4random_uniform( UInt32(maxAngle - minAngle + 1) ) )
        let randomAngleRadian = Double(randomAngle) * M_PI / 180.0
        pushBehavior.angle = CGFloat(randomAngleRadian)
        
        pushBehavior.action = { [weak pushBehavior] in
            if !pushBehavior!.active { self.removeChildBehavior(pushBehavior!) }
        }
        
        addChildBehavior(pushBehavior)
    }
}
    // MARK: - LINEAR VELOCITY

    private extension UIDynamicItemBehavior {
        func limitLinearVelocity(min: CGFloat, max: CGFloat, forItem item: UIDynamicItem) {
            assert(min < max, "min < max")
            let itemVelocity = linearVelocityForItem(item)
            if itemVelocity.magnitude < 0.0 { return }
            if itemVelocity.magnitude < min {
                (item as! BallView).backgroundColor = UIColor.whiteColor()
                
                _ = min/itemVelocity.magnitude * itemVelocity - itemVelocity
                //            addLinearVelocity(deltaVelocity, forItem: item)
            }
            if itemVelocity.magnitude > max  {
                //            println(itemVelocity.magnitude )
                (item as! BallView).backgroundColor = UIColor.redColor()
                let deltaVelocity = max/itemVelocity.magnitude * itemVelocity - itemVelocity
                addLinearVelocity(deltaVelocity, forItem: item)
            }
        }
    }

    private extension CGPoint {
        var angle: CGFloat {
            get { return CGFloat(atan2(self.x, self.y)) }
        }
        var magnitude: CGFloat {
            get { return CGFloat(sqrt(self.x*self.x + self.y*self.y)) }
        }
    }
    prefix func -(left: CGPoint) -> CGPoint {
        return CGPoint(x: -left.x, y: -left.y)
    }

    func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x-right.x, y: left.y-right.y)
    }

    func *(left: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: left*right.x, y: left*right.y)
    }
