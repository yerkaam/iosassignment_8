import Foundation
import UIKit
final class NewsViewModel {
    private let newsService: NewsService
    private(set) var news: [New] = []
    private var likedStates: [Bool] = [] // [Like, Unlike] состояния для каждой новости
    
    var didLoadNews: (([New]) -> Void)?

    init(newsService: NewsService) {
        self.newsService = newsService
        loadLikedStates()
    }

    func getTopHeadLines() {
        newsService.getTopHeadLines(
            success: { [weak self] news in
                guard let self = self else { return }
                self.news = news
                // Если нет сохраненного состояния, инициализируем
                if self.likedStates.isEmpty {
                    self.likedStates = Array(repeating: false, count: news.count)
                }
                self.didLoadNews?(news)
            },
            failure: { error in
                print("Error fetching news: \(error.localizedDescription)")
            }
        )
    }


    // Переключаем состояние Like
    func toggleLike(for index: Int) {
        guard index >= 0 && index < likedStates.count else { return }
        likedStates[index] = true  // Активируем Like
        if index + 1 < likedStates.count {
            likedStates[index + 1] = false  // Сбрасываем Unlike
        }
        saveLikedStates()  // Сохраняем изменения
    }

    func toggleUnlike(for index: Int) {
        guard index >= 0 && index < likedStates.count else { return }
        likedStates[index] = false  // Активируем Unlike
        if index + 1 < likedStates.count {
            likedStates[index + 1] = true  // Сбрасываем Like
        }
        saveLikedStates()  // Сохраняем изменения
    }


    // Переключаем состояние Unlike
    

    // Проверяем состояние кнопки Like
    func isLiked(for index: Int) -> Bool {
        return likedStates[index]
    }

    // Сохраняем состояние Like/Unlike в UserDefaults
    private func saveLikedStates() {
        UserDefaults.standard.set(likedStates, forKey: "likedStates")
    }

    // Загружаем состояние Like/Unlike из UserDefaults
    private func loadLikedStates() {
        if let savedStates = UserDefaults.standard.array(forKey: "likedStates") as? [Bool] {
            likedStates = savedStates
        } else {
            likedStates = Array(repeating: false, count: news.count)
        }
    }
}

