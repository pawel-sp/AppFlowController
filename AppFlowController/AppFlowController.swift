//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright (c) 2017 Paweł Sporysz
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

import UIKit

open class AppFlowController {
    
    // MARK: - Properties
    
    public static let shared = AppFlowController()
    public var rootNavigationController:UINavigationController?
    
    private(set) var rootPathStep:PathStep?
    let tracker:Tracker
    
    // MARK: - Init
    
    init(trackerClass:Tracker.Type) {
        tracker = trackerClass.init()
    }
    
    public convenience init() {
        self.init(trackerClass: Tracker.self)
    }
    
    // MARK: - Setup
    
    public func prepare(for window:UIWindow, rootNavigationController:UINavigationController = UINavigationController()) {
        self.rootNavigationController = rootNavigationController
        window.rootViewController = rootNavigationController
    }
    
    public func register(path:AppFlowControllerPage) throws {
        try register(path:[path])
    }
    
    public func register(path:[AppFlowControllerPage]) throws {
        if let lastPath = path.last, !lastPath.supportVariants, rootPathStep?.search(page: lastPath) != nil {
            throw AppFlowControllerError.pathAlreadyRegistered(identifier: lastPath.identifier)
        }
        
        var previousStep:PathStep?
        
        for var element in path {
            if let found = rootPathStep?.search(page: element) {
                previousStep = found
                continue
            } else {
                if let previous = previousStep {
                    if element.supportVariants {
                        element.variantName = previous.current.identifier
                    }
                    if element.forwardTransition == nil || element.backwardTransition == nil {
                        throw AppFlowControllerError.missingPathStepTransition(identifier: element.identifier)
                    }
                    previousStep = previous.add(page: element)
                } else {
                    rootPathStep = PathStep(page: element)
                    previousStep = rootPathStep
                }
            }
        }
    }
    
    public func register(path:[[AppFlowControllerPage]]) throws {
        for subpath in path {
            try register(path: subpath)
        }
    }
    
    // MARK: - Navigation
    
    open func show(
        page:AppFlowControllerPage,
        variant:AppFlowControllerPage? = nil,
        parameters:[AppFlowControllerParameter]? = nil,
        animated:Bool = true,
        skipDismissTransitions:Bool = false,
        skipPages:[AppFlowControllerPage]? = nil
    ) throws {
        
        guard let rootNavigationController = rootNavigationController else {
            throw AppFlowControllerError.missingConfiguration
        }
        
        let foundStep        = try pathStep(from: page, variant: variant)
        let newPages         = rootPathStep?.allParentPages(from: foundStep) ?? []
        let currentStep      = visibleStep()
        let currentPages     = currentStep == nil ? [] : (rootPathStep?.allParentPages(from: currentStep!) ?? [])
        let keysToClearSkip  = newPages.filter({ !currentPages.contains($0) }).map({ $0.identifier })
        
        if let currentStep = currentStep {
            let distance                = PathStep.distanceBetween(step: currentStep, and: foundStep)
            let dismissCounter          = distance.up
            let _                       = distance.down
            let dismissRange:Range<Int> = dismissCounter == 0 ? 0..<0 : (currentPages.count - dismissCounter) ..< currentPages.count
            let displayRange:Range<Int> = 0 ..< newPages.count
            dismiss(pages: currentPages, fromIndexRange: dismissRange, animated: animated, skipTransition: skipDismissTransitions) {
                self.register(parameters:parameters, for: newPages, skippedPages: skipPages)
                self.tracker.disableSkip(for: keysToClearSkip)
                self.display(pages: newPages, fromIndexRange: displayRange, animated: animated, skipPages: skipPages, completionBlock: nil)
            }
        } else {
            rootNavigationController.viewControllers.removeAll()
            tracker.reset()
            register(parameters:parameters, for: newPages, skippedPages: skipPages)
            tracker.disableSkip(for: keysToClearSkip)
            display(pages: newPages, fromIndexRange: 0..<newPages.count, animated: animated, skipPages: skipPages, completionBlock: nil)
        }
    }
    
    public func goBack(animated:Bool = true) throws {
        
        guard let rootNavigationController = rootNavigationController else {
            throw AppFlowControllerError.missingConfiguration
        }
        
        if let visible = visibleStep() {
            
            var parent = visible.parent
            var viewController:UIViewController?
            let navigationController = rootNavigationController.visibleNavigationController
            
            while viewController == nil {
                if let identifier = parent?.current.identifier {
                    viewController = tracker.viewController(for: identifier)
                } else {
                    break
                }
                parent = parent?.parent
            }
            
            if let viewController = viewController {
                visible.current.backwardTransition?.backwardTransitionBlock(animated: animated){}(navigationController, viewController)
            }
        }
    }
    
