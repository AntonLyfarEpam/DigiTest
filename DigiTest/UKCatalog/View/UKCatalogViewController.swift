//
//  UKCatalogViewController.swift
//  DigiTest
//
//  Created by Anton Lyfar on 21.10.2023.
//

import UIKit

private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, UKCatalogViewModel.Item>
private typealias DataSource = UITableViewDiffableDataSource<Int, UKCatalogViewModel.Item>

class UKCatalogViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private lazy var viewModel = UKCatalogViewModel(onUpdate: update)
    private lazy var dataSource = DataSource(tableView: tableView, cellProvider: cellProvider)

    private var didSelectRowHandler: (IndexPath) -> Void = { _ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.refresh()
    }

    func update(items: [UKCatalogViewModel.Item]) {
        refreshControl.endRefreshing()

        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)

        didSelectRowHandler = { [weak self] indexPath in
            let row = indexPath.row
            if row < items.count {
                self?.showDetails(with: items[row])
            }
        }
    }

    private func cellProvider(
      tableView: UITableView,
      for indexPath: IndexPath,
      item: UKCatalogViewModel.Item
    )
      -> UKCatalogTableViewCell?
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "UKCatalogTableViewCell",
            for: indexPath
        ) as? UKCatalogTableViewCell

        cell?.idLabel.text = item.id
        cell?.txtLabel.text = item.text
        cell?.confidenceLabel.text = "\(item.confidence)"
        cell?.loadImage(with: item.image)

        return cell
    }

    private func showDetails(with item: UKCatalogViewModel.Item) {
        let catalogStoryboard = UIStoryboard(name: "UKCatalog", bundle: nil)
        let viewController = catalogStoryboard.instantiateViewController(withIdentifier: "Details")

        if
            let navigationController = viewController
                as? UINavigationController,
            let detailsViewController = navigationController.topViewController
                as? UKCatalogItemDetailsViewController
        {
            detailsViewController.item = item
        }

        present(viewController, animated: true)
    }

    @objc private func refresh() {
        viewModel.refresh()
    }
}

extension UKCatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            viewModel.lastItemShown()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowHandler(indexPath)
    }
}
