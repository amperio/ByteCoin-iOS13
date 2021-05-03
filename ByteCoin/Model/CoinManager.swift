//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func getCoinData(_ coinManager: CoinManager, coinModel: CoinModel)
    func manageError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "10E2A7F1-388E-4F64-9947-F6950311C808"
    // https://rest.coinapi.io/v1/exchangerate/BTC/EUR?apikey=10E2A7F1-388E-4F64-9947-F6950311C808
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        performRequest(for: baseURL + "/\(currency)?apikey=" + apiKey)
    }
    
    func performRequest(for urlString: String) {
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    delegate?.manageError(error: error!)
                    return
                }
                if let data = data{
                    if let newCoinObject = self.getJASON(data){
                        self.delegate?.getCoinData(self, coinModel: newCoinObject)
                    }
                }
            }.resume()
        }
    }
    
    func getJASON(_ data: Data) -> CoinModel? {
        do{
            let jsModel = try JSONDecoder().decode(CoinJASONmodel.self, from: data)
            let asset_id_base = jsModel.asset_id_base
            let asset_id_quote = jsModel.asset_id_quote
            let rate = jsModel.rate
            return CoinModel(rate: rate, asset_id_quote: asset_id_quote, asset_id_base: asset_id_base)
        }
        catch let error{
            delegate?.manageError(error: error)
            return nil
        }
    }
}
