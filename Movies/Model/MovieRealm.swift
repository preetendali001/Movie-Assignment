//
//  MovieRealm.swift
//  Movies
//
//  Created by Preeten Dali on 22/11/24.
//

import Foundation
import RealmSwift

class MovieRealm: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var posterPath: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
