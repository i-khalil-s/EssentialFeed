//
//  FeedSnapshotTests.swift
//  FeediOSTests
//
//  Created by Sergio Khalil Bello Garcia on 15/04/22.
//

import Foundation
import XCTest
import FeediOS
@testable import Feed

class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "An error message"))
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_ErrorMessage")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOOADING")
    }
    
    // MARK: Helpers
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyBoard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            .init(description: "The East Side Gallery memorial in Berlin-Friedrichshain is a permanent open-air gallery on the longest surviving section of the Berlin Wall in Mühlenstraße.", location: "Mühlenstrasse (Mill Street)\nBerlin, Germany", image: UIImage.make(withColor: .red)),
            .init(description: "Angel de la independencia", location: "Mexico City", image: UIImage.make(withColor: .green))
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            .init(description: nil, location: "Mühlenstrasse (Mill Street)\nBerlin, Germany", image: nil),
            .init(description: nil, location: "Mexico City", image: nil)
        ]
    }
    
    private func record(snapshot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate a PNG representation", file: file, line:  line)
            return
        }
        
        var snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL,
                withIntermediateDirectories: true
            )
            snapshotURL = snapshotURL.appendingPathComponent("\(named).png")
            
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map{ stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        
        display(cells)
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let rendered = UIGraphicsImageRenderer(bounds: view.bounds)
        return rendered.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var controller: FeedImageCellController?
    let viewModel: FeedImageViewModel<UIImage>
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
    
    
}
