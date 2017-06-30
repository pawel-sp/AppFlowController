## Introduction

AppFlowController is designed to improve way of displaying view controllers inside the app and make sure that only those pages which were registered previously can be shown. That approach guarantees that users won't see any view controller in place which wasn't predicted by developer in the app.

## Registering steps

Before you will start presenting view controllers you need to initialize AppFlowController. Look at example below:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    AppFlowController.shared.prepare(for:window!)

    let start = AppFlowControllerPage(name: "start", storyboardName: "Main", viewControllerType: StartViewController.self)
    try! AppFlowController.shared.register(path: start)
    try! AppFlowController.shared.show(page: start)
}
```

To register more complicated structure you can use overloaded operators ```=>``` and ```=>>```:

```swift
try! AppFlowController.shared.register(path:
    start => menu =>> [
        page1,
        page2 => page3
    ]
)
```

That structure means that you can present page1 and page2 only from menu page and page3 only from page2. By default all transitions between pages are using default push and pop animations. To have different transitions you can use one of three subclasses:

```swift
let pushAndPop = PushPopAppFlowControllerTransition.default
let modal      = DefaultModalAppFlowControllerTransition.default
let tab        = DefaultTabBarAppFlowControllerTransition.default
```

You can create your own classes which conform to protocol AppFlowControllerTransition to deliver your own method of presenting view controllers. To register page with transition you need to put it between pages using ```=>``` or ```=>>``` operator:

```swift
try! AppFlowController.shared.register(path:
    start =>> [
        page1,
        page2 => modal => page3
    ]
)
```

That means that page3 will be presented modally from page2. All view controllers presented modally or as a UITabBarController's view controller are inside newly allocated navigation controller by default. You can change the default class of it using generic parameter in classes like ModalAppFlowControllerTransition or TabBarAppFlowControllerTransition.

## Showing pages

There are few important things which you need to remember when you are using AppFlowController. First of all you should delete all connections between view controllers in storyboards. To show specified view controller you should use ```show(page:AppFlowControllerPage)``` method. There could be some cases that you need to present view controller without AppFlowController. In those situations after presenting that view controller you should update current page to keep the whole structure and order of pages according to registration. The best place to do that is to put below's code to ```viewDidLoad()``` method:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    try! AppFlowController.shared.updateCurrentPage(with: self, for: "name")
}
```

Page with that name should also be registered just like the other ones.

## Skipping pages

AppFlowController has possibility to skip some pages. Look at example below:

```swift
try! AppFlowController.shared.register(path:
    page1 => page2 => page3
)
try! AppFlowController.shared.show(page: page3, skipPages:[page2])
```

Let's assume that page1 is currently displayed. Although page3 is registered to be presented only from page2 there is a possibility to display it directly from page1. In that case you need to use skipPages parameter. Page2's view controller won't be present in the navigation controller. After going back to page1 AppFlowController clears all skipped pages settings so if you want to skip it again you need to use skipPages parameter second time.

## Page parameters

Pages can be presented with parameters. Currently AppFlowController has possibility to deliver only one string value per page. It suppose to be a database ID to fetch details model, etc. To show page with parameters you need to pass object of AppFlowControllerParameter class to show method:

```swift
try! AppFlowController.shared.show(
    page: page1,
    parameters:[
        AppFlowControllerParameter(page: page1, value: "value")
    ]
)
```

You can use few parameters if you want to pass one value for each page which gonna be presented in the middle way. To read parameter for currently presented page use ```currentPageParameter() -> String``` method.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    if let parameter = AppFlowController.shared.currentPageParameter() {
        print(parameter)
    }
}
```

## Variants

During pages registration there are few restrictions. One of them is to remember that all pages need to be unique. That means every page need to have different name. Unfortunately there are some cases that specific view controller need to be presented in few places, for example view controller responsible for login/register users. To avoid creating few exact the same pages with different names AppFlowController has variants. It means that you can register one page few times. First of all you need to set ```supportVariants``` property to ```true``` (it's false by default):

```swift
static let play = AppFlowControllerPage(
    name: "play",
    supportVariants: true,
    storyboardName: "Main",
    viewControllerType: PlayViewController.self
)
```

Now you can register play page few times. Without that property during registration AppFlowController would throw ```AppFlowControllerError.pathAlreadyRegistered``` exception. To show page which support variants you need to pass variant parameter (variant is a regular page which is before that page):

```swift
try! AppFlowController.shared.register(path:
    start =>> [
        page1 => play,
        page2 => play
    ]
)
try! AppFlowController.shared.show(
    page: play,
    variant: page1
)
```

In that case ```variant``` property is necessary otherwise ```AppFlowControllerError.missingVariant``` exception would be thrown.

## UITabBarController

The most complicated view controller to present is a UITabBarController. It works quite different than the others because all it's view controllers need to be assigned before presenting it. AppFlowController for those cases has TabBarAppFlowControllerTransition class.

```swift
let tab = DefaultTabBarAppFlowControllerTransition.default
try! AppFlowController.shared.register(path:
    tabsPage =>> [
        tab => tabPage1,
        tab => tabPage2
    ]
)
```

TabBarAppFlowControllerTransition has methods responsible for preloading view controllers before UITabBarController would be presented. Look at at [iOS-Example project](../../tree/master/iOS-Example.xcodeproj) project to check how it works.

## Child view controllers

View controllers with nested view controllers need to be configured to keep the AppFlowController's flow. First of all you need to make sure that child view controller is the one which is visible because AppFlowController uses it to detect the  current page. You can easily do that by creating your own navigation controller:

```swift
protocol ContainerViewControllerInterface {
    var childViewControllers: [UIViewController] { get }
}

class RootNavigationController: UINavigationController {
    override var visibleViewController: UIViewController? {
        if let containerViewController = super.visibleViewController as? ContainerViewControllerInterface {
            return containerViewController.childViewControllers.first ?? super.visibleViewController
        } else {
            return super.visibleViewController
        }
    }
}

AppFlowController.shared.prepare(for:window!, rootNavigationController:RootNavigationController())
```

Now you need to create custom transition class which is going to attach correct child view controller in the right moment (quite similar to tab bar transition). Look at ```ContainerTransition``` class inside the [iOS-Example project](../../tree/master/iOS-Example.xcodeproj) project to check how it works.

## Example
You can run [iOS-Example project](../../tree/master/iOS-Example.xcodeproj) to check all mentioned features and more.

## License

AppFlowController is released under the MIT license.
