//
//  UKCatalogRepositoryTests.swift
//  DigiTestUnitTests
//
//  Created by Anton Lyfar on 23.10.2023.
//

@testable import DigiTest

import XCTest

final class UKCatalogRepositoryTests: XCTestCase {
    var sut: UKCatalogRepository!
    private var catalogServiceMock: UKCatalogServiceMock!
    private var catalogStorageMock: CatalogStorageMock!

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    func test_requestItems_StorageEmpty_StorageUpdated() {
        let input: [CatalogItemResponseModel] = [
            .init(id: "1", text: "1", image: "url1", confidence: 0.1),
            .init(id: "2", text: "2", image: "url2", confidence: 0.2)
        ]
        var storageInput: [CatalogItemDataModel] = []
        var updateOutput = [CatalogItemDataModel]()
        var maxIdOutput: String? = ""
        var output = [CatalogItemEntity]()

        catalogStorageMock = CatalogStorageMock(
            onFetchCall: { storageInput },
            onUpdateCall: {
                updateOutput = $0
                storageInput = $0
                return .itemsUpdated
            }
        )

        catalogServiceMock = UKCatalogServiceMock(onRequestCall: {
            maxIdOutput = $0
            return .success(input)
        })

        sut = UKDefaultCatalogRepository(
            service: catalogServiceMock,
            storage: catalogStorageMock
        )

        sut.requestItems(
            maxId: nil,
            refresh: false,
            completion: { output = $0 }
        )

        XCTAssertNil(maxIdOutput)
        XCTAssertEqual(updateOutput.count, input.count)
        XCTAssertEqual(updateOutput.first?.id, input.first?.id)
        XCTAssertEqual(updateOutput.first?.text, input.first?.text)
        XCTAssertEqual(updateOutput.first?.image, input.first?.image)
        XCTAssertEqual(updateOutput.first?.confidence, input.first?.confidence)
        XCTAssertEqual(updateOutput.last?.id, input.last?.id)
        XCTAssertEqual(updateOutput.last?.text, input.last?.text)
        XCTAssertEqual(updateOutput.last?.image, input.last?.image)
        XCTAssertEqual(updateOutput.last?.confidence, input.last?.confidence)

        XCTAssertEqual(output.count, input.count)
        XCTAssertEqual(output.first?.id, input.first?.id)
        XCTAssertEqual(output.first?.text, input.first?.text)
        XCTAssertEqual(output.first?.image?.absoluteString, input.first?.image)
        XCTAssertEqual(output.first?.confidence, input.first?.confidence)
        XCTAssertEqual(output.last?.id, input.last?.id)
        XCTAssertEqual(output.last?.text, input.last?.text)
        XCTAssertEqual(output.last?.image?.absoluteString, input.last?.image)
        XCTAssertEqual(output.last?.confidence, input.last?.confidence)
    }

    func test_requestItems_StorageNotEmpty_StorageUpdated() {
        let input: [CatalogItemResponseModel] = [
            .init(id: "3", text: "3", image: "ur3", confidence: 0.3),
            .init(id: "4", text: "4", image: "ur4", confidence: 0.4)
        ]

        var storageInput: [CatalogItemDataModel] = [
            .init(id: "1", text: "1", image: "url1", confidence: 0.1),
            .init(id: "2", text: "2", image: "url2", confidence: 0.2)
        ]

        var updateOutput = [CatalogItemDataModel]()
        var maxIdOutput: String? = ""
        var output = [CatalogItemEntity]()

        catalogStorageMock = CatalogStorageMock(
            onFetchCall: { storageInput },
            onUpdateCall: {
                updateOutput = $0
                storageInput += $0
                return .itemsUpdated
            }
        )

        catalogServiceMock = UKCatalogServiceMock(onRequestCall: {
            maxIdOutput = $0
            return .success(input)
        })

        sut = UKDefaultCatalogRepository(
            service: catalogServiceMock,
            storage: catalogStorageMock
        )

        sut.requestItems(
            maxId: nil,
            refresh: false,
            completion: { output = $0 }
        )

        XCTAssertNil(maxIdOutput)
        XCTAssertEqual(updateOutput.count, input.count)
        XCTAssertEqual(updateOutput.first?.id, input.first?.id)
        XCTAssertEqual(updateOutput.first?.text, input.first?.text)
        XCTAssertEqual(updateOutput.first?.image, input.first?.image)
        XCTAssertEqual(updateOutput.first?.confidence, input.first?.confidence)
        XCTAssertEqual(updateOutput.last?.id, input.last?.id)
        XCTAssertEqual(updateOutput.last?.text, input.last?.text)
        XCTAssertEqual(updateOutput.last?.image, input.last?.image)
        XCTAssertEqual(updateOutput.last?.confidence, input.last?.confidence)

        XCTAssertEqual(output.count, storageInput.count)

        input.forEach { model in
            XCTAssert(
                output.contains { entity in
                    entity.id == model.id
                    && entity.text == model.text
                    && entity.image?.absoluteString == model.image
                    && entity.confidence == model.confidence
                }
            )
        }
    }

