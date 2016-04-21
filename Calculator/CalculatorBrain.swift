//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Moaz Ahmed on 4/21/16.
//  Copyright © 2016 Moaz Ahmed. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    enum Op : CustomStringConvertible {
        
        case Operand(Double)
        case unaryOperation (String, Double -> Double)
        case binaryOperation (String, (Double,Double) -> Double)
        case constantOperation(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .unaryOperation(let symbol, _):
                    return symbol
                case .binaryOperation(let symbol, _):
                    return symbol
                case .constantOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    var opStack = [Op]()
    var knownOperations = [String:Op]()
    
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
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) lett over")
        return result
    }
    
    func evaluate (ops: [Op] ) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand , remainingOps)
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
        opStack.append(.Operand(operand))
        return evaluate()
    }
    
    func performOperation (symbol: String) -> Double? {
        if let operation = knownOperations[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
}