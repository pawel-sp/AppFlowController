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
    public var rootNavigationController: UINavigationController?
    
    private(set) var rootPathStep: PathStep?
    let tracker: Tracker
    
    // MARK: - Init
    
    init(trackerClass: Tracker.Type) {
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
    public func prepare(for window: UIWindow, rootNavigationController: UINavigationController = UINavigationController()) {
        self.rootNavigationController = rootNavigationController
        window.rootViewController = rootNavigationController
    }
    
    public func register(pathComponent: FlowPathComponent) throws {
        try register(pathComponents: [pathComponent])
    }

    public func register(pathComponents: [FlowPathComponent]) throws {
        if let lastPathComponent = pathComponents.last, !lastPathComponent.supportVariants, rootPathStep?.search(pathComponent: lastPathComponent) != nil {
            throw AFCError.pathAlreadyRegistered(identifier: lastPathComponent.identifier)
        }
        
        var previousStep: PathStep?
        
        for var element in pathComponents {
            if let found = rootPathStep?.search(pathComponent: element) {
                previousStep = found
                continue
            } else {
                if let previous = previousStep {
                    if element.supportVariants {
                        element.variantName = previous.pathComponent.identifier
                    }
                    if element.forwardTransition == nil || element.backwardTransition == nil {
                        throw AFCError.missingPathStepTransition(identifier: element.identifier)
                    }
                    previousStep = previous.add(pathComponent: element)
                } else {
                    rootPathStep = PathStep(pathComponent: element)
                    previousStep = rootPathStep
                }
            }
        }
    }
    
    /**
        Before presenting any page you need to register it using path components.
     
        - Parameter pathComponents:   Sequences of pages which represent all possible paths inside the app. The best way to register pages is to use => and =>> operators which assign transitions directly to pages.
        - Throws:           
            AFCError.missingPathStepTransition if forward or backward transition of any page is nil
            AFCError.pathAlreadyRegistered     if that page was registered before (all pages need to have unique name). If you want to use the same page few times in different places it's necessary to set supportVariants property to true.
     */
    public func register(pathComponents: [[FlowPathComponent]]) throws {
        for subPathComponents in pathComponents {
            try register(pathComponents: subPathComponents)
        }
    }
    
    // MARK: - Navigation

    /**
        Display view controller configured inside the path.
     
        - Parameter pathComponent:          Page to present.
        - Parameter variant:                If page supports variants you need to pass the correct variant (previous page). Default = nil.
        - Parameter parameters:             For every page you can set single string value as it's parameter. It works also for pages with variants. Default = nil.
        - Parameter animated:               Determines if presenting page should be animated or not. Default = true.
        - Parameter skipDismissTransitions: Use that property to skip all dismiss transitions. Use that with conscience since it can break whole view's stack (it's helpfull for example when app has side menu).
        - Parameter skipPages:              Pages to skip.
     
        - Throws:
            AFCError.missingConfiguration       if prepare(UIWindow, UINavigationController) wasn't invoked before.
            AFCError.showingSkippedPage         if page was previously skipped (for example when you're trying go back to page which before was skipped and it's not present inside the navigation controller).
            AFCError.missingVariant             if page's property supportVariants == true you need to pass variant property, otherwise it's not possible to set which page should be presenter.
            AFCError.variantNotSupported        if page's property supportVariants == false you cannot pass variant property, because there is only one variant of that page.
            AFCError.unregisteredPathIdentifier page need to be registered before showing it.
    */
    open func show(
        _ pathComponent: FlowPathComponent,
        variant: FlowPathComponent? = nil,
        parameters: [TransitionParameter]? = nil,
        animated: Bool = true,
        skipDismissTransitions: Bool = false,
        skipPathComponents: [FlowPathComponent]? = nil) throws {
        
        guard let rootNavigationController = rootNavigationController else {
            throw AFCError.missingConfiguration
        }
        let foundStep = try pathStep(from: pathComponent, variant: variant)
        let newPathComponents = rootPathStep?.allParentPathComponents(from: foundStep) ?? []
        let currentStep = visibleStep
        let currentPathComponents = currentStep == nil ? [] : (rootPathStep?.allParentPathComponents(from: currentStep!) ?? [])
        let keysToClearSkip = newPathComponents.filter({ !currentPathComponents.contains($0) }).map({ $0.identifier })
        
        if let currentStep = currentStep {
            let distance = PathStep.distanceBetween(step: currentStep, and: foundStep)
            let dismissCounter = distance.up
            let _ = distance.down
            let dismissRange: Range<Int> = dismissCounter == 0 ? 0..<0 : (currentPathComponents.count - dismissCounter) ..< currentPathComponents.count
            let displayRange: Range<Int> = 0 ..< newPathComponents.count
         
            try verify(pathComponents: currentPathComponents, distance: distance)
            dismiss(pathComponents: currentPathComponents, fromIndexRange: dismissRange, animated: animated, skipTransition: skipDismissTransitions) {
                self.register(parameters: parameters, for: newPathComponents, skippedPathComponents: skipPathComponents)
                self.tracker.disableSkip(for: keysToClearSkip)
                self.display(pathComponents: newPathComponents, fromIndexRange: displayRange, animated: animated, skipPathComponents: skipPathComponents, completion: nil)
            }
        } else {
            rootNavigationController.viewControllers.removeAll()
            tracker.reset()
            register(parameters: parameters, for: newPathComponents, skippedPathComponents: skipPathComponents)
            tracker.disableSkip(for: keysToClearSkip)
            display(pathComponents: newPathComponents, fromIndexRange: 0..<newPathComponents.count, animated: animated, skipPathComponents: skipPathComponents, completion: nil)
        }
    }
    
    /**
        Displays previous page.
     
        - Parameter animated: Determines if presenting page should be animated or not. Default = true.
    */
    public func goBack(animated: Bool = true) {
        guard let visible = visibleStep else { return }
        guard let pathComponent = visible.firstParentPathComponent(where: { tracker.viewController(for: $0.identifier) != nil }) else { return }
        guard let viewController = tracker.viewController(for: pathComponent.identifier) else { return }
        visible.pathComponent.backwardTransition?.performBackwardTransition(animated: animated){}(viewController)
    }
    
    /**
        Pops navigation controller to specified path. It always current view controller's navigation controller. If page isn't not present in current navigation controller nothing would happen.
     
        - Parameter pathComponent: Path component to pop.
        - Parameter animated:      Determines if transition should be animated or not.
    */
    public func pop(to pathComponent: FlowPathComponent, animated: Bool = true) throws {
        guard let rootNavigationController = rootNavigationController else {
            throw AFCError.missingConfiguration
        }
        guard let foundStep = rootPathStep?.search(pathComponent: pathComponent) else {
            throw AFCError.unregisteredPathIdentifier(identifier: pathComponent.identifier)
        }
        guard let targetViewController = tracker.viewController(for: foundStep.pathComponent.identifier) else {
            throw AFCError.popToSkippedPath(identifier: foundStep.pathComponent.identifier)
        }
        rootNavigationController.visible.navigationController?.popToViewController(targetViewController, animated: animated)
    }
    
    /**
        If you presented view controller without AppFlowController you need to update current path. Use that method inside the viewDidLoad method of presented view controller to make sure that whole step tree still works.
     
        - Parameter viewController: Presented view controller.
        - Parameter name:           Name of path associated with that view controller. That page need to be registered.
     
        - Throws:
            AFCError.unregisteredPathIdentifier if page wasn't registered before.
    */
    public func updateCurrentPath(with viewController: UIViewController, for name:String) throws {
        if let _ = rootPathStep?.search(identifier: name) {
            self.tracker.register(viewController: viewController, for: name)
        } else {
            throw AFCError.unregisteredPathIdentifier(identifier: name)
        }
    }
    
    /**
        Returns string representation of whole path to specified page, for example home/start/login.
     
        - Parameter pathComponent: Path component to receive all path steps.
        - Parameter variant:       Variant of that page (previous path component). Use it only if page supports variants.
     
        - Throws:
             AFCError.missingVariant             if page's property supportVariants == true you need to pass variant property, otherwise it's not possible to set which page should be presenter.
             AFCError.variantNotSupported        if page's property supportVariants == false you cannot pass variant property, because there is only one variant of that page.
             AFCError.unregisteredPathIdentifier page need to be registered before showing it.
    */
    open func pathComponents(for pathComponent: FlowPathComponent, variant: FlowPathComponent? = nil) throws -> String {
        let foundStep = try pathStep(from: pathComponent, variant: variant)
        let pathComponents = rootPathStep?.allParentPathComponents(from: foundStep) ?? []
        let pathComponentStrings = pathComponents.map{ $0.identifier }
        return pathComponentStrings.joined(separator: "/")
    }
    
    /**
        Returns string representation of whole path to current path, for example home/start/login.
    */
    open var currentPathDescription: String? {
        if let visibleStep = visibleStep {
            let items = rootPathStep?.allParentPathComponents(from: visibleStep) ?? []
            let itemStrings = items.map{ $0.identifier }
            return itemStrings.joined(separator: "/")
        } else {
            return nil
        }
    }
    
    /**
        Returns currenlty visible path.
    */
    open var currentPathComponent: FlowPathComponent? {
        return visibleStep?.pathComponent
    }
    
    /**
        Returns parameter for currently visible path. It's nil if path was presented without any parametes.
    */
    open var currentPathParameter: String? {
        if let currentPathID = currentPathComponent?.identifier {
            return tracker.parameter(for: currentPathID)
        } else {
            return nil
        }
    }
    
    /**
        Returns parameter for specified path. It's nil if page was presented without any parametes.
     
        - Parameter pathComponent: Path component to retrieve parameter.
        - Parameter variant:       Variant of that path (previous path). Use it only if page supports variants.
     
        - Throws:
             AFCError.missingVariant             if pathe's property supportVariants == true you need to pass variant property, otherwise it's not possible to set which page should be presenter.
             AFCError.variantNotSupported        if path's property supportVariants == false you cannot pass variant property, because there is only one variant of that page.
             AFCError.unregisteredPathIdentifier page need to be registered before showing it.
    */
    open func parameter(for pathComponent: FlowPathComponent, variant: FlowPathComponent? = nil) throws -> String? {
        let step = try pathStep(from: pathComponent, variant: variant)
        return tracker.parameter(for: step.pathComponent.identifier)
    }
    
    /**
        Reset root navigation controller and view's tracker. It removes all view controllers including those presented modally.
    */
    open func reset(completion: (()->())? = nil) {
        rootNavigationController?.dismissAllPresentedViewControllers() {
            self.rootNavigationController?.viewControllers.removeAll()
            self.tracker.reset()
            completion?()
        }
    }
    
    // MARK: - Helpers
    
    private var visibleStep: PathStep? {
        guard let currentViewController = rootNavigationController?.visibleNavigationController.visible else { return nil }
        guard let key = tracker.key(for: currentViewController) else { return nil }
        return rootPathStep?.search(identifier: key)
    }
    
    private func viewControllers(from pathComponents: [FlowPathComponent], skipPathComponents: [FlowPathComponent]? = nil) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        for pathComponent in pathComponents {
            if pathComponent.forwardTransition?.shouldPreloadViewController() == true, let viewController = tracker.viewController(for: pathComponent.identifier) {
                viewControllers.append(viewController)
                continue
            }
            if skipPathComponents?.contains(where: { $0.identifier == pathComponent.identifier }) == true {
                tracker.register(viewController: nil, for: pathComponent.identifier, skipped: true)
                continue
            }
            let viewController = pathComponent.viewControllerInit()
            tracker.register(viewController: viewController, for: pathComponent.identifier)
            
            if let step = rootPathStep?.search(pathComponent: pathComponent) {
                let preload = step.children.filter({ $0.pathComponent.forwardTransition?.shouldPreloadViewController() == true })
                for item in preload {
                    if let childViewController = self.viewControllers(from: [item.pathComponent], skipPathComponents: skipPathComponents).first {
                        item.pathComponent.forwardTransition?.preloadViewController(childViewController, from: viewController)
                    }
                }
            }
            
            viewControllers.append(pathComponent.forwardTransition?.configureViewController(from: viewController) ?? viewController)
        }
        return viewControllers
    }
    
    private func register(parameters: [TransitionParameter]?, for pathComponents: [FlowPathComponent], skippedPathComponents: [FlowPathComponent]?) {
        if let parameters = parameters {
            for parameter in parameters {
                if pathComponents.filter({ $0.identifier == parameter.identifier }).count == 0 {
                    continue
                }
                if (skippedPathComponents?.filter({ $0.identifier == parameter.identifier }).count ?? 0) > 0 {
                    continue
                }
                self.tracker.register(parameter: parameter.value, for: parameter.identifier)
            }
        }
    }
    
    private func display(pathComponents: [FlowPathComponent], fromIndexRange indexRange: Range<Int>, animated: Bool, skipPathComponents: [FlowPathComponent]? = nil, completion: (() -> ())?) {
        let index = indexRange.lowerBound
        let item = pathComponents[index]
        let identifier = item.identifier
        
        guard let navigationController = rootNavigationController?.visible.navigationController ?? rootNavigationController else {
            completion?()
            return
        }
        
        func displayNextItem(range: Range<Int>, animated: Bool, offset: Int = 0) {
            let newRange:Range<Int> = (range.lowerBound + 1 + offset) ..< range.upperBound
            if newRange.count == 0 {
                completion?()
            } else {
                self.display(
                    pathComponents: pathComponents,
                    fromIndexRange: newRange,
                    animated: animated,
                    skipPathComponents: skipPathComponents,
                    completion: completion
                )
            }
        }
        
        let viewControllerExists = tracker.viewController(for: item.identifier) != nil
        let pathSkipped = tracker.isItemSkipped(at: item.identifier)
        let itemIsPreloaded = item.forwardTransition?.shouldPreloadViewController() == true
        
        if navigationController.viewControllers.count == 0 {
            let pathComponentsToPush = [item] + pathComponents[1..<pathComponents.count].prefix(while: { $0.forwardTransition is PushPopFlowTransition })
            let viewControllersToPush = self.viewControllers(from: pathComponentsToPush, skipPathComponents: skipPathComponents)
            let skippedPathComponents = pathComponentsToPush.count - viewControllersToPush.count
            
            navigationController.setViewControllers(viewControllersToPush, animated: false) {
                displayNextItem(range: indexRange, animated: false, offset: max(0, viewControllersToPush.count - 1 + skippedPathComponents))
            }
        } else if (!viewControllerExists || itemIsPreloaded) && !pathSkipped {
            let viewControllers = self.viewControllers(from: [item], skipPathComponents: skipPathComponents)
            if let viewController = viewControllers.first {
                item.forwardTransition?.performForwardTransition(animated: animated){
                    displayNextItem(range: indexRange, animated: animated)
                }(navigationController, viewController)
            } else {
                displayNextItem(range: indexRange, animated: animated)
            }
        } else {
            displayNextItem(range: indexRange, animated: animated)
        }
    }
    
    private func dismiss(pathComponents: [FlowPathComponent], fromIndexRange indexRange: Range<Int>, animated: Bool, skipTransition: Bool = false, viewControllerForSkippedPath: UIViewController? = nil, completion:(() -> ())?) {
        if indexRange.count == 0 {
            completion?()
        } else {
            let index = indexRange.upperBound - 1
            let item = pathComponents[index]
            let parentPathComponent = rootPathStep?.search(pathComponent: item)?.parent?.pathComponent
            let skipParentPathComponent = parentPathComponent == nil ? false : tracker.isItemSkipped(at: parentPathComponent!.identifier)
            let skippedPathComponent = tracker.isItemSkipped(at: item.identifier)
            let viewController = tracker.viewController(for: item.identifier)
            
            func dismissNext(viewControllerForSkippedPath: UIViewController? = nil) {
                self.dismiss(
                    pathComponents: pathComponents,
                    fromIndexRange: indexRange.lowerBound..<indexRange.upperBound - 1,
                    animated: animated,
                    skipTransition: skipTransition,
                    viewControllerForSkippedPath: viewControllerForSkippedPath,
                    completion: completion
                )
            }
            
            func dismiss(useTransition: Bool, viewController: UIViewController) {
                if useTransition {
                    item.backwardTransition?.performBackwardTransition(animated: animated){ dismissNext() }(viewController)
                } else {
                    dismissNext()
                }
            }
            
            if skipParentPathComponent {
                dismissNext(viewControllerForSkippedPath: viewController ?? viewControllerForSkippedPath)
            } else if let viewController = viewControllerForSkippedPath, skippedPathComponent {
                dismiss(useTransition: !skipTransition, viewController: viewController)
            } else if let viewController = viewController, !skippedPathComponent {
                dismiss(useTransition: !skipTransition, viewController: viewController)
            } else {
                completion?()
            }
        }
    }
    
    private func pathStep(from pathComponent: FlowPathComponent, variant: FlowPathComponent? = nil) throws -> PathStep {
        var pathComponent = pathComponent
        if pathComponent.supportVariants && variant == nil {
            throw AFCError.missingVariant(identifier: pathComponent.identifier)
        }
        if !pathComponent.supportVariants && variant != nil {
            throw AFCError.variantNotSupported(identifier: pathComponent.identifier)
        }
        if pathComponent.supportVariants && variant != nil {
            pathComponent.variantName = variant?.identifier
        }
        guard let foundStep = rootPathStep?.search(pathComponent: pathComponent) else {
            throw AFCError.unregisteredPathIdentifier(identifier: pathComponent.identifier)
        }
        return foundStep
    }
    
    private func verify(pathComponents: [FlowPathComponent], distance: (up: Int, down: Int)) throws {
        if distance.up > 0 {
            let lastIndexToDismiss = pathComponents.count - 1 - distance.up
            if lastIndexToDismiss >= 0 && lastIndexToDismiss < pathComponents.count - 1 {
                let item = pathComponents[lastIndexToDismiss]
                if tracker.isItemSkipped(at: item.identifier) {
                    throw AFCError.showingSkippedPath(identifier: item.identifier)
                }
            }
        }
    }
    
}
