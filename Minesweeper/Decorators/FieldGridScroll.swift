//
//  FieldGridScroll.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import UIKit

class FieldGridScroll: UIScrollView {
    fileprivate var fieldGridCollection: FieldGrid?
    
    private var minScaleFactor: CGFloat = Constants.defaultMinScaleFactor
    
    private var rowCount: Int = 0
    private var columnCount: Int = 0
    private var fieldWidth: CGFloat = 0
    private var fieldHeight: CGFloat = 0
    private var modifiedIndexPaths: Set<IndexPath> = []
    
    fileprivate var lastZoomedWidth: CGFloat = 0
    
    fileprivate var topConstraint: NSLayoutConstraint?
    fileprivate var leadingConstraint: NSLayoutConstraint?
    
    // This gridViewBounds is an inverse zoom of the contentSize. As content
    // size of this scrollview scales down, this gridViewBounds will appear to
    // have enlarge to the underlying collectionview.
    fileprivate var gridViewBounds: CGRect {
        // This gridViewBounds is effectively 100 larger on all sides than the
        // actual container view to prevent clipping outside of safe regions.
        let newOffsetX = (self.contentOffset.x - 100) / self.zoomScale
        let newOffsetY = (self.contentOffset.y - 100) / self.zoomScale
        let newWidth = (self.bounds.width + 200) / self.zoomScale
        let newHeight = (self.bounds.height + 200) / self.zoomScale
        
        return CGRect(x: newOffsetX, y: newOffsetY, width: newWidth, height: newHeight)
    }
    
    lazy private var setUpOnce: Void = {
        self.delegate = self
        
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        let fieldGrid = FieldGrid(frame: self.frame, collectionViewLayout: FieldGridLayout())
        fieldGrid.backgroundColor = UIColor.clear
        fieldGrid.layer.borderWidth = Constants.fieldBorderWidth
        fieldGrid.layer.borderColor = UIColor.black.cgColor
        fieldGrid.isScrollEnabled = false
        self.fieldGridCollection = fieldGrid
        
        fieldGrid.isHidden = true
        
        self.addSubview(fieldGrid)
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let _ = setUpOnce
    }
    
