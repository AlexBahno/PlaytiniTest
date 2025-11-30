//
//  GameViewController.swift
//  PlaytiniTest
//
//  Created by Alexandr Bahno on 29.11.2025.
//

import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        self.view = SKView()
        self.view.bounds = UIScreen.main.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            scene.onGameOver = { [weak self] timeElapsed in
                self?.handleGameOver(timeElapsed: timeElapsed)
            }
            
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }
    }
    
    func handleGameOver(timeElapsed: TimeInterval) {
        let result = GameResult(date: Date(), timeElapsed: timeElapsed)
        ScoreManager.shared.saveResult(result)
        
        let timeString = String(format: "%.2f", timeElapsed)
        
        let alert = UIAlertController(title: "Game Over",
                                      message: "You lasted: \(timeString) seconds",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Menu", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
