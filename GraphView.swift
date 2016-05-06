//
//  GraphView.swift
//  Calculator
//
//  Created by Moaz Ahmed on 5/3/16.
//  Copyright © 2016 Moaz Ahmed. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yForX(sender: GraphView, x: Double) -> Double?
    //var functionName: String? { set get }
}

@IBDesignable
class GraphView: UIView {

    
    // MARK: Properties
    weak var dataSource: GraphViewDataSource?
    private var axes = AxesDrawer()

    private var origin: CGPoint?
    @IBInspectable
    var axesOrigin: CGPoint {
        get {
        
            return origin ?? self.center
        }
        set {
            origin = newValue
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var graphColor: UIColor = UIColor.redColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var axesColor: UIColor {
        get {
            return axes.color
        }
        set {
            axes.color = newValue
        }
    }
    
    @IBInspectable
    var scale: CGFloat = CGFloat(50) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    //MARK: UI Drawing
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        drawAxes()
        drawCurve()
    }
    
    private func drawAxes() {
        axes.drawAxesInRect(self.bounds, origin: axesOrigin, pointsPerUnit: scale)
    }
    
    private func drawCurve() {
        
        var cgX = CGFloat(0)
        var points = [CGPoint]()
        
        while cgX <= self.frame.maxX {
            let graphX = convertGraphicsPointToGraphPoint(cgX, center: axesOrigin.x)
            let graphY = dataSource?.yForX(self, x: graphX)
            if graphY != nil {
                let graphCoordinates = (x: graphX, y: graphY!)
                let cgPoint = convertGraphCoordinatesToGraphicsCoordinates(graphCoordinates)
                points.append(cgPoint)
            }
            cgX += 1
        }
        
        if !points.isEmpty {
            
            let line = UIBezierPath()
            line.moveToPoint(points.removeFirst())
            
            for point in points {
                line.addLineToPoint(point)
            }
            graphColor.setStroke()
            line.stroke()
        }
    }
    
    //MARK: Utilities
    private func convertGraphicsCoordinatesToGraphCoordinates(point: CGPoint) -> (x: Double, y:Double) {
        let x = (point.x - axesOrigin.x) / scale
        let y = (point.y - axesOrigin.y) / scale * -1;
        
        return (x.doubleValue, y.doubleValue)
    }
    
    private func convertGraphCoordinatesToGraphicsCoordinates(point: (x: Double, y: Double)) -> CGPoint {
        let x = (point.x.cgFloat * scale) + axesOrigin.x
        let y = (point.y.cgFloat * -scale) + axesOrigin.y
        
        return CGPoint(x: x, y: y)
    }
    
    private func convertGraphicsPointToGraphPoint(point: CGFloat, center: CGFloat) -> Double {
        
        let graphPoint = (point - center) / scale
        return graphPoint.doubleValue
    }
    
    //MARK: Gestures handlers
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended, .Changed:
            let translation = gesture.translationInView(self)
            axesOrigin.x += translation.x
            axesOrigin.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func doubleTab(gesture: UITapGestureRecognizer) {
        axesOrigin = gesture.locationInView(self)
    }
    
    func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Ended , .Changed , .Began:
            scale *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    
}

//MARK: Extensions
extension CGFloat {
    var doubleValue: Double { return Double(self) }
}
extension Double {
    var cgFloat: CGFloat { return CGFloat(self) }
}