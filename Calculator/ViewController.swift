//
//  ViewController.swift
//  Calculator
//
//  Created by Moaz Ahmed on 10/20/15.
//  Copyright © 2015 Moaz Ahmed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    let brain = CalculatorBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.rangeOfString(".") != nil && digit=="." {
                return
            }
            display.text = display.text! + digit
        }else{
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTypingANumber {
            let digitToRemove  = displayValue! % 10
            displayValue = (displayValue! - digitToRemove) / 10
        }else {
            brain.undoLastOp()
            history.text = historyValue
            
        }
    }
    @IBAction func setM() {
        
        brain.variableValues["M"] = displayValue
        brain.pushOperand("M")
    }
    @IBAction func getM() {
        displayValue = brain.variableValues["M"]
        brain.pushOperand("M")
        enter()
    }
    @IBAction func clear() {
        brain.clear()
        history.text = historyValue
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            }else{
                displayValue = 0
            }
            history.text = historyValue
        }
    }

    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let displayText = displayValue {
            if let result = brain.pushOperand(displayText) {
                displayValue = result
            }else{
                displayValue = 0
            }
        }
    }
    
    var displayValue : Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            //userIsInTheMiddleOfTypingANumber = false
            if let value = newValue {
                print("\(Int(value))")
                display.text = removeDecimalIfNotUsed(value)
                
            }else {
                display.text = "0"
            }
            
        }
    }
    
    var historyValue: String {
        get {
            return brain.description
        }
    }
    
    func removeDecimalIfNotUsed(number: Double) -> String {
        
        return number == floor(number) ? "\(Int(number))" : "\(number)"
    }

}

