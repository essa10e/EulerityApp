//
//  UivewExtension.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/9/21.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return self.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
}
