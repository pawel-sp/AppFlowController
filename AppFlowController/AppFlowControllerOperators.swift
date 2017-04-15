//
//  AppFlowControllerOperators.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

public func ==(lhs:AppFlowControllerItem, rhs:AppFlowControllerItem) -> Bool {
    return lhs.isEqual(item: rhs)
}

infix operator =>:AdditionPrecedence
infix operator =>>:AdditionPrecedence

public func => (lhs:AppFlowControllerItem, rhs:AppFlowControllerTransition) -> (item:AppFlowControllerItem, transition:AppFlowControllerTransition) {
    return (lhs, rhs)
}

public func => (lhs:AppFlowControllerTransition, rhs:AppFlowControllerItem) -> AppFlowControllerItem {
    var rhs = rhs
    rhs.forwardTransition  = lhs
    rhs.backwardTransition = lhs
    return rhs
}

public func => (lhs:AppFlowControllerItem, rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    var rhs = rhs
    if rhs.forwardTransition == nil {
        rhs.forwardTransition = PushPopAppFlowControllerTransition.default
    }
    if rhs.backwardTransition == nil {
        rhs.backwardTransition = PushPopAppFlowControllerTransition.default
    }
    return [lhs, rhs]
}

public func => (lhs:(item:AppFlowControllerItem, transition:AppFlowControllerTransition), rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    var rhs = rhs
    rhs.backwardTransition = lhs.transition
    rhs.forwardTransition  = lhs.transition
    return [lhs.item, rhs]
}

public func => (lhs:[AppFlowControllerItem], rhs:AppFlowControllerTransition) -> (items:[AppFlowControllerItem], transition:AppFlowControllerTransition) {
    return (lhs, rhs)
}

public func => (lhs:[AppFlowControllerItem], rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    var rhs = rhs
    if rhs.forwardTransition == nil {
        rhs.forwardTransition = PushPopAppFlowControllerTransition.default
    }
    if rhs.backwardTransition == nil {
        rhs.backwardTransition = PushPopAppFlowControllerTransition.default
    }
    return lhs + [rhs]
}

public func => (lhs:AppFlowControllerItem, rhs:[AppFlowControllerItem]) -> [AppFlowControllerItem] {
    if var first = rhs.first {
        if first.forwardTransition == nil {
            first.forwardTransition = PushPopAppFlowControllerTransition.default
        }
        if first.backwardTransition == nil {
            first.backwardTransition = PushPopAppFlowControllerTransition.default
        }
    }
    return [lhs] + rhs
}

public func => (lhs:(items:[AppFlowControllerItem], transition:AppFlowControllerTransition), rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    var rhs = rhs
    rhs.backwardTransition = lhs.transition
    rhs.forwardTransition  = lhs.transition
    return lhs.items + [rhs]
}

public func =>> (lhs:AppFlowControllerItem, rhs:[Any]) -> [[AppFlowControllerItem]] {
    var result:[[AppFlowControllerItem]] = []
    for element in rhs {
        if let item = element as? AppFlowControllerItem {
            result.append(lhs => item)
        } else if let items = element as? [AppFlowControllerItem] {
            result.append(lhs => items)
        } else if let anyItems = element as? [Any] {
            for every in lhs =>> anyItems {
                result.append(every)
            }
        }
    }
    return result
}



