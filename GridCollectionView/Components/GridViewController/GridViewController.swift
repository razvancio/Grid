//
//  GridViewController.swift
//  GridCollectionView
//
//  Created by Razvan on 7/29/22.
//

import UIKit

class GridViewController: BaseViewController {

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    let viewModel = GridViewModel()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        setupUI()
    }

    // MARK: Methods
    private func setupUI() {
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.saveCollectionViewWidth(collectionView.frame.width)
    }
    
    private func configureViewModel() {
        viewModel.collectionViewSetupSubject.sink { [weak self] _  in
            guard let self = self else { return }
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.reloadData()
        }
        .store(in: &cancellables)
        
        viewModel.items.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }
        .store(in: &cancellables)
    }

    private func configureCollectionView() {
        collectionView.register(nibWithCellClass: GridCollectionViewCell.self)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        collectionView.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard gesture.numberOfTouches == 2 else { return }
        let pinchPoint = gesture.location(in: collectionView)
        
        let tuple = getSourceCellAndIndexPath(point: pinchPoint)
        
        if let indexPath = tuple.0, let cell = tuple.1 {
            let gesturePoints = getGesturePoints(gesture: gesture, in: cell)
            let diffPointsTuple = viewModel.retrieveAxisPointsDifference(firstPoint: gesturePoints.0, secondPoint: gesturePoints.1)
            handleGestureStates(gesture: gesture, indexPath: indexPath, diffPointsTuple: diffPointsTuple)
            viewModel.updateGridItemDxDy(indexPath: indexPath, dx: diffPointsTuple.0, dy: diffPointsTuple.1)
        }

    }
    
    private func getSourceCellAndIndexPath(point: CGPoint) -> (IndexPath?, GridCollectionViewCell?) {
        guard let cellIndexPath = collectionView.indexPathForItem(at: point), let cell = collectionView.cellForItem(at: cellIndexPath) as? GridCollectionViewCell else { return (nil, nil) }
        return (cellIndexPath, cell)
    }
    
    private func getGesturePoints(gesture: UIPinchGestureRecognizer, in cell: GridCollectionViewCell) -> (CGPoint, CGPoint) {
        let firstPoint = gesture.location(ofTouch: 0, in: cell.contentView)
        let secondPoint = gesture.location(ofTouch: 1, in: cell.contentView)
        return (firstPoint, secondPoint)
    }
    
    private func handleGestureStates(gesture: UIPinchGestureRecognizer, indexPath: IndexPath, diffPointsTuple: (CGFloat, CGFloat)) {
        if gesture.state == .began {
            viewModel.refreshCollectionView(indexPath: indexPath, dx: 0, dy: 0)
        } else if gesture.state != .cancelled {
            viewModel.refreshCollectionView(indexPath: indexPath,
                                            dx: diffPointsTuple.0 - viewModel.items.value[indexPath.item].dx,
                                            dy: diffPointsTuple.1 - viewModel.items.value[indexPath.item].dy)
        }
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDatasource, UICollectionViewDelegateFlowLayout
extension GridViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: GridCollectionViewCell.self, for: indexPath)
        cell.configure(indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = viewModel.items.value[indexPath.row]
        return CGSize(width: item.width, height: item.height)
    }
    
}
