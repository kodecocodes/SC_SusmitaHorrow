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

import UIKit

class RestaurantListViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	var presenter: RestaurantListPresenterProtocol!
	private var viewModels: [RestaurantViewModel] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureTableView()
		presenter.handle(event: .viewDidLoad)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	private func configureTableView() {
		let nib = UINib(nibName: "RestaurantTableViewCell", bundle: Bundle.main)
		tableView.register(nib, forCellReuseIdentifier: "RestaurantTableViewCell")
		tableView.dataSource = self
		tableView.delegate = self
	}
}

extension RestaurantListViewController: StoryboardInstantiable {
	static var storyboardName: String {
		return "Main"
	}
}

extension RestaurantListViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModels.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell", for: indexPath) as! RestaurantTableViewCell
		cell.configure(model: self.viewModels[indexPath.row])
		return cell
	}
}

extension RestaurantListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.presenter.handle(event: .didTapOnRestaurant(index: indexPath.row))
	}
}

extension RestaurantListViewController: RestaurantListCommandListenerProtocol {
	func handle(command: RestaurantListPresenterCommand) {
		switch command {
		case .populateList(let viewModels):
			self.viewModels = viewModels
			tableView.reloadData()
		case .showError(let title, let message):
			break
		}
	}
}

extension RestaurantListViewController: ScenePresenter {
	func present(viewController: UIViewController) {
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}