    public func pop(to page:AppFlowControllerPage, animated:Bool = true) throws {
        
        guard let rootNavigationController = rootNavigationController else {
            throw AppFlowControllerError.missingConfiguration
        }
        
        guard let foundStep = rootPathStep?.search(page: page) else {
            throw AppFlowControllerError.unregisteredPathIdentifier(identifier: page.identifier)
        }
        
        guard let targetViewController = tracker.viewController(for: foundStep.current.identifier) else {
            throw AppFlowControllerError.popToSkippedPath(identifier: foundStep.current.identifier)
        }
        
        func pop(to viewController:UIViewController, animated:Bool) {
            if rootNavigationController == rootNavigationController.visibleNavigationController {
                rootNavigationController.popToViewController(viewController, animated: animated)
                return
            }
            if rootNavigationController.visibleNavigationController.viewControllers.contains(targetViewController) {
                rootNavigationController.visibleNavigationController.popToViewController(targetViewController, animated: animated)
            } else {
                rootNavigationController.visibleViewController?.dismiss(animated: animated) {
                    pop(to: viewController, animated: animated)
                }
            }
        }
        
        pop(to: targetViewController, animated: animated)
    }
    
    public func updateCurrentPage(with viewController:UIViewController, for name:String) throws {
        if let _ = rootPathStep?.search(identifier: name) {
            self.tracker.register(viewController: viewController, for: name)
        } else {
            throw AppFlowControllerError.unregisteredPathIdentifier(identifier: name)
        }
    }
    
    open func pathComponents(for page:AppFlowControllerPage, variant:AppFlowControllerPage? = nil) throws -> String {
        let foundStep   = try pathStep(from: page, variant: variant)
        let pages       = rootPathStep?.allParentPages(from: foundStep) ?? []
        let pageStrings = pages.map({ $0.identifier })
        return pageStrings.joined(separator: "/")
    }
    
    open func currentPathComponents() -> String? {
        if let visibleStep = visibleStep() {
            let items       = rootPathStep?.allParentPages(from: visibleStep) ?? []
            let itemStrings = items.map({ $0.identifier })
            return itemStrings.joined(separator: "/")
        } else {
            return nil
        }
    }
    
    open func currentPage() -> AppFlowControllerPage? {
        return visibleStep()?.current
    }
    
    open func currentPageParameter() -> String? {
        if let currentPageID = currentPage()?.identifier {
            return tracker.parameter(for: currentPageID)
        } else {
            return nil
        }
    }
    
    open func parameter(for page:AppFlowControllerPage, variant:AppFlowControllerPage? = nil) throws -> String? {
        let step = try pathStep(from: page, variant: variant)
        return tracker.parameter(for: step.current.identifier)
    }
    
    open func reset(completionBlock:(()->())? = nil) {
        rootNavigationController?.dismissAllPresentedViewControllers() {
            self.rootNavigationController?.viewControllers.removeAll()
            self.tracker.reset()
            completionBlock?()
        }
    }
    
    // MARK: - Helpers
    
    private func visibleStep() -> PathStep? {
        let navigationController  = rootNavigationController?.visibleNavigationController
        if let visibleViewController = navigationController?.visibleViewController, let key = tracker.key(for: visibleViewController) {
            return rootPathStep?.search(identifier: key)
        } else {
            return nil
        }
    }
    
    private func viewController(fromItem item:AppFlowControllerPage) -> UIViewController {
        let viewController = item.viewControllerBlock()
        if (viewController.isKind(of: UITabBarController.self)) {
            if let step = rootPathStep?.search(page: item) {
                let children            = step.children
                let tabBarController    = viewController as! UITabBarController
                let tabsViewControllers = children.map({ $0.current.viewControllerBlock() })
                tabBarController.viewControllers = tabsViewControllers
                return tabBarController
            } else {
                return viewController
            }
        } else {
            return viewController
        }
    }
    
    private func register(parameters:[AppFlowControllerParameter]?, for pages:[AppFlowControllerPage], skippedPages:[AppFlowControllerPage]?) {
        if let parameters = parameters {
            for parameter in parameters {
                if pages.filter({ $0.identifier == parameter.identifier }).count == 0 {
                    continue
                }
                if (skippedPages?.filter({ $0.identifier == parameter.identifier }).count ?? 0) > 0 {
                    continue
                }
                self.tracker.register(parameter: parameter.value, for: parameter.identifier)
            }
        }
    }
    
