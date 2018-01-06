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

struct RestaurantViewModel {
	let name: String
	let address: String
	let rating: String
	let price: String
	let verified: Bool

	init(name: String, address: String, rating: String, price: String, verified: Bool) {
		self.name = name
		self.address = address
		self.rating = rating
		self.price = price
		self.verified = verified
	}

	init(restaurant: Restaurant) {
		self.name = restaurant.name
		self.price = "Price Tier: \(restaurant.price)"
		self.verified = restaurant.verified
		if let rating = restaurant.rating {
			self.rating = "Rating: \(rating)"
		} else {
			self.rating = ""
		}
		if let locationAddress = restaurant.location.address {
			self.address = locationAddress
		} else {
			self.address = restaurant.location.formattedAddress.reduce("", { (result, string) in
				return string.isEmpty ? result : (result + ", " + string)
			})
		}
	}
}


