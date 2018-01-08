## Screencast Title
   Introduction to VIPER

## Screencast Description
   How to get started with VIPER architecture in iOS

## Language, Editor and Platform versions used in this screencast:

* **Language:** Swift 4

* **Platform:** iOS 11

* **Editor**: XCode 9.0

## Introduction

Hi everyone, this is Susmita. In today’s screencast, I will build an app to fetch nearby restaurants with VIPER architecture. The app will have two screens. The first screen will show the list of restaurants and the second screen will show the details of the selected restaurant. Before getting started, why don’t we go through some theory of VIPER? Yeah, listening to theory is boring, but I promise, I will keep it short.

## Talking Head

### Show Slide 1
VIPER architecture is based on Clean Architecture proposed by Uncle Bob, which divides the parts of a software into pluggable layers so that the software is easy to maintain and extend. So this diagram shows different components of VIPER archirecture. It has the following components, Entity, Interactor, Presenter, Router and View.

- An entity represents the business object of the application. It can be an object with methods, or it can be a set of data structures and functions. For our app, it would be the Restuarant object. The entity layer should not be affected by the changes in UI layer or any other lower level layers. Therefore an entity should never hold an reference to an interactor or a presenter.
- An interactor implements an use case. An use case encapsulates application-specific business rules. For our app the use cases will be “fetch the list of restaurants”, “fetch details of a restaurant. This is responsible for fetching data from remote server or local data store like core data.
- A presenter receives the data from interactor and creates model object for views called ViewModels. A viewModel does not contain any business rule.
- A view sends view events like button tap, cell selection etc to the presenter which invokes appropriate interactor method. On receiving, viewModels, the view renders them.
- The router is responsible for navigation between the viewcontrollers.

### Show Slide 2

This figure shows message passing takes place between the components.

Notice we have four boxes marked with <DS>. <DS> means data structure. Those are ViewEvent, PresenterCommand, InteractorRequest and InteractorResponse.

- ViewController passes the events to the Presenter as ViewEvent object.
- The presenter passes request for data via InteractorRequest.
- After fetching data, the Interactor passes the response via InteractorResponse object. 
- Then the presenter after processing data, hands over PresenterCommand to be handled by the ViewController.


Notice we have four boxes marked with <I>. <I> means interface/protocol. 
In each usecase, there are four roles.
1. InteactorListenerProtocol which is implemented by Presenter. It receives InteractorResponse from the interactor through this interface.
2. InteractorProtocol, implemented by Interactor. It receives InteactorRequest from the presenter through this interface.
3. PresenterProtocol, implemented by Presenter. It receives ViewEvent from the viewController through this interface.
4. PresenterListenerProtocol, implemented ViewContoller. It receives PresenterCommand from the presenter through this interface.


## Demo
In VIPERProtocols.swift, I have defined four protocols, ViewEvent, PresenterCommand, InteractorRequest and InteractorResponse. Whenever, I will implement an usecase, the viewEvent datatype wil conform to ViewEvent protocol, presenterCommand datatype to PresenterCommand protocol, interactorRequest datatype to InteractorRequest and interactorResponse to InteractorResponse protocol.

```
protocol ViewEvent {}
protocol PresenterCommand {}
protocol InteractorRequest {}
protocol InteractorResponse {}
```

## Talking Head

### Show Slide 3

This figure shows the navigation between the flows. 

Navigation is handled by three main components. Router, Scene and ScenePresenter. 
- Scene has the responsibility to configure a viewcontroller for an use case. 

- ScenePresenter is responsible for presenting a given viewController.

- Router has two methods. 
  1. Launch Scene to make the scene as rootViewController of current window.
  2. Present Scene to navigate to other viewController of another usecase.


## Demo 

ScenePresenter is a protocol with one method present(viewController). It is normally implemented by a ViewController.
```
protocol ScenePresenter: class {
  func present(viewController: UIViewController)
}
```


Let's begin by implementing the Scene. I will open Scene.swift and create an enum Scene with two cases restaurantList and restaurantDetail.
```
enum Scene {

	case restaurantList
	case restaurantDetail(id: String)
}
```

Now I will implement the configure method. Before that I will add two helper methods, configureRestaurantList and configureRestaurantDetail which handle configuration for cases restaurantList and restaurantDetail respectively.


