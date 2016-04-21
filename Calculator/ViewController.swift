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
        
        history.text = history.text! + digit
        print("\(digit)")
    }
    
    @IBAction func clear() {
        operandStack.removeAll()
        displayValue = 0
        enter()
    }
    
    var operandStack = Array<Double>()

    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            history.text = history.text! + operation
            enter()
        }
        
        switch operation {
        case"×": performOperation {$0 * $1}
        case"÷": performOperation {$1 / $0}
        case"+": performOperation {$0 + $1}
        case"−": performOperation {$1 - $0}
        case"√": performOperation { sqrt($0)}
        case"sin": performOperation {sin($0)}
        case"cos": performOperation {cos($0)}
        case"π": performOperation { M_PI}
        default: break
        }
    }
    
    func computeConstants() -> Double {
        return M_PI
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast() , operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: () -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation()
            enter()
        }
    }

    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        history.text = history.text! + " "
        print("Operand stack = \(operandStack)")
    }
    
    var displayValue : Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }


}

