//
//  HTTPURLResponse+codeInit.swift
//  EssentialFeedAPITests
//
//  Created by Sergio Khalil Bello Garcia on 01/05/22.
//

import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
