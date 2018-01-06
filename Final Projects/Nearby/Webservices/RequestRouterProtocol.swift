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

enum ActionType {
	case get
	case head
	case post
	case put
	case patch
	case delete

	var httpMethod: HTTPMethod {
		switch self {
		case .get:
			return HTTPMethod.get
		case .head:
			return HTTPMethod.head
		case .post:
			return HTTPMethod.post
		case .put:
			return HTTPMethod.put
		case .patch:
			return HTTPMethod.patch
		case .delete:
			return HTTPMethod.delete
		}
	}
}

protocol RequestRouterProtocol {
	var path: String { get }
	var baseUrl: String { get }
	var headers: [String: String] { get }
	var timeoutInterval: TimeInterval { get }
	var parameters: [String: Any]? { get }
	var method: ActionType { get }
}

extension RequestRouterProtocol {
	var urlParameters: [String: Any]? {
		switch method {
		case .post, .patch, .put:
			return nil
		default:
			return parameters
		}
	}

	func urlRequest() -> URLRequestConvertible {
		let urlString = baseUrl + path
		let url =  URL(string: urlString)!
		var mutableURLRequest = URLRequest(url: url)
		mutableURLRequest.httpMethod = method.httpMethod.rawValue
		headers.forEach { mutableURLRequest.setValue($1, forHTTPHeaderField: $0) }
		mutableURLRequest = method.httpMethod.appendHttpBody(for: mutableURLRequest, with: parameters ?? [:])
		let request = try! URLEncoding.default.encode(mutableURLRequest, with: urlParameters)
		return request
	}
}

fileprivate extension HTTPMethod {
	func appendHttpBody(for request: URLRequest, with parameters: [String: Any] = [:]) -> URLRequest {
		var mutableRequest = request
		let params = parameters
		switch self {
		case .post, .patch, .put:
			do {
				mutableRequest.httpBody = try JSONSerialization.data(
					withJSONObject: params,
					options: JSONSerialization.WritingOptions()
				)
			} catch {
				print(error.localizedDescription)
			}
		default:
			break
		}
		return mutableRequest
	}
}