    func setupFieldGrid(rows: Int, columns: Int,
                        dataSource: UICollectionViewDataSource,
                        cellActionHandler: FieldGridCellActionListener,
                        completionHandler: FieldSetupCompletionHandler?) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        if rows == self.rowCount, columns == self.columnCount {
            // Dimension did not change, so just reset it.
            fieldGridCollection.dataSource = dataSource
            fieldGridCollection.cellActionHandler = cellActionHandler
            
            // Show and reload only what has been affected.
            fieldGridCollection.isHidden = false
            fieldGridCollection.reloadItems(at: Array(self.modifiedIndexPaths))
            
            self.modifiedIndexPaths.removeAll()
            self.contentSize = CGSize(width: self.fieldWidth, height: self.fieldHeight)
            
            self.recenterFieldGrid()
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.zoomScale = 1.0
                    self.contentOffset.x = 0
                    self.contentOffset.y = 0
                }) { (_) in
                    let fullGridBounds = CGRect(x: 0, y: 0, width: self.fieldWidth, height: self.fieldHeight)
                    fieldGridCollection.gridViewBounds = fullGridBounds
                }
                
                completionHandler?(self.fieldWidth, self.fieldHeight)
            }
            
            return
        }
        
        self.rowCount = rows
        self.columnCount = columns
        self.modifiedIndexPaths.removeAll()
        
        fieldGridCollection.setupFieldGrid(
            rows: rows,
            columns: columns,
            dataSource: dataSource,
            cellActionHandler: cellActionHandler
        ) { [weak self] (fieldWidth, fieldHeight) in
            guard let `self` = self else { return }
            self.fieldWidth = fieldWidth
            self.fieldHeight = fieldHeight
            
            self.contentSize = CGSize(width: fieldWidth, height: fieldHeight)
            
            self.calculateGridLayoutParams(width: fieldWidth, height: fieldHeight)
            
            let partialGridBounds = CGRect(x: 0, y: 0, width: self.bounds.size.width * 1.5, height: self.bounds.size.height * 1.5)
            fieldGridCollection.gridViewBounds = partialGridBounds
            
            fieldGridCollection.isHidden = false
            fieldGridCollection.reloadData()
            
            DispatchQueue.main.async {
                // Paint grid first at the smaller view bounds = loads less cells.
                UIView.animate(withDuration: 0.3, animations: {
                    self.zoomScale = 1.0
                    self.contentOffset.x = 0
                    self.contentOffset.y = 0
                }) { (_) in
                    // Load the entire table in the brief moment before user plays.
                    let fullGridBounds = CGRect(x: 0, y: 0, width: fieldWidth, height: fieldHeight)
                    fieldGridCollection.gridViewBounds = fullGridBounds
                }
                
                completionHandler?(fieldWidth, fieldHeight)
            }
        }
    }
    
    private func calculateScaleFactors() {
        let windowWidth = self.frame.width
        let windowHeight = self.frame.height
        
        // Figure out which dimension is wider than the screen when normalized,
        // that dimension would determine the mininum scale factor to fit the
        // entire field into the container.
        let screenAspect = windowWidth / windowHeight
        let fieldAspect = self.fieldWidth / self.fieldHeight
        
        let newMinScale = (fieldAspect > screenAspect) ? windowWidth / self.fieldWidth : windowHeight / self.fieldHeight
        
        if self.minScaleFactor < newMinScale {
            self.zoomScale = newMinScale
        }
        
        self.minScaleFactor = newMinScale
        self.minimumZoomScale = self.minScaleFactor
        self.maximumZoomScale = Constants.defaultMaxScaleFactor
    }
    
    func showEntireField() {
        UIView.animate(withDuration: 0.3) {
            self.zoomScale = self.minScaleFactor
            self.recenterFieldGrid()
        }
    }
    
    func updateCells(at indexPaths: [IndexPath]) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        // Keep track of which cell has been affected.
        self.modifiedIndexPaths = self.modifiedIndexPaths.union(indexPaths)
        
        DispatchQueue.main.async {
            fieldGridCollection.reloadItems(at: indexPaths)
        }
    }
    
    func calculateGridLayoutParams(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.calculateScaleFactors()
        self.lastZoomedWidth = 0
        self.recenterFieldGrid(width: width, height: height)
    }
    
    fileprivate func recenterFieldGrid(width: CGFloat? = nil, height: CGFloat? = nil) {
        guard self.lastZoomedWidth != self.contentSize.width,
            let fieldGrid = self.fieldGridCollection else { return }
        
        let fieldWidth = width ?? self.contentSize.width
        let fieldHeight = height ?? self.contentSize.height
        
        let windowWidth = self.frame.width
        let windowHeight = self.frame.height
        
        self.lastZoomedWidth = fieldWidth
        
        if fieldWidth > windowWidth, fieldHeight > windowHeight {
            self.resetConstraintsToOrigin()
        } else {
            self.leadingConstraint?.isActive = false
            self.topConstraint?.isActive = false
            
            if fieldWidth < windowWidth {
                // lockOffsetX
                let xOffset = (windowWidth - fieldWidth) / 2
                let leadingConstraint = fieldGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: xOffset)
                self.leadingConstraint = leadingConstraint
            } else {
                let leadingConstraint = fieldGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor)
                self.leadingConstraint = leadingConstraint
            }
            
            if fieldHeight < windowHeight {
                // lockOffsetY
                let yOffset = (windowHeight - fieldHeight) / 2
                let topConstraint = fieldGrid.topAnchor.constraint(equalTo: self.topAnchor, constant: yOffset)
                self.topConstraint = topConstraint
            } else {
                let topConstraint = fieldGrid.topAnchor.constraint(equalTo: self.topAnchor)
                self.topConstraint = topConstraint
            }
            
            self.topConstraint?.isActive = true
            self.leadingConstraint?.isActive = true
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    private func resetConstraintsToOrigin() {
        guard let fieldGrid = self.fieldGridCollection else { return }
        
        self.leadingConstraint?.isActive = false
        self.topConstraint?.isActive = false
        
        let leadingConstraint = fieldGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        self.leadingConstraint = leadingConstraint
        
        let topConstraint = fieldGrid.topAnchor.constraint(equalTo: self.topAnchor)
        self.topConstraint = topConstraint
        
        self.topConstraint?.isActive = true
        self.leadingConstraint?.isActive = true
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
}

extension FieldGridScroll: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.fieldGridCollection
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.recenterFieldGrid()
    }
}

extension FieldGridScroll: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
