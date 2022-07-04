//
//  CustomCell.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import UIKit
import Combine

class CustomCell: UICollectionViewCell {
    
    static let id = "Custom Cell"
    
    var viewModel: CollectionViewModel!
    var photoModel: PhotoModel! 
    var imageLoader: ImageLoader!
    var indexPath: IndexPath!
    var imageCache: ImageCache!
    
    private var bag = Set<AnyCancellable>()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator.clipsToBounds = true
        return indicator
    }()

    let myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

//MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myImageView.frame = contentView.bounds
        activityIndicator.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myImageView.image = nil
    }

//MARK: - Initialize
    
    func initialize() {
        
        contentView.addSubview(myImageView)
        contentView.addSubview(activityIndicator)
        myImageView.backgroundColor = .systemBackground
        
        //#WARNING Setup photoModel and Image Loader !
        self.photoModel = viewModel.photoModels.value[indexPath.row]
        self.imageLoader = ImageLoader(url: photoModel.smallURL(), cache: imageCache)
        setupSubscriptions()
        imageLoader.load()
        
    }
    
    private func setupSubscriptions() {
        
        imageLoader.isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }.store(in: &bag)
        
        imageLoader.image
            .receive(on: DispatchQueue.main)
            .sink { image in
                UIView.transition(with: self.myImageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                   self.myImageView.image = image
                                    })
        }.store(in: &bag)
    }
    
}


