//
//  MainCollectionView.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import UIKit
import Combine

class MainCollectionView: UICollectionViewController {
    
    
    var imageCache: ImageCache = ImageCache()
    var viewModel: CollectionViewModel!
    
    private var dataSource: DataSource!
    private var snapshot = DataCourceSnapshot()
    
    private var bag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewDataSource()
        applySnapshot(photoModels: viewModel.photoModels.value)

        // Register cell classes
        registerCell()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)

        // Do any additional setup after loading the view.
        setupRefreshControl()
        setupSubscription()

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        let nextCell = collectionView.cellForItem(at: IndexPath(row: indexPath.row + 1, section: indexPath.section))
        guard let photoModel = dataSource.itemIdentifier(for: indexPath) else {return}
        
        let originalTransform = self.view.transform
        let cellTransform = originalTransform.translatedBy(x: +(self.view.frame.width), y: 0.0)
        let nextCellTransform = originalTransform.translatedBy(x: 0.0, y: -(self.view.frame.width - 10))
        
        UIView.animate(withDuration: 0.7, animations: {
            cell?.transform = cellTransform
            cell?.alpha = 0
            nextCell?.transform = nextCellTransform
            })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.viewModel.storeDeletion(photoModel: photoModel, at: indexPath.row)
            self.viewModel.photoModels.value.remove(at: indexPath.row)
            //self.deleteFromSnapshot(photoModels: [photoModel])
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.photoModels.value.count - 1 {
            print("Load Page")
            self.viewModel.fetchRandom()
        }
    }
    
    private func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(onSwipeRefresh), for: .valueChanged)
        collectionView.refreshControl = refresh
    }
    
    @objc func onSwipeRefresh() {
        viewModel.pullToRefreshSubject.send()
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    private func setupSubscription() {
        viewModel.photoModels
            .sink { photoModels in
            self.applySnapshot(photoModels: photoModels)
        }.store(in: &bag)

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
            
            //# WARNING! Don't forget to ingect ViewModel, imageCache(with self.imageCache) and IndexPath!!!
            cell.viewModel = self.viewModel
            cell.imageCache = self.imageCache
            cell.indexPath = indexPath
            
            //# WARNING! Call this function only after injections
            cell.initialize()
            return cell
        })
    }
    
    private func deleteFromSnapshot(photoModels: [PhotoModel]) {
        snapshot.deleteItems(photoModels)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func applySnapshot(photoModels: [PhotoModel]) {
        snapshot = DataCourceSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(photoModels, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
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
