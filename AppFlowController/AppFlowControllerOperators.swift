//
//  AppFlowControllerOperators.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

func ==(lhs:AppFlowControllerItem, rhs:AppFlowControllerItem) -> Bool {
    return lhs.isEqual(item: rhs)
}

infix operator =>:AdditionPrecedence

func => (lhs:AppFlowControllerItem, rhs:AppFlowControllerTransition) -> (item:AppFlowControllerItem, transition:AppFlowControllerTransition) {
    return (lhs, rhs)
}

func => (lhs:(item:AppFlowControllerItem, transition:AppFlowControllerTransition), rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    var rhs = rhs
    rhs.backwardTransition = lhs.transition
    rhs.forwardTransition  = lhs.transition
    return [lhs.item, rhs]
}

func => (lhs:[AppFlowControllerItem], rhs:AppFlowControllerTransition) -> (items:[AppFlowControllerItem], transition:AppFlowControllerTransition) {
    return (lhs, rhs)
}

func => (lhs:(items:[AppFlowControllerItem], transition:AppFlowControllerTransition), rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    var rhs = rhs
    rhs.backwardTransition = lhs.transition
    rhs.forwardTransition  = lhs.transition
    return lhs.items + [rhs]
}




