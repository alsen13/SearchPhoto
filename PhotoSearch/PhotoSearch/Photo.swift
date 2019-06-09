//
//  Photo.swift
//  PhotoSearch
//
//  Created by admin on 6/8/19.
//  Copyright © 2019 Alexey Sen. All rights reserved.
//

import Foundation

struct Photo: Codable {
    var results: [PhotoImage]
}

struct PhotoImage: Codable {
    var urls: ImagesSize
}

struct ImagesSize: Codable {
    var regular: String
}
