import Foundation

final class SportsViewModel {
    private let sportsService: SportsService
    private(set) var sportsNews: [New] = []
    private var likedStates: [Bool] = [] // Состояние Like/Unlike для каждой спортивной новости
    
    var didLoadSportsNews: (([New]) -> Void)?

    init(sportsService: SportsService) {
        self.sportsService = sportsService
        loadLikedStates()
    }

    func getSportsNews() {
        sportsService.getSportsNews(
            success: { [weak self] news in
                guard let self = self else { return }
                self.sportsNews = news
                // Если нет сохраненного состояния, инициализируем
                if self.likedStates.isEmpty {
                    self.likedStates = Array(repeating: false, count: news.count)
                }
                self.didLoadSportsNews?(news)
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
        UserDefaults.standard.set(likedStates, forKey: "sportsLikedStates")
    }

    // Загружаем состояние Like/Unlike из UserDefaults
    private func loadLikedStates() {
        if let savedStates = UserDefaults.standard.array(forKey: "sportsLikedStates") as? [Bool] {
            likedStates = savedStates
        } else {
            likedStates = Array(repeating: false, count: sportsNews.count)
        }
    }
}
