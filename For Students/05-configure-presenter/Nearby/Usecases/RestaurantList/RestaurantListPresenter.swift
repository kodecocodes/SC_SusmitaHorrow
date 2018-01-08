///// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

class RestaurantListPresenter {
	let restaurantListInteractor: RestaurantListInteractorProtocol
	weak var listener: RestaurantListPresenterListenerProtocol? = nil
	weak var scenePresenter: ScenePresenter? = nil
	private var list: [Restaurant] = []

	init(interactor: RestaurantListInteractorProtocol) {
		self.restaurantListInteractor = interactor
	}
}

extension RestaurantListPresenter: RestaurantListInteractorListenerProtocol {
	func handle(response: RestaurantListInteractorResponse) {
		switch response {
		case .didFetchNearbyRestaurant(let result):
			handleRestaurantsReceived(result: result)
		}
	}

	private func handleRestaurantsReceived(result: ServiceResult<SuggestedRestaurants>) {
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
}

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
}
