//
//  GraphViewController.swift
//  Calculator
//
//  Created by Moaz Ahmed on 5/3/16.
//  Copyright © 2016 Moaz Ahmed. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var functionLabel: UILabel!
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: "pan:")
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: "pinch:")
            let doubleTabRecognizer = UITapGestureRecognizer(target: graphView, action: "doubleTab:")
            doubleTabRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(panRecognizer)
            graphView.addGestureRecognizer(pinchRecognizer)
            graphView.addGestureRecognizer(doubleTabRecognizer)
        }
    }
    
    var calculatorBrain: CalculatorBrain? = nil
    
    
    typealias PropertyList = AnyObject
    func yForX(sender: GraphView, x: Double) -> Double? {
        
        if let brain = calculatorBrain {
            brain.variableValues["M"] = x
            let y = brain.evaluate()
            print("Calculator Brain Program = \(brain.program)")
            return y
        }
        
        return nil
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed, .Ended:
            let translation = gesture.translationInView(graphView)
            graphView.axesOrigin = translation
            //gesture.setTranslation(CGPointZero, inView: graphView)
        default: break
        }
    }
    
    override func viewDidLoad() {
        functionLabel.text = "y=x"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
