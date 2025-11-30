//
//  ScoreManager.swift
//  PlaytiniTest
//
//  Created by Alexandr Bahno on 29.11.2025.
//

import Foundation

struct GameResult: Codable {
    let date: Date
    let timeElapsed: TimeInterval
}

class ScoreManager {
    static let shared = ScoreManager()
    private let key = "game_results"
    
    func saveResult(_ result: GameResult) {
        var results = getResults()
        results.append(result)
        
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func getResults() -> [GameResult] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let results = try? JSONDecoder().decode([GameResult].self, from: data) else {
            return []
        }
        return results.sorted { $0.timeElapsed > $1.timeElapsed }
    }
}
