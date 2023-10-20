//
//  CatalogView.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import SwiftUI

struct CatalogView: View {
    @StateObject private var viewModel = CatalogViewModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.items) { item in
                    ItemView(
                        text: item.text,
                        image: item.image,
                        confidence: item.confidence
                    )
                    .onAppear {
                        if item == viewModel.items.last {
                            viewModel.lastItemShown()
                        }
                    }
                }

                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
            }
        }
        .refreshable {
            viewModel.refresh()
        }
    }
}

struct ItemView: View {
    let text: String
    let image: URL?
    let confidence: Float

    var body: some View {
        HStack {
            AsyncImage(url: image) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    ProgressView()
                }
            }
            .frame(width: 150, height: 100)
            .cornerRadius(10)
            .clipped()

            VStack(alignment: .leading) {
                Text(text)
                Spacer()
                Text(String(format: "Confidence: %.2f", confidence))
            }.padding()

            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    CatalogView()
}
