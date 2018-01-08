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
import Marshal

public struct AnyError: Swift.Error {
	public let baseError: Swift.Error

	public init(_ error: Swift.Error) {
		if let anyError = error as? AnyError {
			self = anyError
		} else {
			self.baseError = error
		}
	}
}

protocol ApplicationError: LocalizedError {
	var title: String { get }
	var debugDescription: String { get }
}

struct InternetError: ApplicationError {
	var title: String {
		return "No Internet!"
	}

	var debugDescription: String {
		return "Internet not working"
	}

	var errorDescription: String? {
		return "Internet seems to be down. Please try again after reconnecting!"
	}
}

struct ParsingError: ApplicationError {
	let error: MarshalError

	init(error: MarshalError) {
		self.error = error
	}

	var title: String {
		return "Error"
	}

	var debugDescription: String {
		return "Parsing Error: \(error.description)"
	}

	var errorDescription: String? {
		return "Something went wrong. Try again!"
	}
}

struct ServerError: ApplicationError {
	var message: String

	init(message: String) {
		self.message = message
	}

	var title: String {
		return "Server Error"
	}

	var debugDescription: String {
		return "Server Error: \(message)"
	}

	var errorDescription: String? {
		return "Something went wrong. Try again!"
	}
}

struct APIError: ApplicationError {
	var title: String {
		return "API Error"
	}

	var debugDescription: String {
		return "Something went wrong."
	}
}

extension APIError: Unmarshaling {
	init(object: MarshaledObject) throws {

	}
}
