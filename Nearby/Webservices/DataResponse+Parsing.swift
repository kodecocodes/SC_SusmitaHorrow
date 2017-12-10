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
import Alamofire
import Marshal

extension DataResponse {
	func parseError() -> ApplicationError {
		do {
			let json = try JSONParser.JSONObjectWithData(data!)
			do {
				print("Got Error from server = \(json.debugDescription))")
				let errorResponse = try APIError(object: json)
				return errorResponse
			} catch (let error) {
				print("Error while parsing error: \(error)")
				return ServerError(message: "Wrong Error Format")
			}
		} catch (let error) {
			print("Error while serializing error: \(error)")
			return ServerError(message: "Response Serialization Error")
		}
	}

	func parseData() -> Result<JSONObject> {
		do {
			let object = try JSONParser.JSONObjectWithData(self.data!)
			print("JSON to parse: \(String(describing: object))")
			return Result.success(object)

		} catch {
			if let parsingError = error as? MarshalError {
				print(parsingError.description)
			}
			return Result.failure(parseError())
		}
	}
}
