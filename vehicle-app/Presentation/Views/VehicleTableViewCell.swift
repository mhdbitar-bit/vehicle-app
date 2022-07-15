//
//  VehicleTableViewCell.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import UIKit

final class VehicleTableViewCell: UITableViewCell {
    
    @IBOutlet var stateImage: UIImageView!
    @IBOutlet private(set) var vehicleImage: UIImageView!
    @IBOutlet private(set) var vehicleTypeLabel: UILabel!
    @IBOutlet private(set) var latitudeLabel: UILabel!
    @IBOutlet private(set) var longitudeLabel: UILabel!
    @IBOutlet private(set) var northEastDistanceLabel: UILabel!
    @IBOutlet var southWestboundDistanceLabel: UILabel!
    
    static let ID = "VehicleTableViewCell"
}
