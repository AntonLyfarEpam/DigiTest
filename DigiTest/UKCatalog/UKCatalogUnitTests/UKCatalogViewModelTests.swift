//
//  UKCatalogViewModelTests.swift
//  DigiTestUnitTests
//
//  Created by Anton Lyfar on 23.10.2023.
//

@testable import DigiTest

import XCTest

final class UKCatalogViewModelTests: XCTestCase {
    var sut: UKCatalogViewModel!
    private var catalogRepositoryMock: UKCatalogRepositoryMock!

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    func test_ThatUpdatingWithItems() throws {
        let expectation = XCTestExpectation(description: "items updated")
        let input = testInput
        var output = [UKCatalogViewModel.Item]()
        var outputMaxID: String? = ""
        var outputRefresh: Bool?

        catalogRepositoryMock = UKCatalogRepositoryMock(onRequestCall: { maxID, refresh in
            outputMaxID = maxID
            outputRefresh = refresh
            return input
        })

        sut = UKCatalogViewModel(
            with: catalogRepositoryMock,
            onUpdate: { items in
                output = items
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(output.count, input.count)
        XCTAssertNil(outputMaxID)
        XCTAssertFalse(outputRefresh ?? true)
        XCTAssertEqual(output.first?.id, input.first?.id)
        XCTAssertEqual(output.first?.text, input.first?.text)
        XCTAssertEqual(output.first?.image, input.first?.image)
        XCTAssertEqual(output.first?.confidence, input.first?.confidence)
        XCTAssertEqual(output.last?.id, input.last?.id)
        XCTAssertEqual(output.last?.text, input.last?.text)
        XCTAssertEqual(output.last?.image, input.last?.image)
        XCTAssertEqual(output.last?.confidence, input.last?.confidence)
    }

    func test_ThatItemsRetrievesWithRefresh() {
        let expectation = XCTestExpectation(description: "items updated")
        let input = testInput
        var outputRefresh = false

        catalogRepositoryMock = UKCatalogRepositoryMock(onRequestCall: { _, refresh in
            outputRefresh = refresh
            return input
        })

        sut = UKCatalogViewModel(
            with: catalogRepositoryMock,
            onUpdate: { _ in
                expectation.fulfill()
            }
        )

        sut.refresh()

        wait(for: [expectation], timeout: 1)
        XCTAssert(outputRefresh)
    }

    func test_ThatLastItemShownRetrievesItemsWithLastItemId() {
        let expectation = XCTestExpectation(description: "items updated")
        let input = testInput
        var output: String?

        catalogRepositoryMock = UKCatalogRepositoryMock(onRequestCall: { maxID, refresh in
            output = maxID
            return input
        })

        sut = UKCatalogViewModel(
            with: catalogRepositoryMock,
            onUpdate: { _ in
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1)

        sut.lastItemShown()

        XCTAssertNotNil(output)
        XCTAssertEqual(output, input.last?.id)
    }
}

private extension UKCatalogViewModelTests {
    var testInput: [CatalogItemEntity] {
        [
            .init(id: "1", text: "1", image: nil, confidence: 0.1),
            .init(id: "2", text: "2", image: nil, confidence: 0.2)
        ]
    }
}

private struct UKCatalogRepositoryMock: UKCatalogRepository {
    struct Parameters {
        let maxId: String?
        let refresh: Bool
    }

    let onRequestCall: ((String?, Bool) -> [CatalogItemEntity])

    func requestItems(
        maxId: String?,
        refresh: Bool,
        completion: @escaping ([CatalogItemEntity]) -> Void
    ) {
        completion(onRequestCall(maxId, refresh))
    }
}
