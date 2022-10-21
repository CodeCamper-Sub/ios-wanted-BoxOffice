//
//  MovieDetailViewModel.swift
//  BoxOffice
//
//  Created by 한경수 on 2022/10/20.
//

import Foundation
import UIKit
import Combine

class MovieDetailViewModel {
    // MARK: Subject
    let share = PassthroughSubject<Void, Never>()
    let viewAction = PassthroughSubject<ViewAction, Never>()
    
    // MARK: Output
    @Published var movie: Movie
    @Published var posterModel: MoviePosterViewModel?
    @Published var directorModel: TriSectoredStackViewModel?
    @Published var actorModel: TriSectoredStackViewModel?
    
    // MARK: Properties
    var subscriptions = [AnyCancellable]()
    
    // MARK: Life Cycle
    init(movie: Movie) {
        self.movie = movie
        bind()
    }
    
    // MARK: Binding
    func bind() {
        $movie
            .sink(receiveValue: { [weak self] movie in
                guard let self else { return }
                self.posterModel = MoviePosterViewModel(movie: movie)
                if let directors = movie.detailInfo?.directors {
                    self.directorModel = TriSectoredStackViewModel(list: directors)
                }
                if let actors = movie.detailInfo?.actors {
                    self.actorModel = TriSectoredStackViewModel(list: actors)
                }
            }).store(in: &subscriptions)
        
        share
            .compactMap { [weak self] _ in
                guard let self else { return nil }
                return .share(self.movie.prettify())
            }.subscribe(viewAction)
            .store(in: &subscriptions)
    }
    
    enum ViewAction {
        case dismiss
        case share(String)
    }
}
