//
//  ImageLoader.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 03.07.2022.
//


import Combine
import UIKit

final class ImageLoader {
    
    var image = PassthroughSubject<UIImage?, Never>()
    
    private let url: URL
    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private var cache: ImageCache
    private var cancellable: AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(url: URL, cache: ImageCache) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        
        guard !isLoading.value else { return }
        
        if let data = cache[url] {
            self.image.send(UIImage(data: data))
            print("Loaded image from cache")
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.imageProcessingQueue)
            .sink { [weak self] in self?.image.send($0) }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading.send(true)
    }
    
    private func onFinish() {
        isLoading.send(false)
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache[url] = $0.jpegData(compressionQuality: 0.8) }
    }
    
}
