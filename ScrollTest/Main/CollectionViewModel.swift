//
//  CollectionViewModel.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import Foundation
import Combine

class CollectionViewModel: ObservableObject {
    
    
    @Published private(set) var state: MainViewState = .loading
    @Published var photoModels: [PhotoModel] = [PhotoModel(stringURLs: SizeURL(full:        "https://i.pinimg.com/736x/6a/ff/bf/6affbf23bf64054256aac98d7062a8f6--pop-art-illustration-illustration-tutorial.jpg", small: "https://i.pinimg.com/736x/6a/ff/bf/6affbf23bf64054256aac98d7062pop-art-illustration-illustration-tutorial.jpg")),
                                                PhotoModel(stringURLs: SizeURL(full: "https://i.pinimg.com/736x/6a/ff/bf/6affbf23bf64054256aac98d7062a8f6--pop-art-illustration-illustrtutorial.jpg", small: "https://i.pinimg.com/736x/6a/ff/bf/6affbf23bf64054256aac98d7062a8f6--pop-art-illustration-illustration-tutorial.jpg")),
                                                PhotoModel(stringURLs: SizeURL(full: "https://i.pinimg.com/736x/6a/ff/bf/6affbf23bf64054256aac98d7062a8f6--pop-art-illustration-illustration-tutorial.jpg", small: "https://i.pinimg.com/736x/6atutorial.jpg")),]
    
    
    private let limit = 5
    private var page = 1
    
    private var bag = Set<AnyCancellable>()
    
    private func fetchRandom() {
        API.getRandomPhotos(page: page, limit: 5)
            .sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: {
                self.photoModels = $0.results
                self.page += 1
            }).store(in: &bag)
    }
    
}

enum MainViewState {
    case loading, all, error(String)
}
