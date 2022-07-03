//
//  CustomCell.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    static let id = "Custom Cell"
    
    var photoModel: PhotoModel!
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator.contentMode = .scaleAspectFill
        indicator.clipsToBounds = true
        return indicator
    }()
    
    let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.clipsToBounds = true
        return stackView
    }()


    let myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageStackView)
        imageStackView.addArrangedSubview(myImageView)
        activityIndicator.startAnimating()
        backgroundColor = .blue
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
    
}


