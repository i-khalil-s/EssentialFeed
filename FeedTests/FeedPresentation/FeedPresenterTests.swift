//
//  FeedPresenterTests.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/03/22.
//

import Foundation
import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

protocol ErrorView {
    func display(errorMessage: FeedErrorViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
    
    private let errorView: ErrorView
    private let loadingView: FeedLoadingView
    
    internal init(errorView: ErrorView, loadingView: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        errorView.display(errorMessage: .noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displayNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    //MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, loadingView: view)
        
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private class ViewSpy: ErrorView, FeedLoadingView {
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(errorMessage: FeedErrorViewModel) {
            messages.append(.display(errorMessage: errorMessage.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
}
