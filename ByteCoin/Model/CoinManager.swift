import Foundation


protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    
    let apiKey = "D78DF951-47B3-4C3D-93BC-3BE828EC81EC"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","UAH","USD","RUB","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","SEK","SGD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    var coinModel: CoinModel?

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        self.delegate?.didUpdateCoin(self, coin: coin)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let currency = decodedData.asset_id_quote
            let price = decodedData.rate
            let coin = CoinModel(currency: currency, price: price)
            
            return coin
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
