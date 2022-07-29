//
//  GridViewModel.swift
//  GridCollectionView
//
//  Created by Razvan on 7/29/22.
//

import UIKit
import Combine

class GridViewModel {
    
    // MARK: Properties
    var initialCellWidth = 100
    var initialCellHeight: CGFloat = 100
    var numberOfColumns = 0
    var numberOfItems = 7
    let minCellWidth: CGFloat = 50
    let minCellHeight: CGFloat = 50
    var items = CurrentValueSubject<[GridItem], Never>([])
    var itemWidths: [CGFloat] = []
    
    var collectionViewWidth: CGFloat = 0 {
        didSet {
            numberOfColumns = Int(collectionViewWidth) / initialCellWidth
            dynamicWidth = collectionViewWidth / CGFloat(numberOfColumns)
        }
    }
    
    let collectionViewSetupSubject = PassthroughSubject<Void, Never>()
    
    var dynamicWidth: CGFloat = 0 {
        didSet {
            for _ in 0..<self.numberOfItems {
                items.value.append(GridItem.init(width: dynamicWidth, height: initialCellHeight))
            }
            for _ in 0..<self.numberOfColumns {
                itemWidths.append(CGFloat(dynamicWidth))
            }
            collectionViewSetupSubject.send()
        }
    }
    
    // MARK: Methods
    func saveCollectionViewWidth(_ width: CGFloat) {
        if collectionViewWidth == 0 {
            collectionViewWidth = width
        }
    }
    
    func retrieveAxisPointsDifference(firstPoint: CGPoint, secondPoint: CGPoint) -> (CGFloat, CGFloat) {
        let dx = abs(firstPoint.x - secondPoint.x)
        let dy = abs(firstPoint.y - secondPoint.y)
        return (dx, dy)
    }
    
    func refreshItemWidths(indexPathWithPinch: IndexPath, dx: CGFloat) {
        let horizontalIndexWithPinch = indexPathWithPinch.row % numberOfColumns
        let currentWidthAtPinchHorizontalIndex = itemWidths[horizontalIndexWithPinch]
        
        var adjustedWidthAtPinchHorizontalIndex = currentWidthAtPinchHorizontalIndex + dx
        
        let numberOfColumnsOutsidePinch = CGFloat(numberOfColumns - 1)
        let maxAdjustedWidth: CGFloat = collectionViewWidth - minCellWidth * CGFloat(numberOfColumnsOutsidePinch)
        
        adjustedWidthAtPinchHorizontalIndex = max(minCellWidth, min(maxAdjustedWidth, adjustedWidthAtPinchHorizontalIndex))
        itemWidths[horizontalIndexWithPinch] = adjustedWidthAtPinchHorizontalIndex
        
        var adjustedDx = adjustedWidthAtPinchHorizontalIndex - currentWidthAtPinchHorizontalIndex
        let adjustmentValueForOtherItems = adjustedDx / numberOfColumnsOutsidePinch
        let remainingAvailableWidth = collectionViewWidth - adjustedWidthAtPinchHorizontalIndex

        let allWidthsAreValid: () -> Bool = {
            let diff = self.collectionViewWidth - self.itemWidths.reduce(0, +)
            return 0 <= diff && diff < 1.0
            && self.itemWidths.allSatisfy { self.minCellWidth <= $0 && $0 <= maxAdjustedWidth }
        }
        
        var calculated = false
        while !allWidthsAreValid() && abs(adjustedDx) > 0.01 && !calculated {
            var tmp = itemWidths
            itemWidths.enumerated().forEach { index, value in
                if index == horizontalIndexWithPinch { return }
                
                let candidateW = value - adjustmentValueForOtherItems

                if minCellWidth <= candidateW && candidateW <= maxAdjustedWidth {
                    tmp[index] = candidateW
                    adjustedDx = adjustedDx - adjustmentValueForOtherItems
                }
            }
            itemWidths = tmp
            calculated = true
        }
        
        if !allWidthsAreValid() {
            var tmp = itemWidths
            itemWidths.enumerated().forEach { index, value in
                if index == horizontalIndexWithPinch { return }
                tmp[index] = remainingAvailableWidth / numberOfColumnsOutsidePinch
            }
            itemWidths = tmp
        }
    }

    func refreshCollectionView(indexPath: IndexPath, dx: CGFloat, dy:CGFloat) {
        let verticalIndex = indexPath.row / numberOfColumns
        
        var width: CGFloat = dx
        var height: CGFloat = dy
        
        if abs(width) < abs(height) {
            width = 0
        } else {
            height = 0
        }
    
        refreshItemWidths(indexPathWithPinch: indexPath, dx: width)
        
        for index in 0..<items.value.count {
            let gridItem = items.value[index]
            let newWidth = itemWidths[index % numberOfColumns]
            let newHeight = index / numberOfColumns == verticalIndex ? gridItem.height + height : gridItem.height
            
            updateGridItemSize(index: index, width: newWidth, height: max(minCellHeight, newHeight))
        }
        
        items.value = items.value
    }

    func updateGridItemDxDy(indexPath: IndexPath, dx: CGFloat, dy: CGFloat) {
        items.value[indexPath.item].dx = dx
        items.value[indexPath.item].dy = dy
    }
    
    func updateGridItemSize(index: Int, width: CGFloat, height: CGFloat) {
        items.value[index].width = width
        items.value[index].height = height
    }
    
}
