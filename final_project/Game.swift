//
//  Game.swift
//  final_project
//
//  Created by Hitesh Bhatia on 12/6/17.
//  Copyright © 2017 Hitesh Bhatia. All rights reserved.
//

import Foundation

class Game {
    
    var delegate : GameDelegate?
    
    let playerCooldown = 0.3
    let playerPower = 1
    var playerHealth = 10 {
        didSet{
            delegate?.healthChanged()
        }
    }
    
    var lastTimePlayerShot : TimeInterval = 0
    
    func startShooting() -> Bool {
        let currTime = Date().timeIntervalSince1970
        if(currTime - lastTimePlayerShot > playerCooldown){
            lastTimePlayerShot = currTime
            return true
        }
        return false
    }
    
    var alienCount = 0
    let alienFreq = 60
    let alienProb : UInt32 = 3
    
    let maximumNumberOfAliens = 20
    let alienLaser = 2
    let alienHealth = 5
    
    var decisionFlag : Bool?
    
    var finalScore = 10
    
    var score = 0 {
        didSet{
            delegate?.scoreChanged()
        }
    }
    
    func alienCount(numAliens: Int) -> Alien?{ // Decides whether an alien should be spawned
        guard numAliens < maximumNumberOfAliens else { return nil }
        alienCount += 1
        if(alienCount == alienFreq){
            alienCount = 0
            if(arc4random_uniform(alienProb) == 0){
                return Alien(alienHealth: 1, power: 1, laserFreq: 60, laserRatioHigh: 10, laserRatioLow: 2, type: .alien1)
            }
        }
        return nil
    }
}

protocol GameDelegate {
    
    func scoreChanged()
    func healthChanged()
}
