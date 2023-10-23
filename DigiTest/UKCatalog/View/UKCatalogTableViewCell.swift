//
//  UKCatalogTableViewCell.swift
//  DigiTest
//
//  Created by Anton Lyfar on 22.10.2023.
//

import UIKit

class UKCatalogTableViewCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!

    private var dataTask: URLSessionDataTask?

    override func prepareForReuse() {
        super.prepareForReuse()

        imgView.image = nil
        dataTask?.cancel()
    }

    func loadImage(with url: URL?) {
        guard let url else { return }

        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }

            DispatchQueue.main.async { [weak self] in
                self?.imgView?.image = image
            }
        }
        
        dataTask?.resume()
    }
}
