//
//  AppFlowControllerOperators.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright (c) 2017 Paweł Sporysz
//  https://github.com/pawel-sp/AppFlowController
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

infix operator =>:AdditionPrecedence
infix operator =>>:AdditionPrecedence

// MARK: - =>

public func => (lhs:AppFlowControllerPage, rhs:AppFlowControllerTransition) -> (page:AppFlowControllerPage, transition:AppFlowControllerTransition) {
    return (lhs, rhs)
}

public func => (lhs:AppFlowControllerTransition, rhs:AppFlowControllerPage) -> AppFlowControllerPage {
    var rhs = rhs
    rhs.forwardTransition  = lhs
    rhs.backwardTransition = lhs
    return rhs
}

public func => (lhs:AppFlowControllerPage, rhs:AppFlowControllerPage) -> [AppFlowControllerPage] {
    return [lhs] => rhs
}

public func => (lhs:[AppFlowControllerPage], rhs:AppFlowControllerPage) -> [AppFlowControllerPage] {
    return lhs => [rhs]
}

public func => (lhs:AppFlowControllerPage, rhs:[AppFlowControllerPage]) -> [AppFlowControllerPage] {
    return [lhs] => rhs
}

public func => (lhs:[AppFlowControllerPage], rhs:[AppFlowControllerPage]) -> [AppFlowControllerPage] {
    if var first = rhs.first {
        if first.forwardTransition == nil {
            first.forwardTransition = PushPopAppFlowControllerTransition.default
        }
        if first.backwardTransition == nil {
            first.backwardTransition = PushPopAppFlowControllerTransition.default
        }
        return lhs + ([first] + rhs.dropFirst())
    } else {
        return lhs + rhs
    }
}

public func => (lhs:(page:AppFlowControllerPage, transition:AppFlowControllerTransition), rhs:AppFlowControllerPage) -> [AppFlowControllerPage] {
    return ([lhs.page], lhs.transition) => rhs
}

public func => (lhs:[AppFlowControllerPage], rhs:AppFlowControllerTransition) -> (pages:[AppFlowControllerPage], transition:AppFlowControllerTransition) {
    return (lhs, rhs)
}

public func => (lhs:AppFlowControllerTransition, rhs:[AppFlowControllerPage]) -> [AppFlowControllerPage] {
    if var first = rhs.first {
        first.forwardTransition = lhs
        first.backwardTransition = lhs
        return [first] + rhs.dropFirst()
    } else {
        return rhs
    }
}

public func => (lhs:(pages:[AppFlowControllerPage], transition:AppFlowControllerTransition), rhs:AppFlowControllerPage) -> [AppFlowControllerPage] {
    var rhs = rhs
    rhs.backwardTransition = lhs.transition
    rhs.forwardTransition  = lhs.transition
    return lhs.pages + [rhs]
}

// MARK: - =>>

public func =>> (lhs:AppFlowControllerPage, rhs:[Any]) -> [[AppFlowControllerPage]] {
    return [lhs] =>> rhs
}

public func =>> (lhs:[AppFlowControllerPage], rhs:[Any]) -> [[AppFlowControllerPage]] {
    var result:[[AppFlowControllerPage]] = []
    for element in rhs {
        if let item = element as? AppFlowControllerPage {
            result.append(lhs => item)
        } else if let items = element as? [AppFlowControllerPage] {
            result.append(lhs => items)
        } else if let anyItems = element as? [Any] {
            for every in lhs =>> anyItems {
                result.append(every)
            }
        }
    }
    return result
}
