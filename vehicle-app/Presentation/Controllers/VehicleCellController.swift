//
//  VehicleCellController.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import UIKit

final class VehicleCellController {
    private let model: Point
    
    init(model: Point) {
        self.model = model
    }
    
    func view(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VehicleTableViewCell.ID) as! VehicleTableViewCell
        cell.vehicleTypeLabel.text = model.type
        cell.latitudeLabel.text = "\(model.coordinate.latitude)"
        cell.longitudeLabel.text = "\(model.coordinate.longitude)"
        cell.northEastDistanceLabel.text = CoreLocationHelpers.calculateDistanceBetween(northEastCoordinate, model.coordinate)
        cell.southWestboundDistanceLabel.text = CoreLocationHelpers.calculateDistanceBetween(southWeastCoordinate, model.coordinate)
        
        if model.state == .active {
            cell.stateImage.image = UIImage(systemName: "checkmark.circle.fill")
            cell.stateImage.tintColor = .systemGreen
        } else {
            cell.stateImage.image = UIImage(systemName: "xmark.circle.fill")
            cell.stateImage.tintColor = .systemRed
        }
        

        return cell
    }
}
