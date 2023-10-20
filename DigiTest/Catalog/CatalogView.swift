//
//  CatalogView.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import SwiftUI

struct CatalogView: View {
    @StateObject private var viewModel = CatalogViewModel()
    @State private var detailedItem: CatalogViewModel.Item?

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.items) { item in
                    ItemView(
                        id: item.id,
                        text: item.text,
                        image: item.image,
                        confidence: item.confidence
                    )
                    .onAppear {
                        if item == viewModel.items.last {
                            viewModel.lastItemShown()
                        }
                    }
                    .onTapGesture {
                        detailedItem = item
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
        .sheet(item: $detailedItem) { item in
            ItemDetailsView(
                id: item.id,
                text: item.text,
                image: item.image,
                confidence: item.confidence
            )
        }
    }
}

private struct ItemView: View {
    let id: String
    let text: String
    let image: URL?
    let confidence: Float

    var body: some View {
        HStack {
            CatalogItemImageView(image: image)
                .frame(width: 150, height: 100)
                .cornerRadius(10)

            CatalogItemDescriptionView(
                id: id,
                text: text,
                confidence: confidence
            )
            .padding()

            Spacer()
        }
        .padding(.horizontal)
    }
}

private struct ItemDetailsView: View {
    let id: String
    let text: String
    let image: URL?
    let confidence: Float

    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?


    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                    CatalogItemImageView(image: image)
                        .frame(height: 300)
                        .padding()

                    HStack {
                        CatalogItemDescriptionView(
                            id: id,
                            text: text,
                            confidence: confidence
                        )
                        .padding()
                        Spacer()
                    }
                    Spacer()
                } else {
                    HStack {
                        CatalogItemImageView(image: image)
                            .frame(width: 300, height: 300)
                            .padding()

                        CatalogItemDescriptionView(
                            id: id,
                            text: text,
                            confidence: confidence
                        )
                        .padding()
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    dismiss()
                }
            )
        }
    }
}

private struct CatalogItemImageView: View {
    let image: URL?

    var body: some View {
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
        .clipped()
    }
}

private struct CatalogItemDescriptionView: View {
    let id: String
    let text: String
    let confidence: Float

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text)
            Text("ID: \(id)")
            Text(String(format: "Confidence: %.2f", confidence))
        }
    }
}

#Preview {
    CatalogView()
}