    func test_requestItems_StorageNotEmpty_StorageNotUpdated() {
        let expectation = XCTestExpectation(description: "items emitted")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        let input: [CatalogItemResponseModel] = [
            .init(id: "1", text: "1", image: "url1", confidence: 0.1),
            .init(id: "2", text: "2", image: "url2", confidence: 0.2)
        ]

        let storageInput: [CatalogItemDataModel] = [
            .init(id: "1", text: "1", image: "url1", confidence: 0.1),
            .init(id: "2", text: "2", image: "url2", confidence: 0.2)
        ]

        var updateOutput = [CatalogItemDataModel]()
        var maxIdOutput: String? = ""
        var output = [CatalogItemEntity]()

        catalogStorageMock = CatalogStorageMock(
            onFetchCall: { storageInput },
            onUpdateCall: {
                updateOutput = $0
                return .noChanges
            }
        )

        catalogServiceMock = UKCatalogServiceMock(onRequestCall: {
            maxIdOutput = $0
            return .success(input)
        })

        sut = UKDefaultCatalogRepository(
            service: catalogServiceMock,
            storage: catalogStorageMock
        )

        sut.requestItems(
            maxId: nil,
            refresh: false,
            completion: {
                output = $0
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(maxIdOutput)

        XCTAssertEqual(output.count, storageInput.count)

        XCTAssertEqual(updateOutput.count, input.count)
        XCTAssertEqual(updateOutput.first?.id, input.first?.id)
        XCTAssertEqual(updateOutput.first?.text, input.first?.text)
        XCTAssertEqual(updateOutput.first?.image, input.first?.image)
        XCTAssertEqual(updateOutput.first?.confidence, input.first?.confidence)
        XCTAssertEqual(updateOutput.last?.id, input.last?.id)
        XCTAssertEqual(updateOutput.last?.text, input.last?.text)
        XCTAssertEqual(updateOutput.last?.image, input.last?.image)
        XCTAssertEqual(updateOutput.last?.confidence, input.last?.confidence)
    }

    func test_requestItems_StorageNotEmpty_StorageNotUpdated_Refresh() {
        let expectation = XCTestExpectation(description: "items emitted")
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true

        let input: [CatalogItemResponseModel] = [
            .init(id: "1", text: "1", image: "url1", confidence: 0.1),
            .init(id: "2", text: "2", image: "url2", confidence: 0.2)
        ]

        let storageInput: [CatalogItemDataModel] = [
            .init(id: "1", text: "1", image: "url1", confidence: 0.1),
            .init(id: "2", text: "2", image: "url2", confidence: 0.2)
        ]

        var updateOutput = [CatalogItemDataModel]()
        var maxIdOutput: String? = ""
        var output = [CatalogItemEntity]()

        catalogStorageMock = CatalogStorageMock(
            onFetchCall: { storageInput },
            onUpdateCall: {
                updateOutput = $0
                return .noChanges
            }
        )

        catalogServiceMock = UKCatalogServiceMock(onRequestCall: {
            maxIdOutput = $0
            return .success(input)
        })

        sut = UKDefaultCatalogRepository(
            service: catalogServiceMock,
            storage: catalogStorageMock
        )

        sut.requestItems(
            maxId: nil,
            refresh: true,
            completion: {
                output = $0
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(maxIdOutput)

        XCTAssertEqual(output.count, storageInput.count)

        XCTAssertEqual(updateOutput.count, input.count)
        XCTAssertEqual(updateOutput.first?.id, input.first?.id)
        XCTAssertEqual(updateOutput.first?.text, input.first?.text)
        XCTAssertEqual(updateOutput.first?.image, input.first?.image)
        XCTAssertEqual(updateOutput.first?.confidence, input.first?.confidence)
        XCTAssertEqual(updateOutput.last?.id, input.last?.id)
        XCTAssertEqual(updateOutput.last?.text, input.last?.text)
        XCTAssertEqual(updateOutput.last?.image, input.last?.image)
        XCTAssertEqual(updateOutput.last?.confidence, input.last?.confidence)
    }
}

private struct UKCatalogServiceMock: UKCatalogService {
    let onRequestCall: ((String?) -> Result<[CatalogItemResponseModel], Error>)

    func requestItems(
        maxId: String?,
        completion: @escaping (Result<[CatalogItemResponseModel], Error>) -> Void
    ) {
        completion(onRequestCall(maxId))
    }
}
