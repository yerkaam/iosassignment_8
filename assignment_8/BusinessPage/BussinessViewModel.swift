//
//  BussinessViewModel.swift
//  assignment_8
//
//  Created by Yerdaulet Orynbay on 24.11.2024.
//

import Foundation

final class BussinessViewModel {
    private let bussinessService: BussinessService
    private(set) var bussinessNews: [New] = []
    private var likedStates: [Bool] = [] // Состояние Like/Unlike для каждой спортивной новости
    
    var didLoadBussinessNews: (([New]) -> Void)?

    init(bussinessService: BussinessService) {
        self.bussinessService = bussinessService
        loadLikedStates()
    }

    func getBussinessNews() {
        bussinessService.getBussinessNews(
            success: { [weak self] news in
                guard let self = self else { return }
                self.bussinessNews = news
                // Если нет сохраненного состояния, инициализируем
                if self.likedStates.isEmpty {
                    self.likedStates = Array(repeating: false, count: news.count)
                }
                self.didLoadBussinessNews?(news)
            },
            failure: { error in
                print("Error fetching sports news: \(error.localizedDescription)")
            }
        )
    }

    // Переключаем состояние Like
    func toggleLike(for index: Int) {
        guard index >= 0 && index < likedStates.count else { return }
        likedStates[index] = true // Устанавливаем Like
        if index + 1 < likedStates.count {
            likedStates[index + 1] = false // Сбрасываем Unlike
        }
        saveLikedStates() // Сохраняем изменения
    }

    // Переключаем состояние Unlike
    func toggleUnlike(for index: Int) {
        guard index >= 0 && index < likedStates.count else { return }
        likedStates[index] = false // Устанавливаем Unlike
        if index + 1 < likedStates.count {
            likedStates[index + 1] = true // Сбрасываем Like
        }
        saveLikedStates() // Сохраняем изменения
    }

    // Проверяем состояние Like для определенного индекса
    func isLiked(for index: Int) -> Bool {
        return likedStates[index]
    }

    // Сохраняем состояние Like/Unlike в UserDefaults
    private func saveLikedStates() {
        UserDefaults.standard.set(likedStates, forKey: "bussinessLikedStates")
    }

    // Загружаем состояние Like/Unlike из UserDefaults
    private func loadLikedStates() {
        if let savedStates = UserDefaults.standard.array(forKey: "bussinessLikedStates") as? [Bool] {
            likedStates = savedStates
        } else {
            likedStates = Array(repeating: false, count: bussinessNews.count)
        }
    }
}
