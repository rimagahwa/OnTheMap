//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by admin on 04/01/2019.
//  Copyright © 2019 Rima. All rights reserved.
//

import Foundation

struct StudentInformation: Codable {
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: String?
    var updatedAt: String?
}

extension StudentInformation {
    init(mapString: String, mediaURL: String) {
        self.mapString = mapString
        self.mediaURL = mediaURL
    }
}
