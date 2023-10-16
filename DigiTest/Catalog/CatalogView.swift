//
//  CatalogView.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import SwiftUI

struct CatalogView: View {
    @StateObject
    private var viewModel = CatalogViewModel()

    var body: some View {
        Color.red
            .onAppear {
                viewModel.f()
            }
    }
}
