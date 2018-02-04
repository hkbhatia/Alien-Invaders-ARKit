//
//  ViewController.swift
//  final_project
//
//  Created by Hitesh Bhatia on 12/4/17.
//  Copyright © 2017 Hitesh Bhatia. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit
import ReplayKit

struct BulletValues {
    static let pBullet = 0
    static let eBullet = 1
    static let directEnemy = 2
}

enum LaserOwner  {
    case playerLaser
    case enemyLaser
}

class ViewController: UIViewController, GameDelegate{

    @IBOutlet var sceneView : ARSCNView!
    var aliens = [AlienNode]()
    var lasers = [Laser]()
    var game = Game()
    
    // Next 3 variables define how the score and such should be displayed on the screen
    
    lazy var pStyle : NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        return style
    }()
    
    lazy var strAttr : [NSAttributedStringKey : Any] = [.strokeColor : UIColor.black, .strokeWidth : -5, .foregroundColor: UIColor.white, .font : UIFont.systemFont(ofSize: 18, weight: .bold), .paragraphStyle : pStyle]
    
    lazy var mainAttr : [NSAttributedStringKey : Any] = [.strokeColor : UIColor.black, .strokeWidth : -5, .foregroundColor: UIColor.white, .font : UIFont.systemFont(ofSize: 45, weight: .bold), .paragraphStyle : pStyle]
    
    // Nodes for the scene itself
    var scoreLabel : SKLabelNode!
    var livesLabel : SKLabelNode!
    var decisionLabel : SKLabelNode!
    var radarLabel : SKShapeNode!
    
    let topSpace : CGFloat = 24
    let sideSpace : CGFloat = 6
    
    
    var isRecording = false // Used to toggle screen recording
    
    
    //MARK: GameDelegate Functions
    
    func scoreChanged() {
        scoreLabel.attributedText = NSMutableAttributedString(string: "Score: \(game.score)", attributes: strAttr)
        if game.score >= game.finalScore {
            game.decisionFlag = true
            showFinish()
        }
    }
    
    func healthChanged() {
        livesLabel.attributedText = NSAttributedString(string: "Health: \(game.playerHealth)", attributes: strAttr)
        if game.playerHealth <= 0 {
            game.decisionFlag = false
            showFinish()
        }
    }

    
    //MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createScene()
        setupGestureRecognizers()
        game.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureScene()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //Mark: UI Setup
    
    private func createScene(){
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self as SCNPhysicsContactDelegate
        sceneView.overlaySKScene = SKScene(size: sceneView.bounds.size)
        sceneView.overlaySKScene?.scaleMode = .resizeFill
        setupLabels()
        setupRadar()
    }
    
    private func configureScene(){
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
    }
    
    private func setupGestureRecognizers(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        tapRecognizer.numberOfTouchesRequired = 1
        
        sceneView.addGestureRecognizer(tapRecognizer)

    }
    
    private func setupRadar(){
        let size = sceneView.bounds.size
        
        radarLabel = SKShapeNode(circleOfRadius: 50)
        radarLabel.position = CGPoint(x: (size.width - 50) - sideSpace, y: 60 + sideSpace)
        radarLabel.strokeColor = .black
        radarLabel.glowWidth = 3
        radarLabel.fillColor = .white
        sceneView.overlaySKScene?.addChild(radarLabel)
        
        for i in (1...3){
            let ring = SKShapeNode(circleOfRadius: CGFloat(i * 10))
            ring.strokeColor = .black
            ring.glowWidth = 0.2
            ring.name = "Ring"
            ring.position = radarLabel.position
            sceneView.overlaySKScene?.addChild(ring)
        }
        
        for _ in (0..<(game.maximumNumberOfAliens)){
            let blip = SKShapeNode(circleOfRadius: 4)
            blip.fillColor = .blue
            blip.strokeColor = .clear
            blip.alpha = 0
            radarLabel.addChild(blip)
        }
        
    }
    
    private func setupLabels(){
        let size = sceneView.bounds.size
        
        scoreLabel = SKLabelNode(attributedText: NSAttributedString(string: "Score: \(game.score)", attributes: strAttr))
        livesLabel = SKLabelNode(attributedText: NSAttributedString(string: "Health: \(game.playerHealth)", attributes: strAttr))
        decisionLabel = SKLabelNode(text: "Default")
        decisionLabel.alpha = 0
        
        
        scoreLabel.position = CGPoint(x: (size.width - scoreLabel.frame.width/2) - sideSpace, y: (size.height - scoreLabel.frame.height) - topSpace)
        livesLabel.position = CGPoint(x: sideSpace + livesLabel.frame.width/2, y: (size.height - livesLabel.frame.height) - topSpace )
        decisionLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        
        sceneView.overlaySKScene?.addChild(scoreLabel)
        sceneView.overlaySKScene?.addChild(livesLabel)
        sceneView.overlaySKScene?.addChild(decisionLabel)
    }
    
    private func showFinish(){
        guard let hasWon = game.decisionFlag else { return }
        decisionLabel.alpha = 1
        decisionLabel.attributedText = NSAttributedString(string: hasWon ? "Player Wins!" : "Aliens Win!", attributes: mainAttr)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.performSegue(withIdentifier: "homeScreen", sender: self)
        })
    }
    
    //Mark: UI Gesture Actions
    
    @objc func handleTap(recognizer: UITapGestureRecognizer){
        if game.startShooting() {
            laserFired(fromNode: sceneView.pointOfView!, type: .playerLaser)
        }
    }
    
    func laserFired(fromNode node: SCNNode, type: LaserOwner){
        guard game.decisionFlag == nil else { return }
        let currentPos = sceneView.pointOfView!
        var target: SCNVector3
        var changedPos: SCNVector3
        var aim : SCNVector3
        switch type {
            
        case .enemyLaser:
            // If enemy, shoot in the direction of the player
            target = SCNVector3Make(0, 0, 0.05)
            changedPos = node.convertPosition(target, to: nil)
            aim = currentPos.position - node.position
        default:
            // If player, shoot straight ahead
            target = SCNVector3Make(0, 0, -0.05)
            changedPos = node.convertPosition(target, to: nil)
            aim = changedPos - currentPos.position
        }
        
        let laser = Laser(start: changedPos, aim: aim, type: type)
        lasers.append(laser)
        sceneView.scene.rootNode.addChildNode(laser.node)
    }
    
    private func addAlien(alien: Alien){
        let currentPos = sceneView.pointOfView!
        let y = (Float(arc4random_uniform(60)) - 29) * 0.01 // Random Y Value between -0.3 and 0.3
        
        //Random X and Z value around the circle
        let xRad = ((Float(arc4random_uniform(361)) - 180)/180) * Float.pi
        let zRad = ((Float(arc4random_uniform(361)) - 180)/180) * Float.pi
        let length = Float(arc4random_uniform(6) + 4) * -0.3
        let x = length * sin(xRad)
        let z = length * cos(zRad)
        let target = SCNVector3Make(x, y, z)
        let actualPosition = currentPos.convertPosition(target, to: nil)
        let alien = AlienNode(alien: alien, position: actualPosition, cameraPosition: currentPos.position)
        
        aliens.append(alien)
        sceneView.scene.rootNode.addChildNode(alien.node)
    }
    
}

