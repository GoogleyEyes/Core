//
//  GoogleService.swift
//  GoogleyEyesCore
//
//  Created by Matthew Wyskiel on 4/17/17.
//
//

import Foundation

protocol GoogleService {
    var apiNameInURL: String { get }
    var apiVersionString: String { get }
    init()
}
