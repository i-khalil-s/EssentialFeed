//
//  UIImage+ImageData.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 30/03/22.
//

import UIKit
import XCTest

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension XCTestCase {
    func anyImageData(withColor color: UIColor = .red) -> Data {
        UIImage.make(withColor: color).pngData()!
    }

    func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot, file: file, line: line)
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at \(snapshotURL). Use `record` method to store a snapshot b efore asserting", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporalySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporalySnapshotURL)
            
            XCTFail("Snapshots does not match stored one. New snapshot URL: \(temporalySnapshotURL), stored snapshot: \(storedSnapshotData)")
        }
    }

    func record(snapshot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot, file: file, line: line)
        
        var snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL,
                withIntermediateDirectories: true
            )
            snapshotURL = snapshotURL.appendingPathComponent("\(named).png")
            
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Snapshot recorded, please use `assert` to compare the images", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    func makeSnapshotData(snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate a PNG representation", file: file, line:  line)
            return nil
        }
        return snapshotData
    }

}
