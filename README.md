# Introduction

This sample project demonstrates how to design an app conforming to VIPER architecture. This app has two screens. The first screen shows the list of nearby restaurants and the second screen show the details of one restaurant.

# Architecture

VIPER architecture was proposed by [Conrad Stoll](https://twitter.com/conradstoll) and Jeff Gilbert. This [article](https://www.objc.io/issues/13-architecture/viper/) discussed the architecture in detail.

![alt tag](https://www.objc.io/images/issue-13/2014-06-07-viper-wireframe-76305b6d.png)

### 1. Entity: 
This represents the business object. This is agnostic of any UI and database elements used in the app.

### 2. Interactor: 
This represents an usecase of an app. Usecase is simply a behaviour which the app exhibits. An usecase coordinates with entities and fulfills the goal of an usecase.

### 3. Presenter:
This prepares the data received from the interactor in a format to be used in the view.

### 4. View:
This receives the view model objects from the presenter and renders view.

### 5. Wireframe:
This is responsible for navigating to other screens.

### 6. Data Store:
This handle the data used in the app. Only the interactor interacts with datastore and manages data.

This app uses slightly modified version of this architecture.

![](https://github.com/raywenderlich/SC_SusmitaHorrow/blob/master/Images/VIPER%20-%20Modified.png)

* Classes marked with **( I )** are interfaces.
* Classes marked with **( DS )** are data structures. 
* Open arrow heads are using relationships.
* Closed arrow heads are implements or inheritance relationships.
* A -> B : Code of class A mentions the name of class B, but class B mentions nothing about class A.

### 1. ViewController:
   ViewController sends **ViewEvents** to the presenter. It implements **PresenterCommandListener** protocol.

### 2. Presenter:
   Presenter implements **ViewEventListener** protocol. It receives **ViewEvents**, invokes **Interactor** and sends command to **PresenterCommandListener** which is normally implemented by a ViewController.

### 3. Interactor: 
   Interactor implements **Interactor** protocol and provides methods to manage data. In this project, the interaction between **Interactor** and **Presenter** is handled via callbacks.

### 4. ScenePresenter:
   This is responsible for routing in the app. Presenter holds an reference of an object conforming to this protocol. It directs routing to other screens through ScenePresenter. Normally, a ViewController implements **ScenePresenter** as it knows how to push/pop new viewcontrollers.

# Overview
```
enum RestaurantListViewEvent: ViewEvent {
	case viewDidLoad
	case didTapOnRestaurant(index: Int)
}

enum RestaurantListPresenterCommand: PresenterCommand {
	case populateList(viewModels: [RestaurantViewModel])
	case showError(title: String, message: String)
}

protocol RestaurantListPresenterProtocol {
	var interactor: RestaurantListInteractorProtocol { get }
	var commandListener: RestaurantListCommandListenerProtocol? { get set }
	func handle(event: RestaurantListViewEvent)
}

protocol RestaurantListCommandListenerProtocol: class {
	func handle(command: RestaurantListPresenterCommand)
}

protocol RestaurantListInteractorProtocol {
	func fetchNearby(completionBlock: @escaping RequestCompletionBlock<SuggestedRestaurants>)
}

protocol ScenePresenter: class {
	func present(viewController: UIViewController)
}

```

