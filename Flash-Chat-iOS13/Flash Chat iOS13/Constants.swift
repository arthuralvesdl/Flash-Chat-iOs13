import UIKit
struct K {
    static let appName = "⚡ Flash Chat"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let registerSegue = "RegisterToChat"
    static let loginSegue = "LoginToChat"
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
        static let darkGray = UIColor(red: 85/255, green: 116/255, blue: 128/255, alpha: 255/255)
        static let dark = UIColor(red: 42/255, green: 51/255, blue: 20/255, alpha: 255/255)
        static let lightGreen = UIColor(red: 43/255, green: 255/255, blue: 244/255, alpha: 255/255)
    }
    
    struct FStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
    }
}
