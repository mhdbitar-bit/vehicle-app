//
//  VehicleCellController.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import UIKit

final class VehicleCellController {
    private let model: Point
    private let borderCoordinate: Coordinate
    
    init(model: Point, borderCoordinate: Coordinate) {
        self.model = model
        self.borderCoordinate = borderCoordinate
    }
    
    func view(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VehicleTableViewCell.ID) as! VehicleTableViewCell
        cell.vehicleTypeLabel.text = model.type
        cell.latitudeLabel.text = "\(model.coordinate.latitude)"
        cell.longitudeLabel.text = "\(model.coordinate.longitude)"
        cell.distanceLabel.text = CoreLocationHelpers.calculateDistanceBetween(borderCoordinate, model.coordinate)
        return cell
    }
}
