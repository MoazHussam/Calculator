//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Moaz Ahmed on 4/21/16.
//  Copyright © 2016 Moaz Ahmed. All rights reserved.
//

import Foundation

class CalculatorBrain : CustomStringConvertible
{
    enum Op : CustomStringConvertible {
        
        case operand(Double)
        case operandVariable(String)
        case unaryOperation (String, Double -> Double)
        case binaryOperation (String, (Double,Double) -> Double)
        case constantOperation(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .operand(let operand):
                    return "\(operand)"
                case .unaryOperation(let symbol, _):
                    return symbol
                case .binaryOperation(let symbol, _):
                    return symbol
                case .constantOperation(let symbol, _):
                    return symbol
                case .operandVariable(let variable):
                    return variable
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOperations = [String:Op]()
    var variableValues = [String:Double]()
    
    init() {
        
        func learnOp(op:Op) {
            knownOperations[op.description] = op
        }
        
        learnOp(Op.binaryOperation("+", +))
        learnOp(Op.binaryOperation("×", *))
        learnOp(Op.binaryOperation("−") {$1 - $0})
        learnOp(Op.binaryOperation("÷") {$1 / $0})
        learnOp(Op.unaryOperation("√", sqrt))
        learnOp(Op.unaryOperation("sin", sin))
        learnOp(Op.unaryOperation("cos", cos))
        learnOp(Op.constantOperation("π") {M_PI})
        learnOp(Op.unaryOperation("-\\+") {-$0})
    }
    
    func undoLastOp() {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return opStack.map() {$0.description}
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                let numberFormatter = NSNumberFormatter()
                for op in opSymbols {
                    if let opSymbol = knownOperations[op] {
                        newOpStack.append(opSymbol)
                    }else {
                        if let number = numberFormatter.numberFromString(op)?.doubleValue {
                            newOpStack.append(.operand(number))
                        }
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        print(description)
        return result
    }
    
    func evaluate (ops: [Op] ) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .operand(let operand):
                return (operand , remainingOps)
            case .operandVariable(let variable):
                if let variableValue = variableValues[variable] {
                    return(variableValue, ops)
                }
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .binaryOperation(_, let operation):
                let op1Evalaution = evaluate(remainingOps)
                if let op1 = op1Evalaution.result {
                    let op2Evaluation = evaluate(op1Evalaution.remainingOps)
                    if let op2 = op2Evaluation.result {
                        return (operation(op1, op2), op2Evaluation.remainingOps)
                    }
                }
            case .constantOperation(_, let operation):
                return (operation(), remainingOps)
            }
        }
        
        
        return (nil , ops)
    }
    
    func pushOperand(operand:Double) -> Double? {
        opStack.append(.operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol:String) -> Double? {
        
        opStack.append(.operandVariable(symbol))
        return evaluate()
    }
    
    func performOperation (symbol: String) -> Double? {
        if let operation = knownOperations[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll()
        variableValues.removeAll()
    }
    
    private func convertToInfix(ops : [Op]) -> (expression: String? , remainingOps: [Op]) {
        
        if !ops.isEmpty {
            
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
                
            case .operand(let operand):
                return (String(format: "%g", operand) , remainingOps)
            case .operandVariable(let variable):
                if let _ = variableValues[variable] {
                    return (variable, remainingOps)
                }
            case .constantOperation(let op, _):
                return ("\(op)", remainingOps)
            case .unaryOperation(let unaryOperator, _):
                let operand = convertToInfix(remainingOps)
                if let unaryOperand = operand.expression {
                    return (unaryOperator + "(\(unaryOperand))", operand.remainingOps)
                }else {
                    return ("\(unaryOperator)(?)", remainingOps)
                }
            case .binaryOperation(let binaryOperand, _):
                let operand2 = convertToInfix(remainingOps)
                if let op2 = operand2.expression {
                    let operand1 = convertToInfix(operand2.remainingOps)
                    if let op1 = operand1.expression {
                        return("\(op1)\(binaryOperand)\(op2)", operand1.remainingOps)
                    }else {
                        return("?\(binaryOperand)\(op2)", operand2.remainingOps)
                    }
                }else {
                    return("?\(binaryOperand)?", remainingOps)
                }
            }
        }
        
        return (nil, ops)
    }
    
    private func convertToInfix() -> String? {
        
        var description = [String]()
        var infixExpression: (expression: String? , remainingOps: [Op]) = (nil , opStack)
        repeat {
            infixExpression = convertToInfix(infixExpression.remainingOps)
            if infixExpression.expression != nil { description.append(infixExpression.expression!) }
        } while !infixExpression.remainingOps.isEmpty
        
        return description.reverse().joinWithSeparator(", ")
    }
    
    var description: String {
        get {
            if let content = convertToInfix() {
                return content
            }else {
                return "0"
            }
        }
    }
    
}