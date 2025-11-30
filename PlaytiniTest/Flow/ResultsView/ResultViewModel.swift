//
//  ResultViewModel.swift
//  PlaytiniTest
//
//  Created by Alexandr Bahno on 30.11.2025.
//

import Foundation
import Combine

final class ResultViewModel {
    
    @Published private(set) var results: [GameResult]
    
    init() {
        self.results = ScoreManager.shared.getResults()
    }
}
