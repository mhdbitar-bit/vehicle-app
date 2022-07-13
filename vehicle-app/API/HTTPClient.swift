//
//  HTTPClient.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/13/22.
//

import Foundation

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
