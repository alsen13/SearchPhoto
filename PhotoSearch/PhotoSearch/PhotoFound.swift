//
//  PhotoFound.swift
//  PhotoSearch
//
//  Created by admin on 6/8/19.
//  Copyright © 2019 Alexey Sen. All rights reserved.
//

import Foundation
import RealmSwift

class PhotoFound: Object {
    @objc dynamic var image: Data? = nil
    @objc dynamic var title: String = ""
}
