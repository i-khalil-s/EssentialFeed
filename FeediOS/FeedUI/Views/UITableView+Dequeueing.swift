//
//  UITableView+Dequeueing.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 08/02/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing:  T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
