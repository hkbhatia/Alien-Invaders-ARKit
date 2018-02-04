//
//  Alien.swift
//  final_project
//
//  Created by Hitesh Bhatia on 12/6/17.
//  Copyright © 2017 Hitesh Bhatia. All rights reserved.
//

import UIKit

enum AlienType {
    case alien1
    case alien2
    case alien3
    
    func getImages() -> (UIImage){
        switch self {
        case .alien1: return (#imageLiteral(resourceName: "alien1"))
        case .alien2: return (#imageLiteral(resourceName: "alien2"))
        case .alien3: return (#imageLiteral(resourceName: "alien1"))
        }
    }
}

class Alien {
    
    var alienHealth : Int
    let alientLaser : Int
    let rewardsPoint : Int
    var laserCount = 0
    let laserFreq : Int
    var laserRatio : Int {
        return medianZone ? laserRatioHigh : laserRatioLow
    }
    private let laserRatioHigh : Int
    private let laserRatioLow : Int
    
    var medianZone = false
    let frontImage : UIImage

    
    init(alienHealth: Int, power: Int, laserFreq: Int, laserRatioHigh: Int, laserRatioLow: Int, type: AlienType){
        
        self.alienHealth = alienHealth
        self.rewardsPoint = alienHealth * 10
        self.alientLaser = power
        self.laserFreq = laserFreq
        self.laserRatioLow = laserRatioLow
        self.laserRatioHigh = laserRatioHigh
        
        let images = type.getImages()
        self.frontImage = images
        
    }
    
    func shouldFire() -> Bool { 
        laserCount += 1
        if(laserCount == laserFreq){
            laserCount = 0
            return arc4random_uniform(UInt32(laserRatio)) == 0
        }
        return false
    }
}
