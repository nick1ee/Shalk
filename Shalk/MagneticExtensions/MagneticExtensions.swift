import UIKit

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }

    static var red: UIColor {
        return UIColor(red: 250, green: 76, blue: 92)
    }

    static var yellow: UIColor {
        return UIColor(red: 255, green: 189, blue: 0)
    }

    static var green: UIColor {
        return UIColor(red: 44, green: 203, blue: 128)
    }

    static var blue: UIColor {
        return UIColor(red: 114, green: 177, blue: 242)
    }

    static let colors: [UIColor] = [.red, .yellow, .green, .blue]

}

extension UIImage {

    static let languages: [String] = ["english", "chinese", "japanese", "korean"]

}

extension Array {

    func randomItem() -> Element {

        let index = Int(arc4random_uniform(UInt32(self.count)))

        return self[index]

    }

}

extension CGPoint {

    func distance(from point: CGPoint) -> CGFloat {

        return hypot(point.x - x, point.y - y)
    }

}
