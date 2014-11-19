//
//  ViewController.swift
//  BoxifyMyBoxes
//
//  Created by Daryl Lu on 11/18/14.
//  Copyright (c) 2014 Daryl Lu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.boxify()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func boxify() {
        var box1 = [2, 7, 4]
        var box2 = [8, 10, 3]
        var box3 = [5, 4, 10]
        var box4 = [2, 2, 2]
        
        var allBoxes = NSMutableArray()
        allBoxes.addObjectsFromArray([box1, box2, box3, box4])
        var volumeOfAllBoxes = 0
        
        var allWidths = Array<Double>()
        var allDepths = Array<Double>()
        var allHeights = Array<Double>()
        var allSurfaceAreas = Array<Int>() // Later in the loop, to use MAX, must look at Ints only -- does not work for Double
        for boxes in allBoxes {
            var box = boxes as Array<Double>
            box.sort { $1 < $0 }
            allWidths.append(box[0])
            allDepths.append(box[1])
            allHeights.append(box[2])
            volumeOfAllBoxes += Int(box[0]) * Int(box[1]) * Int(box[2])
            allSurfaceAreas.append(Int(box[0] * box[1])) // Later in the loop, to use MAX, must look at Ints only -- does not work for Double
        }
        
        var sortedWidths = allWidths
        var sortedDepths = allDepths
        sortedWidths.sort { $1 < $0 }
        sortedDepths.sort { $1 < $0 }
        
        var containerWidth = sortedWidths[0]
        var containerDepth = sortedDepths[0]
        var containerHeight = 0
        
        while (allWidths.count > 0) {

            var boxPlaced = Int()
            var boxesDetailsArray = NSMutableArray()
            
            var boxSurfaceAreas = Array<Int>()
            var boxHeights = Array<Int>()
            // Find the maximum surface area out from the allSurfaceAreas array
            let maxSurfaceArea = allSurfaceAreas.reduce(Int.min, combine: { max($0, $1) })

            // Find all of the inner boxes that have surface areas equal to the MAX surface area. If the inner box matches, then add to the boxSurfaceAreas array the index (box number) and the inner box's height to the boxHeights array
            for innerBox in 0..<allWidths.count {
                if  maxSurfaceArea == allSurfaceAreas[innerBox] {
                    boxSurfaceAreas.append(innerBox)
                    boxHeights.append(Int(allHeights[innerBox]))
                }
            }
            
            // Find the minimum height of the boxes that have surface areas equal to the largest surface area. Iterate through the boxSurfaceAreas array till the height of the box at the right index matches with the minimum height. When found, take the box's index and save it into boxPlaced as the index value of the box that should be placed first
            let minHeight = boxHeights.reduce(Int.max, combine: { min($0, $1) })
            for boxToPlace in 0..<boxSurfaceAreas.count {
                if minHeight == boxHeights[boxToPlace] {
                    boxPlaced = boxSurfaceAreas[boxToPlace]
                    break
                }
            }
            // Increment the containerHeight with the box's height
            containerHeight += Int(allHeights[boxPlaced])
            
            var container1WidthToPass = containerWidth - allWidths[boxPlaced]
            var container1DepthToPass = containerDepth
            var container1HeightToPass = allHeights[boxPlaced]
            
            var container2WidthToPass = containerWidth
            var container2DepthToPass = containerDepth - allDepths[boxPlaced]
            var container2HeightToPass = allHeights[boxPlaced]
            
            // Remove the height of the box that was just added
            allWidths.removeAtIndex(boxPlaced)
            allDepths.removeAtIndex(boxPlaced)
            allHeights.removeAtIndex(boxPlaced)
            allSurfaceAreas.removeAtIndex(boxPlaced)
            
            if (container1WidthToPass > 0) {
                boxesDetailsArray = self.recursiveBoxification(allWidths, allDepths: allDepths, allHeights: allHeights, allSurfaceAreas: allSurfaceAreas, containerWidth: container1WidthToPass, containerDepth: container1DepthToPass, containerHeight: container1HeightToPass)
                allWidths = boxesDetailsArray.objectAtIndex(0) as Array
                allDepths = boxesDetailsArray.objectAtIndex(1) as Array
                allHeights = boxesDetailsArray.objectAtIndex(2) as Array
                allSurfaceAreas = boxesDetailsArray.objectAtIndex(3) as Array
            }
            
            if (container2DepthToPass > 0) {
                boxesDetailsArray = self.recursiveBoxification(allWidths, allDepths: allDepths, allHeights: allHeights, allSurfaceAreas: allSurfaceAreas, containerWidth: container2WidthToPass, containerDepth: container2DepthToPass, containerHeight: container2HeightToPass)
                allWidths = boxesDetailsArray.objectAtIndex(0) as Array
                allDepths = boxesDetailsArray.objectAtIndex(1) as Array
                allHeights = boxesDetailsArray.objectAtIndex(2) as Array
                allSurfaceAreas = boxesDetailsArray.objectAtIndex(3) as Array
            }
        }
        var volumeOfContainer = Int(containerWidth) * Int(containerDepth) * containerHeight
        println("Volume of container is: \(volumeOfContainer) measuring \(containerWidth) x \(containerDepth) x \(containerHeight)")
        println("Volume of all boxes contained within \(volumeOfAllBoxes)")
        
    }
    
    func recursiveBoxification(allWidths: Array<Double>, allDepths: Array<Double>, allHeights: Array<Double>, allSurfaceAreas: Array<Int>, containerWidth: Double, containerDepth: Double, containerHeight: Double) -> NSMutableArray {
        var boxesDetailsArray = NSMutableArray()
        var boxesVolume = Array<Int>()
        var boxPlaced = Int()
        
        var newAllWidths = allWidths
        var newAllDepths = allDepths
        var newAllHeights = allHeights
        var newAllSurfaceAreas = allSurfaceAreas
        
        var containerDims = [containerWidth, containerDepth, containerHeight]// Could actually pass these into a single array earlier and passed into this func as a single array parameter
        
        for i in 0..<allWidths.count {
            if (allWidths[i] <= containerWidth && allDepths[i] <= containerDepth && allHeights[i] <= containerHeight) {
                boxesVolume.append(Int(allWidths[i] * allDepths[i] * allHeights[i]))
            } else {
                boxesVolume.append(0)
            }
        }
        let maxVolume = boxesVolume.reduce(Int.min, combine: { max($0, $1) })
        
        for i in 0..<boxesVolume.count {
            if (maxVolume == boxesVolume[i]) {
                boxPlaced = i
                break
            }
        }
        
        var container1WidthToPass = containerWidth - allWidths[boxPlaced]
        var container1DepthToPass = containerDepth
        var container1HeightToPass = containerHeight
        
        var container2WidthToPass = containerWidth
        var container2DepthToPass = containerDepth - allDepths[boxPlaced]
        var container2HeightToPass = containerHeight
        
        newAllWidths.removeAtIndex(boxPlaced)
        newAllDepths.removeAtIndex(boxPlaced)
        newAllHeights.removeAtIndex(boxPlaced)
        newAllSurfaceAreas.removeAtIndex(boxPlaced)
        
        boxesDetailsArray.addObject(newAllWidths)
        boxesDetailsArray.addObject(newAllDepths)
        boxesDetailsArray.addObject(newAllHeights)
        boxesDetailsArray.addObject(newAllSurfaceAreas)
        
        if (container1WidthToPass > 0 && newAllWidths.count > 0) {
            boxesDetailsArray = self.recursiveBoxification(newAllWidths, allDepths: newAllDepths, allHeights: newAllHeights, allSurfaceAreas: newAllSurfaceAreas, containerWidth: container1WidthToPass, containerDepth: container1DepthToPass, containerHeight: container1HeightToPass)
            newAllWidths = boxesDetailsArray.objectAtIndex(0) as Array
            newAllDepths = boxesDetailsArray.objectAtIndex(1) as Array
            newAllHeights = boxesDetailsArray.objectAtIndex(2) as Array
            newAllSurfaceAreas = boxesDetailsArray.objectAtIndex(3) as Array
        }
        
        if (container2DepthToPass > 0 && newAllWidths.count > 0) {
            boxesDetailsArray = self.recursiveBoxification(newAllWidths, allDepths: newAllDepths, allHeights: newAllHeights, allSurfaceAreas: newAllSurfaceAreas, containerWidth: container2WidthToPass, containerDepth: container2DepthToPass, containerHeight: container2HeightToPass)
            newAllWidths = boxesDetailsArray.objectAtIndex(0) as Array
            newAllDepths = boxesDetailsArray.objectAtIndex(1) as Array
            newAllHeights = boxesDetailsArray.objectAtIndex(2) as Array
            newAllSurfaceAreas = boxesDetailsArray.objectAtIndex(3) as Array
        }
        
        return boxesDetailsArray
    }

}

