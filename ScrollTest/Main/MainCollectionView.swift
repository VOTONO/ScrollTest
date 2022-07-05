//
//  MainCollectionView.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import UIKit
import Combine

final class MainCollectionView: UICollectionViewController {
    
    // Image Cache for injection into cells
    var imageCache: ImageCache = ImageCache()
    var viewModel: CollectionViewModel!
    
    private var dataSource: DataSource!
    private var snapshot = DataCourceSnapshot()
    
    private var bag = Set<AnyCancellable>()
    
    //Cells animation time
    private let animationTime: Double = 0.7
    private var portraitWidth: CGFloat {
        
        if (UIWindow.isLandscape) {
            return UIScreen.main.bounds.height
        } else {
            return UIScreen.main.bounds.width
        }
    }
    private var spinner = UIActivityIndicatorView(style: .large)

//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupRefreshControl()
        setupSpinner()
        setupSubscription()
    }

//MARK: - Overrides
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        animateCells(indexPath: indexPath, animationTime: animationTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime, execute: {
            self.viewModel.photoModels.value.remove(at: indexPath.row)
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.photoModels.value.count - 1 {
            self.viewModel.fetchRandom()
        }
    }
}

//MARK: - Functions, Actions and Subscriptions
    
extension MainCollectionView {
    
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
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .success:
                    self.spinner.stopAnimating()
                case .loading:
                    break
                case .error(let error):
                    self.spinner.stopAnimating()
                    self.showAlert(description: error.description)
                }
            }.store(in: &bag)
    }
    
    private func showAlert(description: String) {
        let alert = UIAlertController(title: "Error", message: "\(description)", preferredStyle: .alert)

        let cancel = UIAlertAction(title: "Retry", style: .default) { (action) -> Void in
            self.viewModel.fetchRandom()
        }
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Setup Collection View
extension MainCollectionView {
    
    private func setupCollectionView() {
        configureCollectionViewDataSource()
        applySnapshot(photoModels: viewModel.photoModels.value)
        registerCell()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PhotoModel>
    typealias DataCourceSnapshot = NSDiffableDataSourceSnapshot<Section, PhotoModel>
    
    
    enum Section {
        case main
    }
    
    private func configureCollectionViewDataSource() {
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, photoModel -> CustomCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCell.id, for: indexPath) as! CustomCell
            
            //# WARNING! Don't forget to ingect imageCache(with self.imageCache) and Photo Model!!!
            cell.imageCache = self.imageCache
            cell.photoModel = self.viewModel.photoModels.value[indexPath.row]
            
            //# WARNING! Call this function only after injections
            cell.initialize()
            return cell
        })
    }
    private func applySnapshot(photoModels: [PhotoModel]) {
        snapshot = DataCourceSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(photoModels)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func registerCell() {
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: CustomCell.id)
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let size = (portraitWidth - 20)
        
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        return layout
    }
    
}

//MARK: Animations
extension MainCollectionView {
    
    private func animateCells(indexPath: IndexPath, animationTime: Double) {
        let cell = collectionView.cellForItem(at: indexPath)
        let secondCell = collectionView.cellForItem(at: IndexPath(row: indexPath.row + 1, section: indexPath.section))
        let thirdCell = collectionView.cellForItem(at: IndexPath(row: indexPath.row + 2, section: indexPath.section))
        
        let originalTransform = self.view.transform
        let cellTransform = originalTransform.translatedBy(x: +(UIScreen.main.bounds.width), y: 0.0)
        let secondCellTransform = originalTransform.translatedBy(x: 0.0, y: -(portraitWidth - 10))
        let thirdCellTransform = originalTransform.translatedBy(x: 0.0, y: -(portraitWidth - 10))
        
        UIView.animate(withDuration: animationTime, animations: {
            cell?.transform = cellTransform
            cell?.alpha = 0
            secondCell?.transform = secondCellTransform
            thirdCell?.transform = thirdCellTransform
            })
    }
    
    private func setupSpinner() {
        self.view.addSubview(spinner)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}
