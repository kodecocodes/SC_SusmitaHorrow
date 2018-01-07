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
import ReachabilitySwift
import Marshal

typealias RequestCompletionBlock<T> = (ServiceResult<T>) -> ()

class BaseAPIClient {
	private var sessionManager = SessionManager()
	let reachability = Reachability()!
	static let shared = BaseAPIClient()

	func signOut() {
		sessionManager.session.invalidateAndCancel()
		sessionManager = SessionManager()
	}

	@discardableResult func request<Value>(_ resource: Resource<Value>, completionBlock: @escaping RequestCompletionBlock<Value>) -> DataRequest {
		return request(urlRequest: resource.requestRouter.urlRequest()) { result in
			switch result {
			case .success(let dataResponse):
				do {
					let value = try resource.parse(dataResponse)
					completionBlock(ServiceResult.success(value))
				} catch {
					let parsingError = error as! MarshalError
					print(parsingError.description)

					let processedError = ParsingError(error: parsingError)
					completionBlock(ServiceResult.failure(processedError))
				}
			case .failure(let anyError):
				completionBlock(ServiceResult.failure(anyError))
			}
		}
	}

  @discardableResult private func request(urlRequest: URLRequestConvertible, completionBlock: @escaping (ServiceResult<JSONObject>) -> ()) -> DataRequest {
		return sessionManager.request(urlRequest)
			.debugLog()
			.validate(statusCode: 200...299)
			.responseData { [weak self] dataResponse in
				print(dataResponse.debugDescription)
				if dataResponse.error != nil {
					let isReachable = self?.reachability.isReachable ?? false
					let processedError = isReachable ? dataResponse.parseError() : InternetError()
					completionBlock(ServiceResult.failure(processedError))
				} else {
					let result = dataResponse.parseData()
					completionBlock(result)
				}
		}
	}
}

private extension Request {
	func debugLog() -> Self {
		#if DEBUG
			debugPrint(self)
		#endif
		return self
	}
}

