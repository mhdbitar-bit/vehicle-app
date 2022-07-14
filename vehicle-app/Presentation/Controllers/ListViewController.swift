//
//  ListViewController.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import UIKit
import Combine

final class ListViewController: UITableViewController, Alertable {
    private var viewModel: ListViewModel!
    private var borderCoorindate: Coordinate!
    private var cancellables: Set<AnyCancellable> = []
    
    private var points = [Point]() {
        didSet { tableView.reloadData() }
    }
    
    convenience init(viewModel: ListViewModel, borderCoorindate: Coordinate) {
        self.init()
        self.viewModel = viewModel
        self.borderCoorindate = borderCoorindate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.title
        tableView.register(UINib(nibName: VehicleTableViewCell.ID, bundle: nil), forCellReuseIdentifier: VehicleTableViewCell.ID)
        setupRefreshControl()
        bind()
        
        if tableView.numberOfRows(inSection: 0) == 0 {
            refresh()
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        viewModel.loadPoints()
    }
    
    private func bind() {
        bindLoading()
        bindError()
        bindItems()
    }
    
    private func bindLoading() {
        viewModel.$isLoading.sink { [weak self] isLoading in
            if isLoading {
                self?.refreshControl?.beginRefreshing()
            } else {
                self?.refreshControl?.endRefreshing()
            }
        }.store(in: &cancellables)
    }
    
    private func bindItems() {
        viewModel.$points.sink { [weak self] points in
            guard let self = self else { return }
            self.points = points
        }.store(in: &cancellables)
    }
    
    private func bindError() {
        viewModel.$error.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: error)
            }
        }.store(in: &cancellables)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return VehicleCellController(model: points[indexPath.row], borderCoordinate: borderCoorindate).view(tableView)
    }
}
