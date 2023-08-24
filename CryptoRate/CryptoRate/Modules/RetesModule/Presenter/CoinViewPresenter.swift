//
//  CoinViewPresenter.swift
//  CryptoRate
//
//  Created by Viktor Golovach on 23.08.2023.
//

import Foundation
import Combine

protocol CoinViewProtocol: AnyObject {
    func onContentUpdate(with coins: [CryptoData])
    func onError(with error: Error)
}

protocol CoinViewPresenterProtocol: AnyObject {
    
    init(view: CoinViewProtocol, networkService: NetworkServiceProtocol)
    
    var coinsArray: CurrentValueSubject<[CryptoData], Never>! { get set }
    var requestTimer: Timer.TimerPublisher! {get set}
    
    func fetchCoins()
    
}

class CoinPresenter: CoinViewPresenterProtocol {
    
    var requestTimer: Timer.TimerPublisher!
    var coinsArray: CurrentValueSubject<[CryptoData], Never>!
    private var cancellables = Set<AnyCancellable>()
    
    weak var view: CoinViewProtocol?
    var networkService: NetworkServiceProtocol!
    
    required init(view: CoinViewProtocol, networkService: NetworkServiceProtocol) {
        self.view = view
        self.networkService = networkService
        //init subject
        self.coinsArray = CurrentValueSubject<[CryptoData], Never>([])
        //init request timer
        self.requestTimer = Timer.publish(every: 1, on: .main, in: .default)
        self.setupPublisher()
    }
    
    
    func fetchCoins() {
        //start timer
        requestTimer
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                guard let self = self else {return}
                Task {
                    let response = await self.networkService.fetchPrice()
                    switch response {
                    case .success(let coins):
                        //apply data to publisher
                        self.coinsArray.send(coins)
                    case .failure(let error):
                        self.view?.onError(with: error)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupPublisher() {
        self.coinsArray
            .removeDuplicates()
            .sink(
                receiveCompletion: { completion in
                    print("completion status: \(completion)")
                }, receiveValue: { coins in
                    self.view?.onContentUpdate(with: coins)
                }
            )
            .store(in: &cancellables)
    }
    
    
    
}
