import UIKit
import SnapKit

class NewsController: UIViewController, UITableViewDelegate {
    private let viewModel: NewsViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: Init
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        fetchData()
        bindViewModel()

    }
    
}

// MARK: View Layout & Binding
private extension NewsController {
    func layoutUI() {
        title = "News"
        view.backgroundColor = .gray
        view.addSubview(tableView)
        setUpTableView()
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewCell.self, forCellReuseIdentifier: "newCell")
    }
    
    func fetchData() {
        viewModel.getTopHeadLines()
    }
    
    func bindViewModel() {
        viewModel.didLoadNews = { [weak self] news in
            self?.tableView.reloadData()
        }
    }
}

// MARK: TableView Data Source
extension NewsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! NewCell
        
        let newsItem = viewModel.news[indexPath.row]
        let isLiked = viewModel.isLiked(for: indexPath.row)
        let isUnlike = !isLiked // Если Like не активен, то активен Unlike

        // Передаем данные и состояние в ячейку
        cell.configure(data: newsItem, isLiked: isLiked, isUnlike: isUnlike)

        // Обработчик кнопки Like
        cell.likeButtonTapped = { [weak self] in
            self?.viewModel.toggleLike(for: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        // Обработчик кнопки Unlike
        cell.unlikeButtonTapped = { [weak self] in
            self?.viewModel.toggleUnlike(for: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }





}
extension NewsController{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Убираем выделение строки после выбора
        
        // Получаем данные новости для выбранной строки
        let newsItem = viewModel.news[indexPath.row]
        
        // Создаем экземпляр NewDetailViewController с передачей newsUrl
        let newsDetailViewController = NewDetailViewController(newsUrl: newsItem.url)
        
        // Переход на детальный экран
        navigationController?.pushViewController(newsDetailViewController, animated: true)
    }
}




