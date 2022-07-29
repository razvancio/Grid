//
//  GridCollectionViewCell.swift
//  GridCollectionView
//
//  Created by Razvan on 7/29/22.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {

    // MARK: Outlets
    @IBOutlet weak var label: UILabel!
    
    // MARK: Methods
    func configure(indexPath: IndexPath) {
        label.text = "\(indexPath.item)"
        backgroundColor = indexPath.item % 2 == 0 ? .lightGray : .gray
    }
    
}
