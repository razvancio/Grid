//
//  GridViewModelTests.swift
//  GridCollectionViewTests
//
//  Created by Razvan on 7/29/22.
//

import XCTest
@testable import GridCollectionView

class GridViewModelTests: XCTestCase {
    
    var viewModel: GridViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = GridViewModel()
        viewModel.numberOfItems = 9
        viewModel.initialCellWidth = 100
        viewModel.saveCollectionViewWidth(375)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRetrieveAxisPointsDifference() throws {
        let firstPoint = CGPoint.init(x: 5, y: 5)
        let secondPoint = CGPoint.init(x: 10, y: 11)
        let dx: CGFloat = 5
        let dy: CGFloat = 6
        let tuple = viewModel.retrieveAxisPointsDifference(firstPoint: firstPoint, secondPoint: secondPoint)
        XCTAssertEqual(tuple.0, dx, "dx: incorrect value \(tuple.0). Expected value: \(dx)")
        XCTAssertEqual(tuple.1, dy, "dy: incorrect value \(tuple.1). Expected value: \(dy)")
    }
   
    func testUpdateGridItemDxDy() throws {
        let indexPath = IndexPath.init(item: 1, section: 0)
        viewModel.updateGridItemDxDy(indexPath: indexPath, dx: 5, dy: 100)
        let item = viewModel.items.value[indexPath.item]
        XCTAssertEqual(item.dx, 5, "incorrect dx")
        XCTAssertEqual(item.dy, 100, "incorrect dy")
    }
    
    func testUpdateGridWidthHeight() throws {
        let indexPath = IndexPath.init(item: 1, section: 0)
        viewModel.updateGridItemSize(index: indexPath.item, width: 100, height: 200)
        let item = viewModel.items.value[indexPath.item]
        XCTAssertEqual(item.width, 100, "incorrect width")
        XCTAssertEqual(item.height, 200, "incorrect height")
    }
    
    func testRefreshCollectionViewIncreasedHeight() throws {
        let expectedHeight: CGFloat = 105
        viewModel.refreshCollectionView(indexPath: IndexPath.init(item: 1, section: 0), dx: 0, dy: 5)
        XCTAssertEqual(viewModel.items.value[0].height, expectedHeight, "wrong item index 1 height. expected \(expectedHeight)")
        XCTAssertEqual(viewModel.items.value[1].height, expectedHeight, "wrong item width 4 height. expected \(expectedHeight)")
        XCTAssertEqual(viewModel.items.value[2].height, expectedHeight, "wrong item width 7 height. expected \(expectedHeight)")
    }
    
    func testRefreshItemWidths() throws {
        let expectedWidth: CGFloat = 122.5
        let indexPath = IndexPath.init(item: 1, section: 0)
        viewModel.refreshItemWidths(indexPathWithPinch: indexPath, dx: 5)
        XCTAssertEqual(viewModel.itemWidths[0], expectedWidth, "wrong item index 0 width. expected \(expectedWidth)")
    }
    

}
