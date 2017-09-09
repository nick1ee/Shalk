//
//  Extensions.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/24.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

extension Int {

    func addLeadingZero() -> String {

        if self < 10 {

            return "0\(self)"

        } else {

            return "\(self)"

        }

    }

}

extension String {

    func addSpacingAndCapitalized() -> String {

        var text = ""

        for character in self.charactersArray {

            text += "\(character.uppercased) "

        }

        return text

    }

    func convertDate() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        guard let date = dateFormatter.date(from: self) else { return "" }

        if Calendar.current.isDateInToday(date) {

            dateFormatter.dateFormat = "a HH:mm"

            dateFormatter.amSymbol = "AM"

            dateFormatter.pmSymbol = "PM"

            return dateFormatter.string(from: date)

        }

        if Calendar.current.isDateInYesterday(date) {

            dateFormatter.dateFormat = "HH:mm"

            return "昨天 \(dateFormatter.string(from: date))"

        } else {

            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

            return dateFormatter.string(from: date)

        }

    }

}

extension String {
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: self)
        
        return result
        
    }
    
}
