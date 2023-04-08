//
//  LocationsDataService.swift
//  profileui
//
//  Created by Admin on 05/04/2023.
//

import Foundation
import MapKit

class LocationsDataService {
    
    static let locations: [Location] = [
        Location(
            name: "UMT",
            cityName: "HCM",
            coordinates: CLLocationCoordinate2D(latitude: 10.7744675, longitude: 106.7986732),
            description: "Trường đại học đầu tiên tại Cát Lái chuẩn bị khai giảng năm học mới",
            imageNames: ["truong-dai-hoc-cat-lai-10"],
            link: "https://blog.houze.vn/blog/truong-dai-hoc-dau-tien-tai-cat-lai-chuan-bi-khai-giang-nam-hoc-moi"
        ),
    ]
    
}
