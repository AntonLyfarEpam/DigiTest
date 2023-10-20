//
//  CatalogViewModelTests.swift
//  DigiTestUnitTests
//
//  Created by Anton Lyfar on 20.10.2023.
//

import Combine
@testable import DigiTest

import XCTest

final class CatalogViewModelTests: XCTestCase {
    var sut: CatalogViewModel!
    private var catalogRepositoryMock: CatalogRepositoryMock!
    private let retrieveItemsPublisher = PassthroughSubject<[CatalogItemEntity], Never>()
    private var subscribers: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()

        catalogRepositoryMock = CatalogRepositoryMock(subject: retrieveItemsPublisher, onRetrieveCall: nil)
        sut = CatalogViewModel(with: catalogRepositoryMock)
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
        subscribers = []
    }

    func test_ThatItemsEmitting() throws {
        let expectation = XCTestExpectation(description: "items emitted")
        let input = testInput
        var output = [CatalogViewModel.Item]()

        sut.$items
            .dropFirst()
            .sink {
                output = $0
                expectation.fulfill()
            }
            .store(in: &subscribers)

        XCTAssert(output.isEmpty)

        retrieveItemsPublisher.send(input)
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(output.count, input.count)
        XCTAssertEqual(output.first?.id, input.first?.id)
        XCTAssertEqual(output.first?.text, input.first?.text)
        XCTAssertEqual(output.first?.image, input.first?.image)
        XCTAssertEqual(output.first?.confidence, input.first?.confidence)
        XCTAssertEqual(output.last?.id, input.last?.id)
        XCTAssertEqual(output.last?.text, input.last?.text)
        XCTAssertEqual(output.last?.image, input.last?.image)
        XCTAssertEqual(output.last?.confidence, input.last?.confidence)
    }

    func test_ThatIsLoadingEnablesOnRefresh() {
        let expectation = XCTestExpectation(description: "items emitted")
        let input = testInput
        var isLoading = false

        sut.$isLoading
            .dropFirst()
            .sink { isLoading = $0 }
            .store(in: &subscribers)

        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscribers)

        XCTAssertFalse(isLoading)
        sut.refresh()
        XCTAssert(isLoading)
        retrieveItemsPublisher.send(input)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(isLoading)
    }

    func test_ThatItemsRetrievesInitiallyWithoutRefresh() {
        catalogRepositoryMock = CatalogRepositoryMock(
            subject: retrieveItemsPublisher,
            onRetrieveCall: {
                XCTAssertFalse($0.refresh)
            }
        )

        sut = CatalogViewModel(with: catalogRepositoryMock)
    }

    func test_ThatItemsRetrievesWithRefresh() {
        var expectation: XCTestExpectation?
        var output = false

        catalogRepositoryMock = CatalogRepositoryMock(
            subject: retrieveItemsPublisher,
            onRetrieveCall: {
                output = $0.refresh
                expectation?.fulfill()
            }
        )

        sut = CatalogViewModel(with: catalogRepositoryMock)

        expectation = XCTestExpectation(description: "retrieveItems was called")
        sut.refresh()

        wait(for: [expectation!], timeout: 1)
        XCTAssert(output)
    }

    func test_ThatLastItemShownRetrievesItemsWithLastItemId() {
        let expectation = XCTestExpectation(description: "items emitted")
        let input = testInput
        var output: String?

        catalogRepositoryMock = CatalogRepositoryMock(
            subject: retrieveItemsPublisher,
            onRetrieveCall: { output = $0.maxId }
        )

        sut = CatalogViewModel(with: catalogRepositoryMock)
        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscribers)

        retrieveItemsPublisher.send(input)
        wait(for: [expectation], timeout: 1)

        sut.lastItemShown()

        XCTAssertNotNil(output)
        XCTAssertEqual(output, input.last?.id)
    }
}

private extension CatalogViewModelTests {
    var testInput: [CatalogItemEntity] {
        [
            .init(id: "1", text: "1", image: nil, confidence: 0.1),
            .init(id: "2", text: "2", image: nil, confidence: 0.2)
        ]
    }
}

private struct CatalogRepositoryMock: CatalogRepository {
    struct Parameters {
        let maxId: String?
        let refresh: Bool
    }

    let subject: PassthroughSubject<[CatalogItemEntity], Never>
    let onRetrieveCall: ((Parameters) -> Void)?

    func retrieveItems(maxId: String?, refresh: Bool) -> AnyPublisher<[CatalogItemEntity], Never> {
        onRetrieveCall?(Parameters(maxId: maxId, refresh: refresh))
        return subject.eraseToAnyPublisher()
    }
}
