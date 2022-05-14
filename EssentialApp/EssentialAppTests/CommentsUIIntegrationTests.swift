//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 11/05/22.
//

import Foundation
import XCTest
import Feed
import FeediOS
import EssentialApp
import Combine

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTile)
        
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReaload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedReaload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a thrid loading request once user initiates another load")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
    
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed successfully")
        
        sut.simulateUserInitiatedReaload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a load")
    
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is not completed")
    }
    
    func test_loadCommentsCompletion_renderSuccessfullyLoadedComments() {
        let comment0 = makeComments(message: "A comment", userName: "A name")
        let comment1 = makeComments(message: "Another comment", userName: "Another name")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReaload()
        loader.completeCommentsLoading(with: [comment1], at: 1)
        assertThat(sut, isRendering: [comment1])
        
    }
    
    func test_loadCommentCompletion_renderSuccessfullyEmptyCommentAfterNoEmptyComment() {
        let comment0 = makeComments()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReaload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
        
    }
    
    func test_loadCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComments()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment], at: 0)
        
        sut.simulateUserInitiatedReaload()
        loader.completeCommentsLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [comment])
        
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let expectation = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ListViewController, hasViewConfiguredFor comment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.commentView(at: index)
        
        guard let cell = view as? ImageCommentCell else {
            return XCTFail("Expected \(ImageCommentCell.self) instance, but got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let viewModel = ImageCommentsPresenter.map([comment]).comments.first
        
        XCTAssertEqual(cell.messageText, viewModel?.comment, "Expected `descriptionText` to be \(String(describing: comment.message)) for comment at \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.userNameText, viewModel?.name, "Expected `userNameText` to be \(String(describing: comment.userName)) for comment at \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.dateText, viewModel?.date, "Expected `dateText` to be \(String(describing: viewModel?.date)) for comment at \(index)", file: file, line: line)
    }
    
    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        guard sut.numberOfRenderedFeedImageViews() == comments.count else {
            return XCTFail("Expected \(comments.count) coments count, but got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index)
        }
    }
    
    private func makeComments(message: String = "", userName: String = "") -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: Date(), userName: userName)
    }
    
    private class LoaderSpy {
        
        private var requests: [PassthroughSubject<[ImageComment], Error>] = []
        var loadCommentsCallCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}

