//
//  CollectionViewModel.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import Foundation
import Combine

final class CollectionViewModel: ObservableObject {
    
    var photoModels = CurrentValueSubject<[PhotoModel], Never>([])
    
    // For refreshing state afteter deletions
    var referencePhotoModels: [PhotoModel] = []
    
    var state = CurrentValueSubject<MainViewState, Never>(.success)
    public let pullToRefreshSubject = PassthroughSubject<Void, Never>()

    private var deletedStorage: [Int : PhotoModel] = [ : ]
    
    // Photo per page
    private let limit = 5
    private var page = 1
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        fetchRandom()
        setupSubscriptions()
    }
    
    func fetchRandom() {
        state.send(.loading)
        API.getRandomCats(page: page, limit: 5)
            .sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    print("Fetch Random error: \(error)")
                    self.state.send(.error(error.localizedDescription))
                    
                }
            }, receiveValue: {
                self.photoModels.value += $0.results
                self.referencePhotoModels += $0.results
                self.page += 1
                self.state.send(.success)
            }).store(in: &bag)
    }
    
    
    func storeDeletion(photoModel: PhotoModel, at index: Int) {
        deletedStorage[index] = photoModel
    }
    
    private func setupSubscriptions() {
        pullToRefreshSubject.sink { _ in
            self.photoModels.send(self.referencePhotoModels)
        }.store(in: &bag)
    }
    
}

enum MainViewState {
    case success, loading, error(String)
}
