//
//  CoinTableViewCell.swift
//  CryptoRate
//
//  Created by Viktor Golovach on 24.08.2023.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet private weak var coinNameLabel: UILabel!
    @IBOutlet private weak var coinSymbolLabel: UILabel!
    @IBOutlet private weak var coinPriceLabel: UILabel!
    @IBOutlet private weak var coinPercentLabel: UILabel!
    
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.coinSymbolLabel.layer.cornerRadius = self.coinSymbolLabel.frame.height / 2
        self.coinSymbolLabel.layer.masksToBounds = true
    }
   
    func configure(with coin: CryptoData) {
        let floatPrice = Float(coin.priceUsd)
        let floatPercent = Float(coin.changePercent24Hr)
        self.coinNameLabel.text = coin.name
        self.coinPriceLabel.text = "\(String(format:"%.02f", floatPrice ?? 0))$"
        self.coinSymbolLabel.text = "  \(coin.symbol)  "
        
        floatPercent ?? 0 < 0
        ? setNegativePercentLabel(with: floatPercent ?? 0)
        : setPositivePercent(with: floatPercent ?? 0)
        
    }
    
    private func setPositivePercent(with percent: Float) {
        self.coinPercentLabel.text = "24h ↑ \(String(format:"%.02f", percent))%"
        self.coinPercentLabel.textColor = .systemGreen
    }
    
    private func setNegativePercentLabel(with percent: Float) {
        self.coinPercentLabel.text = "24h ↓ \(String(format:"%.02f", percent))%"
        self.coinPercentLabel.textColor = .systemPink
    }
    
}
