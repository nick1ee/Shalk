//
//  TextFieldExtensions.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/23.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
//swiftlint:disable identifier_name
private var __maxLengths = [UITextField: Int]()

extension UITextField {

    @IBInspectable var maxLength: Int {

        get {

            guard let l = __maxLengths[self] else {

                return 150 // (global default-limit. or just, Int.max)

            }

            return l

        }

        set {

            __maxLengths[self] = newValue

            addTarget(self, action: #selector(fix), for: .editingChanged)

        }

    }

    func fix(textField: UITextField) {

        let t = textField.text

        textField.text = t?.safelyLimitedTo(length: maxLength)

    }

}

extension String {

    func safelyLimitedTo(length n: Int) -> String {

        let c = self.characters

        if (c.count <= n) { return self }

        return String( Array(c).prefix(upTo: n) )

    }

}
//swiftlint:enable identifier_name