```
enum Scene {

	case restaurantList
	case restaurantDetail(id: String)

	func configure() -> UIViewController {
		switch self {
		case .restaurantList:
			return configureRestaurantList()
		case .restaurantDetail(let id):
			return configureRestaurantDetail(detailId: id)
		}
	}

	func configureRestaurantList() -> UINavigationController {
  		let restaurantListVC = RestaurantListViewController.storyboardInstance
		return UINavigationController(rootViewController: restaurantListVC)
	}

	func configureRestaurantDetail(detailId: String) -> RestaurantDetailViewController {
  		let restaurantDetailVC = RestaurantDetailViewController.storyboardInstance
  		return restaurantDetailVC
	}
}
```

Note that, currently we are returning an instance of UINavigationController with RestaurantListViewController as rootViewController for the case restaurantList.
For case restaurantDetail, we are returning an instance of RestaurantDetailViewController.

Now I will implement the Router. It is a shared instance with two methods launch scene and present scene.
Launch scene will get viewcontroller from scene.configure method and set this as rootViewController of current window. 
Present will present the viewcontroller return by the scene.configure.

```
class Router {
	static var shared = Router()
	private init() {}
	
	func launch(scene: Scene) {
		let window = UIApplication.shared.keyWindow
		let viewController = scene.configure()
		window?.rootViewController = viewController
		window?.makeKeyAndVisible()
	}

	func present(scene: Scene, scenePresenter: ScenePresenter) {
		let viewController = scene.configure()
		scenePresenter.present(viewController: viewController)
	}
}
```

Now I will go to the AppDelegate and call Router.shared.launch(scene: .restaurantList). 
```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
	self.window = UIWindow(frame: UIScreen.main.bounds)
	self.window?.makeKeyAndVisible()
	Router.shared.launch(scene: .restaurantList)
	return true
}
```

 Let's build and run. Now we see restaurant list screen set as the first screen of the app.

## Talking Head

Now let's move on building other components.
## Demo

Now I will open **RestaurantListProtocols.swift** and start configuring the use case **Fetch Nearby Restaurants** by defining enums required for message passing in RestaurantListProtocols.swift.
- First, I will create an enum **RestaurantListViewEvent** by conforming to protocol **ViewEvent**. We have two events here, one is viewDidLoad and other is didTapOnRestaurant.

```
enum RestaurantListViewEvent: ViewEvent {
  case viewDidLoad
  case didTapOnRestaurant(index: Int)
}
```

- Now, I will create an enum **RestaurantListPresenterCommand** conforming to protocol **PresenterCommand**. We have two cases here. populateList and showError.

```
enum RestaurantListPresenterCommand: PresenterCommand {
  case populateList(viewModels: [RestaurantViewModel])
  case showError(title: String, message: String)
}
```

Note that the presenter passes the array of RestaurantViewModel, which is used by the view, not the Restaurant object. The business object should not leak to the view layer.

- Now, I will create an enum **RestaurantListInteractorRequest** conforming to protocol **InteractorRequest**. Here we have just one case fetchNearbyRestaurant.

```
enum RestaurantListInteractorRequest: InteractorRequest {
  case fetchNearbyRestaurant
}
```

- Now, I will create an enum **RestaurantListInteractorResponse** conforming to protocol **InteractorResponse**. Here we have one case didFetchNearbyRestaurant.

```
enum RestaurantListInteractorResponse: InteractorResponse {
  case didFetchNearbyRestaurant(result: ServiceResult<SuggestedRestaurants>)
}
```
ServiceResult is an enum which case two cases, success and failure. (_This is predefined_)

```
enum ServiceResult<Value> {
  case success(Value)
  case failure(ApplicationError)
}
```

## Talking Head

So enum for message passing is ready. Next I will define protocols for view, presenter and interactor.

## Demo

- I will first define **RestaurantListInteractorListenerProtocol**. It has one method handle which should contain logic for handling different kinds of **RestaurantListInteractorResponse**. This will be implemented by the presenter.

```
protocol RestaurantListInteractorListenerProtocol: class {
  func handle(response: RestaurantListInteractorResponse)
}
```

