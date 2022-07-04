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
        indicator.contentMode = .scaleAspectFill
        return indicator
    }()
    
    let imageStackView: UIStackView = {
        let stackView = UIStackView()
        
        return stackView
    }()


    let myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myImageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myImageView.image = nil
    }
    
    func initialize() {
        
        contentView.addSubview(activityIndicator)
        contentView.addSubview(myImageView)
        myImageView.backgroundColor = .gray
        
        
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
                    DispatchQueue.main.async {
                        self.activityIndicator.startAnimating()
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    
                }
            }.store(in: &bag)
        
        imageLoader.image
            .receive(on: DispatchQueue.main)
            .sink { image in
                DispatchQueue.main.async {
                    print("Setup Image")
                    self.myImageView.image = image
                }
            
        }.store(in: &bag)
    }
    
}