    private func display(pages:[AppFlowControllerPage], fromIndexRange indexRange:Range<Int>, animated:Bool, skipPages:[AppFlowControllerPage]? = nil, completionBlock:(() -> ())?) {
        
        let index      = indexRange.lowerBound
        let item       = pages[index]
        let identifier = item.identifier
        
        guard let navigationController = rootNavigationController?.visibleNavigationController else {
            completionBlock?()
            return
        }
        
        func displayNextItem(range:Range<Int>, animated:Bool, offset:Int = 0) {
            let newRange:Range<Int> = (range.lowerBound + 1 + offset) ..< range.upperBound
            if newRange.count == 0 {
                completionBlock?()
            } else {
                self.display(
                    pages: pages,
                    fromIndexRange: newRange,
                    animated: animated,
                    skipPages: skipPages,
                    completionBlock: completionBlock
                )
            }
        }
        
        if navigationController.viewControllers.count == 0 {
            var viewControllersToPush = [item]
            var skippedPages:Int = 0
            for item in pages[1..<pages.count] {
                if skipPages?.contains(where: { $0.identifier == item.identifier }) == true {
                    skippedPages += 1
                    continue
                }
                if item.forwardTransition is PushPopAppFlowControllerTransition {
                    viewControllersToPush += [item]
                } else {
                    break
                }
            }
            let viewControllers = viewControllersToPush.map({ self.viewController(fromItem: $0) })
            for (index, viewController) in viewControllers.enumerated() {
                let identifier = viewControllersToPush[index].identifier
                tracker.register(viewController: viewController, for: identifier)
            }
            navigationController.setViewControllers(viewControllers, animated: false) {
                displayNextItem(range: indexRange, animated: false, offset:max(0, viewControllersToPush.count - 1 + skippedPages))
            }
        } else if tracker.viewController(for: item.identifier) == nil && !tracker.isItemSkipped(at: item.identifier) {
            
            let shouldSkipViewController = skipPages?.contains(where: { $0.identifier == item.identifier }) == true
            
            if shouldSkipViewController {
                
                tracker.register(viewController: nil, for: item.identifier, skipped:shouldSkipViewController)
                displayNextItem(range: indexRange, animated: animated)
                
            } else {
                
                let viewController = self.viewController(fromItem:item)
                tracker.register(viewController: viewController, for: item.identifier, skipped:shouldSkipViewController)
                item.forwardTransition?.forwardTransitionBlock(animated: animated){
                    displayNextItem(range: indexRange, animated: animated)
                }(navigationController, viewController)
            }
    
        } else {
            
            displayNextItem(range: indexRange, animated: animated)
            
        }
    }
    
    private func dismiss(pages:[AppFlowControllerPage], fromIndexRange indexRange:Range<Int>, animated:Bool, skipTransition:Bool = false, completionBlock:(() -> ())?) {
        if indexRange.count == 0 {
            
            completionBlock?()
            
        } else {
            
            let index = indexRange.upperBound - 1
            let item  = pages[index]
            
            guard let viewController = tracker.viewController(for: item.identifier) else {
                completionBlock?()
                return
            }
            guard let navigationController = rootNavigationController?.visibleNavigationController else {
                completionBlock?()
                return
            }
            
            if !skipTransition {
                item.backwardTransition?.backwardTransitionBlock(animated: animated){
                    self.dismiss(
                        pages: pages,
                        fromIndexRange: indexRange.lowerBound..<indexRange.upperBound - 1,
                        animated: animated,
                        skipTransition: skipTransition,
                        completionBlock: completionBlock
                    )
                    }(navigationController, viewController)
            } else {
                self.dismiss(
                    pages: pages,
                    fromIndexRange: indexRange.lowerBound..<indexRange.upperBound - 1,
                    animated: animated,
                    skipTransition: skipTransition,
                    completionBlock: completionBlock
                )
            }
            
        }
    }
    
    private func pathStep(from page:AppFlowControllerPage, variant:AppFlowControllerPage? = nil) throws -> PathStep {
        
        var page = page
        
        if page.supportVariants && variant == nil {
            throw AppFlowControllerError.missingVariant(identifier: page.identifier)
        }
        
        if !page.supportVariants && variant != nil {
            throw AppFlowControllerError.variantNotSupported(identifier: page.identifier)
        }
        
        if page.supportVariants && variant != nil {
            page.variantName = variant?.identifier
        }
        
        guard let foundStep = rootPathStep?.search(page: page) else {
            throw AppFlowControllerError.unregisteredPathIdentifier(identifier: page.identifier)
        }
        
        return foundStep
    }
    
}
