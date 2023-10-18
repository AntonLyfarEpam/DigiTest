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
            VStack {
                ForEach(viewModel.items) { item in
                    HStack {
                        AsyncImage(url: item.image) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            default:
                                ProgressView()
                            }
                        }
                        .frame(width: 150, height: 80)
                        .cornerRadius(10)
                        .clipped()

                        VStack(alignment: .leading) {
                            Text(item.text)
                            Spacer()
                            Text(String(format: "Confidence: %.2f", item.confidence))
                        }.padding()

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .refreshable {
            viewModel.refresh()
        }
    }
}

#Preview {
    CatalogView()
}
