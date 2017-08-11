//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
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
    
    /**
        You need to use that method before you gonna start use AppFlowController to present pages. 
     
        - Parameter window:                     Current app's window.
        - Parameter rootNavigationController:   AppFlowController requires that root navigation controller is kind of UINavigationController.
    */
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
    
    /**
        Before presenting any page you need to register it using whole path.
     
        - Parameter path:   Sequences of pages which represent all possible paths inside the app. The best way to register pages is to use => and =>> operators which assign transitions directly to pages.
        - Throws:           
            AppFlowControllerError.missingPathStepTransition if forward or backward transition of any page is nil
            AppFlowControllerError.pathAlreadyRegistered     if that page was registered before (all pages need to have unique name). If you want to use the same page few times in different places it's necessary to set supportVariants property to true. 
     */
    public func register(path:[[AppFlowControllerPage]]) throws {
        for subpath in path {
            try register(path: subpath)
        }
    }
    
    // MARK: - Navigation

    /**
        Display view controller configured inside the page.
     
        - Parameter page:                   Page to present.
        - Parameter variant:                If page supports variants you need to pass the correct variant (previous page). Default = nil.
        - Parameter parameters:             For every page you can set single string value as it's parameter. It works also for pages with variants. Default = nil.
        - Parameter animated:               Determines if presenting page should be animated or not. Default = true.
        - Parameter skipDismissTransitions: Use that property to skip all dismiss transitions. Use that with conscience since it can break whole view's stack (it's helpfull for example when app has side menu).
        - Parameter skipPages:              Pages to skip.
     
        - Throws:
            AppFlowControllerError.missingConfiguration       if prepare(UIWindow, UINavigationController) wasn't invoked before.
            AppFlowControllerError.showingSkippedPage         if page was previously skipped (for example when you're trying go back to page which before was skipped and it's not present inside the navigation controller).
            AppFlowControllerError.missingVariant             if page's property supportVariants == true you need to pass variant property, otherwise it's not possible to set which page should be presenter.
            AppFlowControllerError.variantNotSupported        if page's property supportVariants == false you cannot pass variant property, because there is only one variant of that page.
            AppFlowControllerError.unregisteredPathIdentifier page need to be registered before showing it.
    */
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
         
            try verify(pages: currentPages, distance: distance)
            
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
    
    /**
        Displays previous page.
     
        - Parameter animated: Determines if presenting page should be animated or not. Default = true.
    */
    public func goBack(animated:Bool = true) {
        guard let visible        = visibleStep() else { return }
        guard let page           = visible.firstParentPage(where: { tracker.viewController(for: $0.identifier) != nil }) else { return }
        guard let viewController = tracker.viewController(for: page.identifier) else { return }
        
        visible.current.backwardTransition?.backwardTransitionBlock(animated: animated){}(viewController)
    }
    
    /**
        Pops navigation controller to specified page. It always current view controller's navigation controller. If page isn't not present in current navigation controller nothing would happen.
     
        - Parameter page:       Page to pop.
        - Parameter animated:   Determines if transition should be animated or not.
    */
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
        
        rootNavigationController.visible.navigationController?.popToViewController(targetViewController, animated: animated)
    }
    
    /**
        If you presented view controller without AppFlowController you need to update current page. Use that method inside the viewDidLoad method of presented view controller to make sure that whole step tree still works.
     
        - Parameter viewController: Presented view controller.
        - Parameter name:           Name of page associated with that view controller. That page need to be registered.
     
        - Throws:
            AppFlowControllerError.unregisteredPathIdentifier if page wasn't registered before.
    */
    public func updateCurrentPage(with viewController:UIViewController, for name:String) throws {
        if let _ = rootPathStep?.search(identifier: name) {
            self.tracker.register(viewController: viewController, for: name)
        } else {
            throw AppFlowControllerError.unregisteredPathIdentifier(identifier: name)
        }
    }
    
    /**
        Returns string representation of whole path to specified page, for example home/start/login.
     
        - Parameter page:       Page to receive all path steps.
        - Parameter variant:    Variant of that page (previous page). Use it only if page supports variants.
     
        - Throws:
             AppFlowControllerError.missingVariant             if page's property supportVariants == true you need to pass variant property, otherwise it's not possible to set which page should be presenter.
             AppFlowControllerError.variantNotSupported        if page's property supportVariants == false you cannot pass variant property, because there is only one variant of that page.
             AppFlowControllerError.unregisteredPathIdentifier page need to be registered before showing it.
    */
    open func pathComponents(for page:AppFlowControllerPage, variant:AppFlowControllerPage? = nil) throws -> String {
        let foundStep   = try pathStep(from: page, variant: variant)
        let pages       = rootPathStep?.allParentPages(from: foundStep) ?? []
        let pageStrings = pages.map({ $0.identifier })
        return pageStrings.joined(separator: "/")
    }
    
    /**
        Returns string representation of whole path to current page, for example home/start/login.
    */
    open func currentPathComponents() -> String? {
        if let visibleStep = visibleStep() {
            let items       = rootPathStep?.allParentPages(from: visibleStep) ?? []
            let itemStrings = items.map({ $0.identifier })
            return itemStrings.joined(separator: "/")
        } else {
            return nil
        }
    }
    
    /**
        Returns currenlty visible page.
    */
    open func currentPage() -> AppFlowControllerPage? {
        return visibleStep()?.current
    }
    
    /**
        Returns parameter for currently visible page. It's nil if page was presented without any parametes.
    */
    open func currentPageParameter() -> String? {
        if let currentPageID = currentPage()?.identifier {
            return tracker.parameter(for: currentPageID)
        } else {
            return nil
        }
    }
    
    /**
        Returns parameter for specified page. It's nil if page was presented without any parametes.
     
        - Parameter page:     Page to retrieve parameter.
        - Parameter variant:  Variant of that page (previous page). Use it only if page supports variants.
     
        - Throws:
             AppFlowControllerError.missingVariant             if page's property supportVariants == true you need to pass variant property, otherwise it's not possible to set which page should be presenter.
             AppFlowControllerError.variantNotSupported        if page's property supportVariants == false you cannot pass variant property, because there is only one variant of that page.
             AppFlowControllerError.unregisteredPathIdentifier page need to be registered before showing it.
    */
    open func parameter(for page:AppFlowControllerPage, variant:AppFlowControllerPage? = nil) throws -> String? {
        let step = try pathStep(from: page, variant: variant)
        return tracker.parameter(for: step.current.identifier)
    }
    
    /**
        Reset root navigation controller and view's tracker. It removes all view controllers including those presented modally.
    */
    open func reset(completionBlock:(()->())? = nil) {
        rootNavigationController?.dismissAllPresentedViewControllers() {
            self.rootNavigationController?.viewControllers.removeAll()
            self.tracker.reset()
            completionBlock?()
        }
    }
    
    // MARK: - Helpers
    
    private func visibleStep() -> PathStep? {
        guard let currentViewController = rootNavigationController?.visibleNavigationController.visible else { return nil }
        guard let key = tracker.key(for: currentViewController) else { return nil }
        
        return rootPathStep?.search(identifier: key)
    }
    
    private func viewControllers(from pages:[AppFlowControllerPage], skipPages:[AppFlowControllerPage]? = nil) -> [UIViewController] {
        var viewControllers:[UIViewController] = []
        
        for page in pages {
            
            if page.forwardTransition?.shouldPreloadViewController() == true, let viewController = tracker.viewController(for: page.identifier) {
                viewControllers.append(viewController)
                continue
            }
            
            if skipPages?.contains(where: { $0.identifier == page.identifier }) == true {
                tracker.register(viewController: nil, for: page.identifier, skipped: true)
                continue
            }

            let viewController = page.viewControllerBlock()
            tracker.register(viewController: viewController, for: page.identifier)
            
            
            if let step = rootPathStep?.search(page: page) {
                let preload = step.children.filter({ $0.current.forwardTransition?.shouldPreloadViewController() == true })
                for item in preload {
                    if let childViewController = self.viewControllers(from: [item.current], skipPages: skipPages).first {
                        item.current.forwardTransition?.preloadViewController(childViewController, from: viewController)
                    }
                }
            }
            
            viewControllers.append(page.forwardTransition?.configureViewController(from: viewController) ?? viewController)
        }
        
        return viewControllers
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
        
        guard let navigationController = rootNavigationController?.visible.navigationController ?? rootNavigationController else {
            completionBlock?()
            return
        }
        
        func displayNextItem(range:Range<Int>,  animated:Bool, offset:Int = 0) {
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
        
        let viewControllerExists = tracker.viewController(for: item.identifier) != nil
        let pageSkipped          = tracker.isItemSkipped(at: item.identifier)
        let itemIsPreloaded      = item.forwardTransition?.shouldPreloadViewController() == true
        
        if navigationController.viewControllers.count == 0 {
            
            let pagesToPush           = [item] + pages[1..<pages.count].prefix(while: { $0.forwardTransition is PushPopAppFlowControllerTransition })
            let viewControllersToPush = self.viewControllers(from: pagesToPush, skipPages: skipPages)
            let skippedPages          = pagesToPush.count - viewControllersToPush.count
            
            navigationController.setViewControllers(viewControllersToPush, animated: false) {
                displayNextItem(range: indexRange, animated: false, offset:max(0, viewControllersToPush.count - 1 + skippedPages))
            }
            
        } else if (!viewControllerExists || itemIsPreloaded) && !pageSkipped {
            
            let viewControllers = self.viewControllers(from: [item], skipPages: skipPages)
            
            if let viewController = viewControllers.first {
                item.forwardTransition?.forwardTransitionBlock(animated: animated){
                    displayNextItem(range: indexRange, animated: animated)
                }(navigationController, viewController)
            } else {
                displayNextItem(range: indexRange, animated: animated)
            }
    
        } else {
            
            displayNextItem(range: indexRange, animated: animated)
            
        }
    }
    
    private func dismiss(pages:[AppFlowControllerPage], fromIndexRange indexRange:Range<Int>, animated:Bool, skipTransition:Bool = false, viewControllerForSkippedPage:UIViewController? = nil, completionBlock:(() -> ())?) {
        if indexRange.count == 0 {
            
            completionBlock?()
            
        } else {
            
            let index          = indexRange.upperBound - 1
            let item           = pages[index]
            let parentPage     = rootPathStep?.search(page: item)?.parent?.current
            let skipParentPage = parentPage == nil ? false : tracker.isItemSkipped(at: parentPage!.identifier)
            let skippedPage    = tracker.isItemSkipped(at: item.identifier)
            let viewController = tracker.viewController(for: item.identifier)
            
            func dismissNext(viewControllerForSkippedPage:UIViewController? = nil) {
                self.dismiss(
                    pages: pages,
                    fromIndexRange: indexRange.lowerBound..<indexRange.upperBound - 1,
                    animated: animated,
                    skipTransition: skipTransition,
                    viewControllerForSkippedPage: viewControllerForSkippedPage,
                    completionBlock: completionBlock
                )
            }
            
            func dismiss(useTransition:Bool, viewController:UIViewController) {
                if useTransition {
                    item.backwardTransition?.backwardTransitionBlock(animated: animated){ dismissNext() }(viewController)
                } else {
                    dismissNext()
                }
            }
            
            if skipParentPage {
                dismissNext(viewControllerForSkippedPage: viewController ?? viewControllerForSkippedPage)
            } else if let viewController = viewControllerForSkippedPage, skippedPage {
                dismiss(useTransition: !skipTransition, viewController: viewController)
            } else if let viewController = viewController, !skippedPage {
                dismiss(useTransition: !skipTransition, viewController: viewController)
            } else {
                completionBlock?()
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
    
    private func verify(pages:[AppFlowControllerPage], distance:(up:Int, down:Int)) throws {
        
        if distance.up > 0 {
            let lastIndexToDismiss = pages.count - 1 - distance.up
            if lastIndexToDismiss >= 0 && lastIndexToDismiss < pages.count - 1 {
                let item = pages[lastIndexToDismiss]
                if tracker.isItemSkipped(at: item.identifier) {
                    throw AppFlowControllerError.showingSkippedPage(identifier: item.identifier)
                }
            }
        }
        
    }
    
}
