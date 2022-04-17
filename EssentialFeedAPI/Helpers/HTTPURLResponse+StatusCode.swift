//
//  HTTPURLResponse+StatusCode.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 22/03/22.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
