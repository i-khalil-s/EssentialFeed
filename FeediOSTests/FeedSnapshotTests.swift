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
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOOADING_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOOADING_light")
    }
    
    // MARK: Helpers
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyBoard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyBoard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
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
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map{ stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return CellController(cellController, cellController, cellController)
        }
        
        display(cells)
    }
}

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotsWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .available),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: .medium),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 2),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ])
        )
    }
}

private final class SnapshotsWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }
    
    func snapshot() -> UIImage {
        let rendered = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return rendered.image { action in
            layer.render(in: action.cgContext)
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
