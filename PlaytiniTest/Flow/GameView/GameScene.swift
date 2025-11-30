//
//  GameScene.swift
//  PlaytiniTest
//
//  Created by Alexandr Bahno on 29.11.2025.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1       // 1
    static let car: UInt32 = 0b10         // 2
    static let finish: UInt32 = 0b100     // 4
    static let boundary: UInt32 = 0b1000  // 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Scene properties
    private let player = SKSpriteNode(color: .white, size: CGSize(width: 30, height: 30))
    private let cam = SKCameraNode()
    
    //MARK: - Constants
    private let rowHeight: CGFloat = 60
    private let laneCount = 20
    
    //MARK: - Game`s states
    private var roads: [CGFloat] = []
    private var isGameRunning = true
    private var lastGeneratedRowIndex = 0
    private var startTime: Date?
    private var cameraSpeed: CGFloat = 0.5
    
    // MARK: - Callbacks
    var onGameOver: ((TimeInterval) -> Void)?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        setupCamera()
        setupPlayer()
        setupGestures(view: view)
        
        for _ in 0..<20 {
            spawnNextRow()
        }
        
        startCarSpawner()
        startTime = Date()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameRunning else { return }
        movePlayer(dy: rowHeight)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameRunning else { return }
        
        cam.position.y += cameraSpeed
        
        if cameraSpeed < 4.0 {
            cameraSpeed += 0.0005
        }
        
        let cameraTop = cam.position.y + size.height / 2
        let generationThreshold = CGFloat(lastGeneratedRowIndex) * rowHeight
        
        if cameraTop > generationThreshold - (size.height / 2) {
            spawnNextRow()
            cleanupOldRows()
        }
        
        let cameraBottom = cam.position.y - size.height / 2
        if player.position.y < cameraBottom - 30 {
            gameOver()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        
        if (maskA == PhysicsCategory.player && maskB == PhysicsCategory.car) ||
            (maskB == PhysicsCategory.player && maskA == PhysicsCategory.car) {
            gameOver()
        }
    }
}

// MARK: - Setup
private extension GameScene {
    func setupCamera() {
        self.camera = cam
        addChild(cam)
        cam.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    func setupGestures(view: SKView) {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    func setupPlayer() {
        player.position = CGPoint(x: size.width / 2, y: rowHeight / 2)
        player.zPosition = 10
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.car
        player.physicsBody?.collisionBitMask = PhysicsCategory.boundary
        player.physicsBody?.allowsRotation = false
        
        addChild(player)
    }
}

//MARK: - Spawn Logic
private extension GameScene {
    func spawnNextRow() {
        let rowIndex = lastGeneratedRowIndex
        let yPos = CGFloat(rowIndex) * rowHeight + (rowHeight / 2)
        
        let node = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: rowHeight))
        node.position = CGPoint(x: size.width / 2, y: yPos)
        node.strokeColor = .clear
        node.zPosition = -1
        
        if rowIndex % 2 != 0 {
            node.fillColor = .darkGray
            node.name = "road"
            roads.append(yPos)
        } else {
            node.fillColor = (rowIndex % 2 == 0) ? .systemGreen : .init(red: 0.1, green: 0.6, blue: 0.2, alpha: 1)
            node.name = "grass"
        }
        
        addChild(node)
        lastGeneratedRowIndex += 1
    }
    
    func startCarSpawner() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnCar()
        }
        let waitAction = SKAction.wait(forDuration: 0.6, withRange: 0)
        run(SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction])))
    }
    
    func spawnCar() {
        guard isGameRunning, !roads.isEmpty else { return }
        
        let cameraBottom = cam.position.y - size.height / 2
        let cameraTop = cam.position.y + size.height / 2
        
        let activeRoads = roads.filter { $0 > cameraBottom && $0 < cameraTop + 200 }
        
        guard let randomRoadY = activeRoads.randomElement() else { return }
        
        let globalRowIndex = Int(randomRoadY / rowHeight)
        let directionRight = globalRowIndex % 2 == 0
        
        let car = SKSpriteNode(color: .systemRed, size: CGSize(width: 50, height: 30))
        let spawnX = directionRight ? cam.position.x - size.width : cam.position.x + size.width
        let endX = directionRight ? cam.position.x + size.width : cam.position.x - size.width
        
        car.position = CGPoint(x: spawnX, y: randomRoadY)
        car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
        car.physicsBody?.isDynamic = false
        car.physicsBody?.categoryBitMask = PhysicsCategory.car
        
        addChild(car)
        
        let duration = Double.random(in: 2.0...4.0)
        
        let moveAction = SKAction.moveTo(x: endX, duration: duration)
        let removeAction = SKAction.removeFromParent()
        car.run(SKAction.sequence([moveAction, removeAction]))
    }
}

//MARK: - Player Action
private extension GameScene {
    @objc func handleSwipeDown() {
        guard isGameRunning else { return }
        movePlayer(dy: -rowHeight)
    }
    
    func movePlayer(dy: CGFloat) {
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: dy), duration: 0.1)
        let scaleSeq = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        
        if !player.hasActions() {
            player.run(SKAction.group([moveAction, scaleSeq]))
        }
    }
    
    func movePlayerForward() {
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: rowHeight), duration: 0.1)
        let scaleSeq = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        player.run(SKAction.group([moveAction, scaleSeq]))
    }
}

//MARK: - Helpers
private extension GameScene {
    func cleanupOldRows() {
        let cameraBottom = cam.position.y - size.height
        
        for node in children {
            if (node.name == "road" || node.name == "grass") && node.position.y < cameraBottom - rowHeight {
                if node.name == "road" {
                    if let index = roads.firstIndex(of: node.position.y) {
                        roads.remove(at: index)
                    }
                }
                
                node.removeFromParent()
            }
        }
    }
    
    func gameOver() {
        guard isGameRunning else { return }
        isGameRunning = false
        player.removeAllActions()
        
        if let view = self.view {
            for recognizer in view.gestureRecognizers ?? [] {
                view.removeGestureRecognizer(recognizer)
            }
        }
        
        let survivalTime = Date().timeIntervalSince(startTime ?? Date())
        
        player.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 0.2)))
        player.run(SKAction.scale(to: 0.1, duration: 0.5))
        
        run(SKAction.wait(forDuration: 0.8)) { [weak self] in
            self?.onGameOver?(survivalTime)
        }
    }
}
