//
//  SharedLocalizationTestHelpers.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/05/22.
//

import XCTest
import Feed

class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

func assertLocalizedKeysAndValuesExists(in presentationBundle: Bundle, _ table: String, file: StaticString = #file, line: UInt = #line) {
    let localizationBundles = allLocalizationBundles(in: presentationBundle, file: file, line: line)
    let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table, file: file, line: line)
    
    localizationBundles.forEach { (bundle, localization) in
        localizedStringKeys.forEach { key in
            let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
            
            if localizedString == key {
                let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                XCTFail("Missing Localized string in language \(language) for key: \(key) in table \(table).", file: file, line: line)
            }
        }
    }
}
     
typealias LocalizedBundle = (bundle: Bundle, localization: String)

     func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
         return bundle.localizations.compactMap { localization in
             guard
                 let path = bundle.path(forResource: localization, ofType: "lproj"),
                 let localizedBundle = Bundle(path: path)
             else {
                 XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                 return nil
             }

             return (localizedBundle, localization)
         }
     }

    func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
         return bundles.reduce([]) { (acc, current) in
             guard
                 let path = current.bundle.path(forResource: table, ofType: "strings"),
                 let strings = NSDictionary(contentsOfFile: path),
                 let keys = strings.allKeys as? [String]
             else {
                 XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                 return acc
             }

             return acc.union(Set(keys))
         }
     }
