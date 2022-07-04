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
    public let pullToRefreshSubject = PassthroughSubject<Void, Never>()
    
    var photoModels = CurrentValueSubject<[PhotoModel], Never>([]) {
        didSet {
            print("Photo models: \(photoModels.value.count)")
        }
    }
    private var deletedStorage: [Int : PhotoModel] = [ : ] {
        didSet {
            print("Store Deleted: \(deletedStorage.count)")
            print("Photo models: \(photoModels.value.count)")
        }
    }
    var loadedPage = PassthroughSubject<SearchModel, Never>()
    
    private let limit = 5
    private var page = 1
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        fetchRandom()
        setupSubscriptions()
    }
    
    func fetchRandom() {
        API.getRandomCats(page: page, limit: 5)
            .sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    print("Fetch Random error: \(error)")
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: {
                self.photoModels.value += $0.results
                self.page += 1
            }).store(in: &bag)
    }
    
    func storeDeletion(photoModel: PhotoModel, at index: Int) {
        deletedStorage[index] = photoModel
    }
    private func setupSubscriptions() {
        pullToRefreshSubject.sink { _ in
            self.deletedStorage.forEach { key, value in
                self.photoModels.value.insert(value, at: key)
            }
            print("Refreshing")
            self.deletedStorage.removeAll()
        }.store(in: &bag)
    }
    
}

enum MainViewState {
    case loading, all, error(String)
}
