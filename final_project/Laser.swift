//
//  Laser.swift
//  final_project
//
//  Created by Hitesh Bhatia on 12/6/17.
//  Copyright © 2017 Hitesh Bhatia. All rights reserved.
//

import UIKit
import ARKit

class Laser : SceneNode{
    var start : SCNVector3!
    var aim : SCNVector3!
    var type : LaserOwner
    var node : SCNNode!
    
    init(start: SCNVector3, aim: SCNVector3, type: LaserOwner){
        self.start = start
        self.aim = aim.normalized()
        self.type = type
        self.node = createLaser()
        self.node.position = start
    }
    
    func createLaser() -> SCNNode{
        
        // Creates geometry of a sphere and paints it red
        let geo = SCNSphere(radius: 0.01)
        let mat = SCNMaterial()
        mat.diffuse.contents = type == .playerLaser ? UIColor.blue : UIColor.darkGray
        geo.materials = [mat]
        let sphere = SCNNode(geometry: geo)
        
        sphere.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        sphere.physicsBody?.contactTestBitMask = type == .playerLaser ? BulletValues.pBullet : BulletValues.eBullet
        sphere.physicsBody?.isAffectedByGravity = false
        return sphere
    }
    
    func changePosition() -> Bool{
        self.node.position += aim/60
        if self.node.position.distance(vector: start) > 3 {
            return false
        }
        return true
    }
}
