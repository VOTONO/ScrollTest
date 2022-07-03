//
//  MainCollectionView.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import UIKit
import Combine

class MainCollectionView: UICollectionViewController {
    
    var viewModel: CollectionViewModel!
    
    private var dataSource: DataSource!
    private var snapshot = DataCourceSnapshot()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        configureCollectionViewDataSource()
        applySnapshot(photoModels: viewModel.photoModels)

        // Register cell classes
        registerCell()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)

        // Do any additional setup after loading the view.
       
    }
    
}


//MARK: Setup Collection View
extension MainCollectionView {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PhotoModel>
    typealias DataCourceSnapshot = NSDiffableDataSourceSnapshot<Section, PhotoModel>
    
    
    enum Section {
        case main
    }
    
    private func configureCollectionViewDataSource() {
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, photoModel -> CustomCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCell.id, for: indexPath) as! CustomCell
            cell.photoModel = self.viewModel.photoModels[indexPath.row]
            
            return cell
        })
    }
    
    private func applySnapshot(photoModels: [PhotoModel]) {
        snapshot = DataCourceSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(photoModels)
        dataSource.apply(snapshot)
    }
    
    
    
    private func registerCell() {
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: CustomCell.id)
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let size = (view.frame.size.width - 20)
        
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        return layout
    }
    
}
