//
//  FieldGridLayout.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import UIKit

protocol FieldGridLayoutDelegate: class {
    func collectionView(rowCountForFieldGrid collectionView: UICollectionView) -> Int
    func collectionView(columnCountForFieldGrid collectionView: UICollectionView) -> Int
    func collectionView(cellDimensionForFieldGrid collectionView: UICollectionView) -> CGFloat
    func collectionView(viewWindowForFieldGrid collectionView: UICollectionView) -> CGRect?
}

extension FieldGridLayoutDelegate {
    func collectionView(rowCountForFieldGrid collectionView: UICollectionView) -> Int {
        return Constants.defaultRows
    }
    
    func collectionView(columnCountForFieldGrid collectionView: UICollectionView) -> Int {
        return Constants.defaultColumns
    }
    
    func collectionView(cellDimensionForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return Constants.defaultCellDimension
    }
    
    func collectionView(cellSpacingForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return Constants.cellSpacing
    }
    
    func collectionView(viewWindowForFieldGrid collectionView: UICollectionView) -> CGRect? {
        return nil
    }
}

class FieldGridLayout: UICollectionViewLayout, FieldGridLayoutDelegate {
    weak var delegate: FieldGridLayoutDelegate?
    
    private var numberOfRows = 0
    private var numberOfColumns = 0
    private var cellDimension: CGFloat = 0
    private var cellSpacing: CGFloat = 0
    
    private var itemAttributesCache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        return (CGFloat(self.numberOfColumns) * (self.cellDimension + self.cellSpacing)) - self.cellSpacing
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        let rowCount = (self.delegate ?? self).collectionView(rowCountForFieldGrid: collectionView)
        let columnCount = (self.delegate ?? self).collectionView(columnCountForFieldGrid: collectionView)
        let cellDimension = (self.delegate ?? self).collectionView(cellDimensionForFieldGrid: collectionView)
        let cellSpacing = (self.delegate ?? self).collectionView(cellSpacingForFieldGrid: collectionView)
        
        // Do nothing; the content has already been cached and nothing has changed on the grid dimension.
        if !self.itemAttributesCache.isEmpty,
            rowCount == self.numberOfRows,
            columnCount == self.numberOfColumns,
            cellDimension == self.cellDimension,
            cellSpacing == self.cellSpacing {
            return
        }
        
        // Bust the cache and recalculate the game dimensions.
        // Either first generation or the dimensions have changed.
        self.itemAttributesCache.removeAll()
        
        self.numberOfRows = rowCount
        self.numberOfColumns = columnCount
        self.cellDimension = cellDimension
        self.cellSpacing = cellSpacing
        
        let columnWidth = self.contentWidth / CGFloat(self.numberOfColumns)
        let rowHeight = columnWidth
        
        var columnOffset = [CGFloat]()
        for column in 0 ..< self.numberOfColumns {
            columnOffset.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        var rowOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let frame = CGRect(x: columnOffset[column], y: rowOffset[column], width: columnWidth, height: rowHeight)
            let insetFrame = frame.insetBy(dx: self.cellSpacing, dy: self.cellSpacing)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = insetFrame
            self.itemAttributesCache.append(attributes)
            self.contentHeight = max(contentHeight, frame.maxY) + self.cellSpacing
            rowOffset[column] = rowOffset[column] + rowHeight
            
            column = column < (self.numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var viewRect = rect
        
        // If we have a custom window to check against, then do so.
        if let collectionView = self.collectionView,
            let viewWindowRect = self.delegate?.collectionView(viewWindowForFieldGrid: collectionView) {
            viewRect = viewWindowRect
        }
        
        return self.itemAttributesCache.filter { $0.frame.intersects(viewRect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.itemAttributesCache[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
