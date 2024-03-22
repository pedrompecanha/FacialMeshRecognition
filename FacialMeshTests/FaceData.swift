//
//  FaceData.swift
//  FacialMeshTests
//
//  Created by Pedro Peçanha on 21/03/24.
//

import Foundation
import ARKit

struct FaceData {
    var points: [Int:SCNVector3] = [:]
    
    func getDistance(faceInfo: [Int:SCNNode]) -> Double? {
        let maxDistance = 100
        
        guard !points.isEmpty else { return nil }
        
        var savedFace = centralizeFace(faceInfo: points)
        
        var sentFace = centralizeFace(faceInfo: faceInfo.mapValues({$0.position}))
        
//        savedFace = normalizeFace(faceInfo: savedFace)
//        sentFace = normalizeFace(faceInfo: sentFace)
        
        
//        var currentDistance: Double = 0.0
//        for (key, value) in sentFace {
//            let xDistance = abs(savedFace[key]!.x - value.x)
//            let yDistance = abs(savedFace[key]!.y - value.y)
//            let zDistance = abs(savedFace[key]!.z - value.z)
//            
//            currentDistance += Double (xDistance + yDistance + zDistance)
//            
//        }
        
        
        var currentDistance: Double = euclidianDistance(savedFace, sentFace)
        
//        print("RESULTS:")
        print(currentDistance)
//        print("\(currentDistance)/\(maxDistance)")
        
        let percentage = (1 - (currentDistance/Double(maxDistance))) * 100
        
//        print(String(format: "test percentage: %.2f%%", arguments: [percentage]))
        
        return currentDistance
    }
    
    func centralizeFace(faceInfo: [Int:SCNVector3]) -> [Int:SCNVector3] {
        
        var face = faceInfo
        
        let xCenterOfNose = -1 * (points[127]!.x + points[576]!.x) / 2
        let yCenterOfNose = -1 * (points[127]!.y + points[576]!.y) / 2
        
        for key in face.keys {
            face[key]!.x += xCenterOfNose
            face[key]!.y += yCenterOfNose
        }
        
        return face
    }
    
    func normalizeFace(faceInfo: [Int:SCNVector3]) -> [Int:SCNVector3] {
        let biggestX = faceInfo.values.max(by: {$0.x < $1.x})!.x
        let smallestX = faceInfo.values.max(by: {$0.x > $1.x})!.x
        let biggestY = faceInfo.values.max(by: {$0.y < $1.y})!.y
        let smallestY = faceInfo.values.max(by: {$0.y > $1.y})!.y
        let biggestZ = faceInfo.values.max(by: {$0.z < $1.z})!.z
        let smallestZ = faceInfo.values.max(by: {$0.z > $1.z})!.z
        
//        let normalizedValue = (originalValue - minValue) / (maxValue - minValue)

        
        var normalizedFace: [Int:SCNVector3] = [:]
        
        for key in faceInfo.keys {
            
            let originalX = faceInfo[key]!.x
            let originalY = faceInfo[key]!.y
            let originalZ = faceInfo[key]!.z

            normalizedFace[key] = SCNVector3(
                (originalX - smallestX) / (biggestX - smallestX),
                (originalY - smallestY) / (biggestY - smallestY),
                (originalZ - smallestZ) / (biggestZ - smallestZ)
            )
        }
//        print("biggestX = \(biggestX)")
//        print("smallestX = \(smallestX)")
//        print("biggestY = \(biggestY)")
//        print("smallestY = \(smallestY)")
//        print("biggestZ = \(biggestZ)")
//        print("smallestZ = \(smallestZ)")
        
        return normalizedFace

        

    }
    
    

}


func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func length(_ vector: SCNVector3) -> Float {
    return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
}

func l2distance(_ dict1: [Int: SCNVector3], _ dict2: [Int: SCNVector3]) -> Double {
    let squaredDifferences = zip(dict1, dict2).flatMap { (entry1, entry2) in
        let (_, vec1) = entry1
        let (_, vec2) = entry2
        return pow(Double(length(vec2 - vec1)), 2)
    }
    let sumOfSquaredDifferences = squaredDifferences.reduce(0, +)
    return sqrt(sumOfSquaredDifferences)
}

func euclidianDistance(_ face1: [Int: SCNVector3], _ face2: [Int: SCNVector3]) -> Double {
    
    var totalDifference: Double = 0.0
    
    for key in face1.keys {

        let zDiff = pow(face1[key]!.z - face2[key]!.z, 2)
        let xDiff = pow(face1[key]!.x - face2[key]!.x, 2)
        let yDiff = pow(face1[key]!.y - face2[key]!.y, 2)
        
        totalDifference += Double(sqrt(zDiff + xDiff + yDiff))
    }
    return totalDifference
}
