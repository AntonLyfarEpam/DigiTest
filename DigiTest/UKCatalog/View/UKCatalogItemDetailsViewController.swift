//
//  UKCatalogItemDetailsViewController.swift
//  DigiTest
//
//  Created by Anton Lyfar on 22.10.2023.
//

import UIKit

class UKCatalogItemDetailsViewController: UIViewController {
    var item: UKCatalogViewModel.Item?

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var confidenceLabel: UILabel!

    private var dataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Details"
        if let item {
            textLabel.text = item.text
            idLabel.text = item.id
            confidenceLabel.text = "\(item.confidence)"
            loadImage(with: item.image)
        }
    }

    @IBAction private func close(_ sender: Any) {
        dismiss(animated: true)
    }

    private func loadImage(with url: URL?) {
        guard let url else { return }

        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }

            DispatchQueue.main.async { [weak self] in
                self?.imageView?.image = image
            }
        }

        dataTask?.resume()
    }
}
