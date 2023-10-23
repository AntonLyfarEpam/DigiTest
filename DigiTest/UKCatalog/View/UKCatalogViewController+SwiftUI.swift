//
//  UKCatalogViewController+SwiftUI.swift
//  DigiTest
//
//  Created by Anton Lyfar on 22.10.2023.
//

import SwiftUI

struct UKCatalogView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    func makeUIViewController(context: Context) -> some UIViewController {
        let catalogStoryboard = UIStoryboard(name: "UKCatalog", bundle: nil)
        let viewController = catalogStoryboard.instantiateViewController(withIdentifier: "Catalog")

        return viewController
    }
}