//MARK: Scene Physics Contact Delegate

extension ViewController : SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let maskA = contact.nodeA.physicsBody!.contactTestBitMask
        let maskB = contact.nodeB.physicsBody!.contactTestBitMask
        
        switch(maskA, maskB){
        case (BulletValues.directEnemy, BulletValues.pBullet):
            hitAlien(bullet: contact.nodeB, enemy: contact.nodeA)
        case (BulletValues.pBullet, BulletValues.directEnemy):
            hitAlien(bullet: contact.nodeA, enemy: contact.nodeB)
        default:
            break
        }
    }
    
    func hitAlien(bullet: SCNNode, enemy: SCNNode){
        bullet.removeFromParentNode()
        enemy.removeFromParentNode()
        game.score += 1
    }
}

//MARK: AR SceneView Delegate
extension ViewController : ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard game.decisionFlag == nil else { return }
        
        if let alien = game.alienCount(numAliens: aliens.count){
            addAlien(alien: alien)
        }
        
        for (i, alien) in aliens.enumerated().reversed() {
            
            guard alien.node.parent != nil else {
                aliens.remove(at: i)
                continue
            }
            
            // Move alien closer to where they need to go
            if alien.move(towardsPosition: sceneView.pointOfView!.position) == false {
                // If move function returned false, assume a crash and remove alien from world.
                alien.node.removeFromParentNode()
                aliens.remove(at: i)
                game.playerHealth -= alien.alien.alienHealth
            }else {
                
                if alien.alien.shouldFire() {
                    laserFired(fromNode: alien.node, type: .enemyLaser)
                }
            }
        }
        
        // Draw aliens on the radar as an XZ Plane
        for (i, blip) in radarLabel.children.enumerated() {
            if i < aliens.count {
                let alien = aliens[i]
                blip.alpha = 1
                let relativePosition = sceneView.pointOfView!.convertPosition(alien.node.position, from: nil)
                var x = relativePosition.x * 10
                var y = relativePosition.z * -10
                if x >= 0 { x = min(x, 35) } else { x = max(x, -35)}
                if y >= 0 { y = min(y, 35) } else { y = max(y, -35)}
                blip.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
            }else{
                blip.alpha = 0
            }
            
        }
        
        for (i, laser) in lasers.enumerated().reversed() {
            if laser.node.parent == nil {
                // If laser is no longer in the world, remove it from our list
                lasers.remove(at: i)
            }
            // Move the lasers and remove if necessary
            if laser.changePosition() == false {
                laser.node.removeFromParentNode()
                lasers.remove(at: i)
            }else{
                // Check for a hit against the player
                 print(laser.node.position.distance(vector: sceneView.pointOfView!.position))
                if laser.node.physicsBody?.contactTestBitMask == BulletValues.eBullet
                    && laser.node.position.distance(vector: sceneView.pointOfView!.position) < 0.03{
                    laser.node.removeFromParentNode()
                    lasers.remove(at: i)
                    game.playerHealth -= 1
                }
            }
        }
    }
    
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            print("Camera Not Available")
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                print("Camera Tracking State Limited Due to Excessive Motion")
            case .initializing:
                print("Camera Tracking State Limited Due to Initalization")
            case .insufficientFeatures:
                print("Camera Tracking State Limited Due to Insufficient Features")
                
            }
        case .normal:
            print("Camera Tracking State Normal")
        }
    }
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("Session Failed with error: \(error.localizedDescription)")
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session Interrupted")
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session no longer being interrupted")
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
