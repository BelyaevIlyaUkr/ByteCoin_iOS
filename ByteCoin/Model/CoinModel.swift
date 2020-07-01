import Foundation

struct CoinModel {
    let currency: String
    let price: Double
    
    var formattedPrice: String {
        return String(format: "%.2f",price)
    }
}
