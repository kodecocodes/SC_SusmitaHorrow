# Introduction

This sample project demonstrates how to design an app conforming to VIPER architecture. This app has two screens. The first screen shows the list of nearby restaurants and the second screen show the details of one restaurant.

VIPER architecture was proposed by [Conrad Stoll](https://twitter.com/conradstoll) and Jeff Gilbert, which is based on Clean Architecture proposed by [Robert C. Martin](https://twitter.com/unclebobmartin) (aka Uncle Bob). Clean Architecture is itself a combined version of Hexagonal Architecture and Onion Architecture. The following section discusses the Clean Architecture as described by Uncle Bob, implementation of Clean Architecture in iOS domain and then VIPER architecture used in the sample app.

- [Clean Architecture](#clean-architecture)
- [Clean Architecture for iOS](#clean-architecture-for-ios)
  - [VIP](#vip)
  - [VIPER](#viper)
  - [VIPER Simplified](#viper-simplified)

## Clean Architecture

[[https://cdn-images-1.medium.com/max/1600/1*ZNT5apOxDzGrTKUJQAIcvg.png | width = 700px]]

The concentric circles represent different areas of software. The further in we go, the higher level the software becomes. The various components follow the **Dependency Rule** to maintain proper boundary among themselves.
### The Dependency Rule
> Source code dependencies must point only inward, towards higher-level policies.

In other words, nothing in the inner circle(the higher component) can know anything at all about somethings in the outer circle(the lower component).

## Components

### Entities:
Entities encapsulate enterprise-wise Critical Business Rule. They are meant to be used by many different applications in the enterprise. An entity can be an object with methods, or it can be a set of data structures and functions.
In case of mobile applications, we have just one single application. In this case the entities represent the business objects of the application. This objects should be affected by the changes in UI layer or any other lower level layers.

### Use Cases
Use Cases encapsulate application-specific business rules. They coordinate with the entities to apply Critical Business Rule. 
Let’s take an example.
Suppose we are building a signup flow. Here one use case would be “User should be able to sign up”. Now the signup involves different objects to be validated. Those validation rules are specified in entities. Whereas Signup method is the part of use case layer which uses the entities to achieve the goal.

### Interface Adapters
They convert data from the format most convenient for the use cases and entities, to the most convenient for some external agency such as database and web.
This layer contains the whole of the MVC architecture of a GUI. The presenters, views and controllers all belong in this layer. 
In case of iOS Architecture, we have the following things in this layer.
1. ViewControllers
2. Presenters
3. Gateways : Interface to database layer, Interface to server

### Frameworks and Drivers
This layer generally contains the system framework. Here lies the UIKit, Coredata etc.

## Crossing Boundaries
![[https://github.com/raywenderlich/SC_SusmitaHorrow/blob/master/Images/Clean%20Architecture.png | width = 700px]]



1. Classes marked with **(I)** are interfaces. 
2. Classes marked with **(DS)** are data structures. 
3. Open arrow heads are using relationships.
   A -> B : Code of class A mentions the name of class B, but class B mentions nothing about class A.
4. Closed arrow heads are implements or inheritance relationships.

**All component relationships are unidirectional.**

### Example
Let us consider a case of a typical web based java application and understand how data flow across the boundaries.

1.  **Data flow from **Controller** to Interactor**

The web server gathers data from the user and hands it to the **Controller**. Then the **Controller** passes the data in a plain object to the **Interactor** through **InputBoundary**. 
If we follow the diagram above, both **Interactor** and **Controller** use the data structure **InputData**. 
According to the Dependency rule, the higher level module should not depend on the lower level module. **Interactor** should not have a reference to the Controller. Here Dependency Inversion principle is applied. An interface **InputBoundary** is defined which is implemented by **Interactor**.

2. **Data flow from **Interactor** to **Presenter****

The **Interactor** coordinates with Entity, **DataStore** and **Webservices** and passes the data in a plain object to the Presenter through **OutputBoundary**. The Presenter implements **OutputBoundary** protocol. Both **Interactor** and **Presenter** use the data structure **OutputData**.

3. **Data flow from **Presenter** to **View****

The **Presenter** formats the data received from **Interactor** in the form of **ViewModel** which represents information needed to be displayed in the view. This does not contain any business rule.

## Clean Architecture for iOS
Let's consider the data flow among various components of the Clean Architecture in iOS domain. In Clean Architecture, the how data flow is unidirectional like this:

**Controller -> Interactor -> Presenter -> View**

But in case of iOS, it becomes little difficult follow this. This is because, in iOS, the responsibilities of a **Controller** and a **View** are handled by **ViewController**. A ViewController receives user inputs/events as well as renders appropriate views. Hence we have the following variants of clean architecture in iOS.

1. **VIP**: Proposed by [Raymond Law](https://twitter.com/rayvinly)
   * Info: https://clean-swift.com/clean-swift-ios-architecture/
2. **VIPER**: Proposed by Jeff Gilbert and [Conrad Stoll](https://twitter.com/conradstoll)
   * Info: https://www.objc.io/issues/13-architecture/viper/

These architectures differ in the followings ways:
1. How data flow occurs among View, Presenter and Interactor 
2. How navigation from one scene to other is handled.

## **VIP**

[[https://github.com/raywenderlich/SC_SusmitaHorrow/blob/master/Images/VIP.png | width = 700px ]]

In this architecture flow of data occurs as **ViewController -> Interactor -> Presenter -> ViewController**

Initially, it may seem a circle reference is created, but here Dependency Inversion is applied. So if you closely observe the diagram, you will see there is no directed cycle.

Here the **ViewController** invokes **Interactor** through **InputBoundary**. **InputBoundary** is an interface which is implemented by the **Interactor**. Upon finishing data processing, **Interactor** passes data to **OutoutBoundary** in form of **OutputData**. Again the **OutputBoundary** is an interface which is implemented by the **Presenter**. Finally the **Presenter** passes the data in the form of **ViewModel** to **PresenterOutputBoundary**. The **ViewController** implements **PresenterOutputBoundary**.

## **VIPER**

[[https://github.com/raywenderlich/SC_SusmitaHorrow/blob/master/Images/VIPER.png | width = 700px ]]



Here the data flow occurs as follows:

**ViewController <-----> Presenter <-----> Interactor**

Here we have four major interfaces:
1. **PresenterOutputBoundary**: Implemented by **ViewController**. **Presenter** calls this after finishing data formatting for view.
2. **PresenterInputBoundary**: Implemented by **Presenter**. **ViewController** calls this whenever an user action triggers.
3. **InteractorOutputBoundary**: Implemented by **Presenter**. **Interactor** calls this whenever data fetch is done.
4. **InteractorInputBoundary**: Implemented by **Interactor**. **Presenter** calls this when new data request is triggered from the **ViewController**.
                            
VIP is closer to clean architecture implementation in term of data flow. Whereas VIPER takes care of the proper separation of view and business logic by making **Presenter** responsible for coordination.

[[https://raw.githubusercontent.com/swiftingio/blog/%2324-Architecture-Wars/Images/VIP.png | width = 400px]]        [[https://raw.githubusercontent.com/swiftingio/blog/%2324-Architecture-Wars/Images/VIPER.png | width = 400px]]

## **VIPER Simplified**

In this sample project, I have demonstrated an Event-Command based VIPER architecture which makes use of powerful swift enums. The basic architecture is as follows:

[[https://github.com/raywenderlich/SC_SusmitaHorrow/blob/master/Images/VIPER%20-%20Modified.png | width = 700px]]

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

## Reference
1. **Clean Architecture: A Craftsman's Guide to Software Structure and Design (Robert C. Martin Series)** 
2. https://swifting.io/blog/2016/09/07/architecture-wars-a-new-hope/
3. https://medium.com/@piyush.dez/ios-architectures-5a19cd56edc2
