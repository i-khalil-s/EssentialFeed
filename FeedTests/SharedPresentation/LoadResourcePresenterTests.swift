//
//  LoadResourcePresenterTests.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 01/05/22.
//

import XCTest
import Feed

class LoadResourcePresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoadingWithError_displaysLocalizedErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoading_displays() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        let resource = "resource"
        
        sut.didFinishLoading(with: resource)
        
        XCTAssertEqual(view.messages, [
            .display(resource: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    //MARK: Helpers
    private func makeSUT(
        mapper: @escaping LoadResourcePresenter.Mapper = { _ in "any"},
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LoadResourcePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter(resourceView: view, errorView: view, loadingView: view, mapper: mapper)
        
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing Localized string for key: \(key) in table \(table).", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: ErrorView, FeedLoadingView, ResourceView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resource: String)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resource: viewModel))
        }
    }
}