- Now I will define RestaurantListInteractorProtocol. This will be implemented by the interactor. 
  It has one get set property responseListener of type **RestaurantListInteractorListenerProtocol**, and one method handle which will implement the logic for handling different kinds of **RestaurantListInteractorRequest**.

```
protocol RestaurantListInteractorProtocol: class {
  var responseListener: RestaurantListInteractorListenerProtocol? { get set }
  func handle(request: RestaurantListInteractorRequest)
}
```

- Now I will define RestaurantListPresenterListenerProtocol. It has one method handle which will contain the logic for handling different kinds of RestaurantListPresenterCommand. This will be implemented by the ViewController.

```
protocol RestaurantListPresenterListenerProtocol: class {
  func handle(command: RestaurantListPresenterCommand)
}
```

- Now I will define RestaurantListPresenterProtocol. It as one read only property interactor of type RestaurantListInteractorProtocol, get set property commandListener of type RestaurantListPresenterListenerProtocol, and a method handle containing the logic for handling different kinds of RestaurantListViewEvent. This will be implemented by the presenter.

```
protocol RestaurantListPresenterProtocol: class {
  var interactor: RestaurantListInteractorProtocol { get }
  var commandListener: RestaurantListPresenterListenerProtocol? { get set }
  func handle(event: RestaurantListViewEvent)
}
```


## Taking Head
Now, our protocols are ready. Let’s implement the RestaurantListInteractor.

## Demo
- I will open **RestaurantListInteractor.swift** and define RestaurantListInteractor
I will add one property, baseApiClient of type BaseAPIClient which is responsible for fetching data from the server.
Then I will add another property, listener of type RestaurantListInteractorListenerProtocol.

```
class RestaurantListInteractor {
 fileprivate var baseApiClient = BaseAPIClient.shared
 fileprivate weak var listener: RestaurantListInteractorListenerProtocol?
}
```
- Now I will extend **RestaurantListInteractor** to conform to the protocol RestaurantListInteractorProtocol. It will add stubs for us. I will return the listener which I just defined from the getter of responseListener and set presenter to newValue in setter.

```
extension RestaurantListInteractor: RestaurantListInteractorProtocol {
  var responseListener: RestaurantListInteractorListenerProtocol? {
     get {
       return listener
     }
     set {
       listener = newValue
     }
  }
  func handle(request: RestaurantListInteractorRequest) {}
```
- Then I will implement the handle method. I will switch through all the cases of RestaurantListInteractorRequest. Here we have just one case, fetchNearbyRestaurant. I will create an instance of resource of type Resource<SuggestedRestaurants>. This object encapsulates all the information required for fetching data from server as well as parsing information. I just need to pass which endpoint to hit, which is **RequestRouter.fetchList** for this use case.

```
let resource = Resource<SuggestedRestaurants>(requestRouter: RequestRouter.fetchList)			self.baseApiClient.request(resource) { [weak self] result in
    self?.listener?.handle(response: .didFetchNearbyRestaurant(result: result))
}

```
## Talking Head

Now our RestaurantListInteractor is ready. Now let’s implement the RestaurantListPresenter.

## Code
- I will open **RestaurantListPresenter.swift** and define RestaurantListPresenter.
I will add one property, restaurantListInteractor of type RestaurantListInteractorProtocol.
I will add another property, scenePresenter of type ScenePresenter.
Then I will add a list which is an array of Restaurant.

```
class RestaurantListPresenter {
    let restaurantListInteractor: RestaurantListInteractorProtocol
    weak var listener: RestaurantListPresenterListenerProtocol? = nil
    weak var scenePresenter: ScenePresenter? = nil
    private var list: [Restaurant] = []

    init(interactor: RestaurantListInteractorProtocol) {
	self.restaurantListInteractor = interactor
    }
}
```
- Now I will extend **RestaurantListPresenter** to conform to the protocol RestaurantListInteractorListenerProtocol. Here we have just one case. handle(response: RestaurantListInteractorResponse). We will call a method handleRestaurantsReceived. 
```
extension RestaurantListPresenter: RestaurantListInteractorListenerProtocol {
  func handle(response: RestaurantListInteractorResponse) {
     switch response {
       case .didFetchNearbyRestaurant(let result):
         handleRestaurantsReceived(result: result)
     }
  }
```
In the success case, I will save the received list. I will convert the suggestedRestaurants.list to array of RestaurantViewModel. Then I will create a command RestaurantListPresenterCommand.populateList with the array of view models. Then I will call listener.handle(command: command)
In the error case, I will create command RestaurantListPresenterCommand.showError and  I will call listener.handle(command: command).

