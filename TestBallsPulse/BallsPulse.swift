//
//  BallsPulse.swift
//  TestBallsPulse
//
//  Created by Luciano Almeida on 28/01/20.
//  Copyright © 2020 Luciano Almeida. All rights reserved.
//

import UIKit

class BallLayer: CALayer {
    
    static var animationIdentifier: String = "BallLayerAnimation"
    static var animationTypeIdentifier: String = "BallLayerAnimationType"
    
    enum AnimationType: String {
        case collapse
        case uncollapse
    }
    
    var isCollapsed: Bool = false
    var radius: CGFloat = 0.0
    var ballRadius: CGFloat = 10.0
    
    static func circleRect(ballRadius: CGFloat) -> CGRect {
        return CGRect(origin: .zero, size: CGSize(width: ballRadius * 2, height: ballRadius * 2))
    }
    
    static func collapsedRect(ballRadius: CGFloat, rate: CGFloat) -> CGRect {
        let rect = circleRect(ballRadius: ballRadius)
        guard (0.0...1.0)~=rate else { return rect }
        let collapsed = ballRadius * (1 - rate)
        let origin = CGPoint(x: collapsed, y: collapsed)
        let size = CGSize(width: rect.size.width - (collapsed * 2), height: rect.size.height - (collapsed * 2))
        return CGRect(origin: origin, size: size)
    }
}

class BallsPulseLoadingIndicator: UIView {
    
    private var containersBalls: [CALayer] = []
    
    private var layersBalls: [BallLayer] = []
    
    @IBInspectable
    var numberOfBalls: Int = 3
    
    @IBInspectable
    var ballsMinSpacing: CGFloat = 5.0
    
    @IBInspectable
    var collapseRate: CGFloat = 0.25
    
    @IBInspectable
    var ballsRadius: CGFloat = 5.0
    
    var animationTime: TimeInterval = 0.1
    
    var ballsColor: UIColor = UIColor.white {
        didSet {
            layersBalls.forEach({ $0.backgroundColor = ballsColor.cgColor })
        }
    }
    
    var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layoutLayers()
        adjustSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        layoutLayers()
        adjustSize()
    }
    
    private func calculatedViewSize() -> CGSize {
        let width = CGFloat(numberOfBalls) * (ballsMinSpacing + (ballsRadius * 2)) - ballsMinSpacing
        return CGSize(width: width, height: ballsRadius * 2)
    }
    
    private func layoutLayers() {
        for idx in 0..<numberOfBalls {
            let container = containersBalls[idx]
            let ball = layersBalls[idx]
            container.frame = positionForBallContainer(at: idx)
            ball.cornerRadius = ballsRadius
            ball.frame = BallLayer.circleRect(ballRadius: ballsRadius)
        }
    }
  
    private func adjustSize() {
        let size = calculatedViewSize()
        NSLayoutConstraint.activate([
          widthAnchor.constraint(equalToConstant: size.width),
          heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    private func positionForBallContainer(at idx: Int) -> CGRect {
        let xPos = CGFloat(idx) * (ballsMinSpacing + (ballsRadius * 2))
        return CGRect(origin: CGPoint(x: xPos, y: 0.0),
                      size: CGSize(width: ballsRadius * 2, height: ballsRadius * 2))
    }
    
    private func setup() {
        setupBalls()
    }
    
    private func setupBalls() {
        for _ in 0..<numberOfBalls {
            let container = CALayer()
            let ball = BallLayer()
            ball.backgroundColor = ballsColor.cgColor
            layersBalls.append(ball)
            containersBalls.append(container)
            container.addSublayer(ball)
            layer.addSublayer(container)
        }
    }
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        collapseBall(at: layersBalls.startIndex, rate: collapseRate)
    }
    
    func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        layersBalls.forEach({ $0.removeAllAnimations() })
        resetBallsSize()
    }
    
    func resetBallsSize() {
        for idx in 0..<numberOfBalls {
            let ball = layersBalls[idx]
            ball.frame = BallLayer.circleRect(ballRadius: ballsRadius)
            ball.cornerRadius = ballsRadius
        }
    }
    
    private func collapseBall(at idx: Int, rate: CGFloat) {
        let newFrame = BallLayer.collapsedRect(ballRadius: ballsRadius, rate: collapseRate)
        animateBall(at: idx, to: newFrame, animationType: .collapse)
    }
    
    private func uncolapseBall(at idx: Int) {
        let newFrame = BallLayer.circleRect(ballRadius: ballsRadius)
        animateBall(at: idx, to: newFrame, animationType: .uncollapse)
    }
    
    private func animateBall(at idx: Int, to frame: CGRect, animationType: BallLayer.AnimationType) {
        let ball = layersBalls[idx]
        let groupAnimation = animation(for: ball, frame: frame)
        groupAnimation.setValue(idx, forKey: BallLayer.animationIdentifier)
        groupAnimation.setValue(animationType, forKey: BallLayer.animationTypeIdentifier)
        ball.add(groupAnimation, forKey: nil)
        ball.frame.origin = frame.origin
        ball.frame.size = frame.size
        ball.cornerRadius = frame.size.width/2
        
    }
    
    fileprivate func animation(for layer: CALayer,
                               frame: CGRect) -> CAAnimationGroup {
        let animation = CABasicAnimation(keyPath: "frame.origin")
        animation.fromValue = NSValue(cgPoint: layer.frame.origin)
        animation.toValue = NSValue(cgPoint: frame.origin)
        animation.isRemovedOnCompletion = true
        
        let sizeAnimation = CABasicAnimation(keyPath: "frame.size")
        sizeAnimation.fromValue = NSValue(cgSize: layer.frame.size)
        sizeAnimation.toValue = NSValue(cgSize: frame.size)
        sizeAnimation.isRemovedOnCompletion = true
        
        let cornerAnimation = CABasicAnimation(keyPath: "cornerRadius")
        sizeAnimation.fromValue = layer.cornerRadius
        sizeAnimation.toValue = frame.size.width/2
        sizeAnimation.isRemovedOnCompletion = true
        
        let group = CAAnimationGroup()
        group.delegate = self
        group.duration = animationTime
        group.repeatCount = 1
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        group.animations = [sizeAnimation, animation, cornerAnimation]
        group.isRemovedOnCompletion = true
        return group
    }
    
    private func nextIdx(for idx: Int) -> Int {
        let nIdx = idx + 1
        guard layersBalls.startIndex..<layersBalls.endIndex~=nIdx else { return layersBalls.startIndex }
        return nIdx
    }
    
    deinit {
        layersBalls.forEach({ $0.removeAllAnimations() })
    }
}

extension BallsPulseLoadingIndicator: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && isAnimating {
            if let idx = anim.value(forKey: BallLayer.animationIdentifier) as? Int,
                let animationType = anim.value(forKey: BallLayer.animationTypeIdentifier) as? BallLayer.AnimationType {
                handleAnimationFinished(idx: idx, animationType: animationType)
            }
        } else {
            self.stopAnimating()
        }
    }
    
    private func handleAnimationFinished(idx: Int, animationType: BallLayer.AnimationType) {
        let current = layersBalls[idx]
        current.isCollapsed = animationType == .collapse
        startAnimateNext(for: idx)
    }
    
    private func startAnimateNext(for idx: Int) {
        let nextBallIdx = nextIdx(for: idx)
        let nextBall = layersBalls[nextBallIdx]
        if nextBall.isCollapsed {
            uncolapseBall(at: nextBallIdx)
        } else {
            collapseBall(at: nextBallIdx, rate: collapseRate)
        }
    }
}