```
fileprivate func handleRestaurantsReceived(result: ServiceResult<SuggestedRestaurants>) {
   switch result {
     case .success(let suggestedRestaurants):
       self.list = suggestedRestaurants.list
       let viewModels = self.list.map { RestaurantViewModel(restaurant: $0) }
       let command = RestaurantListPresenterCommand.populateList(viewModels: viewModels)
       self.listener?.handle(command: command)
     case .failure(let error):
       let command = RestaurantListPresenterCommand.showError(
        title: error.title, message: error.errorDescription ?? "")
       self.listener?.handle(command: command)
   }
}
```
- Now we’ll extend RestaurantListPresenter to conform to the protocol RestaurantListInteractorListenerProtocol. It will add stubs for us. I will return self.restaurantListInteractor from the getter of interactor. I will return self.listener from the getter of commandListener and set the value of self.listener to new value on setter.

```
extension RestaurantListPresenter: RestaurantListPresenterProtocol {
  var interactor: RestaurantListInteractorProtocol {
    return self.restaurantListInteractor
  }
  var commandListener: RestaurantListPresenterListenerProtocol? {
    get {
      return self.listener
    }
    set {
      self.listener = newValue
    }
  }
  func handle(event: RestaurantListViewEvent) {}
}
```
- Now in the handle method, we need to handle two cases. one is viewDidLoad and the other is didTapOnRestaurant. For the time being, we will just implement viewDidLoad. On ViewDidLoad, we will call    self.restaurantListInteractor.handle(request: .fetchNearbyRestaurant).
On didTapOnRestaurant, we will get id of selected restaurant and present the restaurantDetail scene.

```
func handle(event: RestaurantListViewEvent) {
  switch event {
  case .viewDidLoad:
    self.restaurantListInteractor.handle(request: .fetchNearbyRestaurant)
   
  case .didTapOnRestaurant(let index): 
    let id = self.list[index].id
    if let scenePresenter = self.scenePresenter {
       Router.shared.present(scene: .restaurantDetail(id: id), scenePresenter: scenePresenter)
    }
  }
}
```

## Talking Head

Now let’s extend RestaurantListViewController to conform to protocol RestaurantListViewController. It would implement handle method and have to handle two commands.
On populateList, we will call tableView.reloadData()
On showError, we will show an alert.

## Code

```
extension RestaurantListViewController: RestaurantListPresenterListenerProtocol {
	func handle(command: RestaurantListPresenterCommand) {
	switch command {
	case .populateList(let viewModels):
		self.viewModels = viewModels
		tableView.reloadData()
	case .showError(let title, let message):
		self.showAlert(title: title, message: message)
		}
	}
}
```

showAlert is defined in the extension of UIViewController.

## Talking Head

We also need to make RestaurantListViewController conform to ScenePresenter. In present method we will just push the given viewcontroller.

## Code 

```
extension RestaurantListViewController: ScenePresenter {
	func present(viewController: UIViewController) {
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}
```

## Talking Head
We have our presenter, interactor and view ready. We need to plug them together now. I will update configureRestaurantList method.

- First I'll create instance of RestaurantListInteractor and RestaurantListPresenter as interactor and presenter.
- Then set interactor.responseListener to presenter.
- Then set presenter.scenePresenter to restaurantListVC
- Then set presenter.commandListener to restaurantListVC.
- Then set restaurantListVC.presenter to presenter.

```
func configureRestaurantList() -> UINavigationController {
	let restaurantListVC = RestaurantListViewController.storyboardInstance
	let interactor = RestaurantListInteractor()
	let presenter = RestaurantListPresenter(interactor: interactor)
	interactor.responseListener = presenter
	presenter.scenePresenter = restaurantListVC
	presenter.commandListener = restaurantListVC
	restaurantListVC.presenter = presenter
	let navigationController = UINavigationController(rootViewController: restaurantListVC)
	return navigationController
```

## Talking Head

Now everything is ready, let's build an run. Great! we see the list of restuarants.

## Conclusion
I hope this video helped you to get started with VIPER architecture.