# SocialNetwork
Так как приложение небольшое и стоить всего из одной страницы была была использована архитектура MVC :
Model :
Отвечает за хранение данных и бизнес-логику.
Core Data (Post сущность) и данные из API (структуры PostModel, PostAPI)
Загрузка данных через API (URLSession)
ImageLoader для изображений
Бизнес Логика 
Методы сохранения/загрузки данных в Core Data: (private func savePostsToCoreData(_ posts: [PostAPI]) { ... }
private func fetchPostsFromCoreData() -> [PostModel] { ... }

View: 
Отвечает за отображение данных. Содержит UI-компоненты без логики.
Компоненты:
-UI-Элементы :
UITableView: Основная таблица ленты.
PostTableViewCell: Ячейка таблицы с:
UILabel (для заголовка и текста).
UIImageView (для аватарки).
-Код для установки констрейнтов в PostTableViewCel

Controller :
Связывает модель и представление, управляет их взаимодействием.
Компоненты:
-ViewController :
   Инициализация UITableView и настройка UIRefreshControl.
   Обработка событий:
Загрузка данных при старте (loadInitialData()).
Обновление через pull-to-refresh (handleRefresh()).
    Обновление UI:
tableView.reloadData().
Управление состоянием refreshControl.
-Протоколы и делегирование :
UITableViewDataSource и UITableViewDelegate для работы с таблицей.

Преимущества MVC в этом проекте
Отделение ответственности :
Модель занимается данными.
Представление — отображением.
Контроллер — связью между ними.
Читаемость : 
Код разделён на логические части.

Недостатки:
ViewController может стать слишком большим.
Для сложных приложений лучше использовать MVVM или VIPER .


Список использованных технологий: 

1. Основные технологии
UIKit : Для создания пользовательского интерфейса (UITableView, UITableViewCell, Auto Layout).
Core Data : Для хранения данных оффлайн (посты, аватарки).
URLSession : Для асинхронной загрузки данных из удалённых API. - Не испольлозовала библиотеку, были проблемы с загрузкой самой библиотеки. URLSession надежнее.
Swift : Язык программирования.

2. Инструменты и фреймворки
Auto Layout в коде : Настройка UI без использования Storyboard.
JSON Decoding : Парсинг JSON-ответов от API (например, PostAPI).
NSCache : Кэширование загруженных изображений в ImageLoader.
Xcode : Среда разработки для iOS.

3. Сервисы и API
JSONPlaceholder (https://jsonplaceholder.typicode.com/posts): Для получения данных постов.
RandomUser.Me (https://randomuser.me/api/portraits): Для генерации URL аватарок пользователей.

4. Дополнительные компоненты
ImageLoader :
Загрузка изображений из сети.
Кэширование для ускорения повторного отображения.
UIRefreshControl : Для поддержки pull-to-refresh в таблице.

5. Паттерны программирования
Протоколы и делегирование :
UITableViewDataSource и UITableViewDelegate в ViewController.
Опциональные типы : Для работы с необязательными полями в Core Data (например, postId).

6. Основные классы и структуры
Post
(Core Data) : Сущность для хранения постов в базе данных.
PostAPI : Модель для парсинга JSON-ответа от API.
PostModel : Модель для передачи данных в представление (ячейки таблицы).
ImageLoader : Утилитный класс для загрузки и кэширования изображений.
PostTableViewCell : Ячейка таблицы с аватаркой, заголовком и текстом поста.
ViewController : Контроллер, отвечающий за загрузку данных и обновление UI.

7. Настройки и особенности
Отсутствие Storyboard : Вся UI создана программно.
Опциональные поля в Core Data : Для безопасной работы с данными (например, postId в Post).
Обработка ошибок : Проверки на nil при работе с Core Data и загрузке изображений.

8. Тестирование
Симулятор iOS : Для проверки работы приложения.


Инструкция по сборке приложения "Социальная лента"
1. Создание проекта
Откройте Xcode → Create a new Xcode project .
Выберите App → Нажмите Next .
Укажите:
Product Name : SocialFeed.
Team : Ваша учетная запись (или оставить пустым).
Organization Name : Ваша организация (или пусто).
Bundle Identifier : Уникальный идентификатор (например, com.yourname.SocialFeed).
Interface : Swift , UIKit , iPhone .
Lifecycle : SwiftUI (или Storyboard , но мы удалим Storyboard позже).
Нажмите Next → Выберите папку для проекта → Create .

3. Удаление Storyboard
В проекте удалите файл Main.storyboard:
Щёлкните правой кнопкой мыши по файлу → Delete → Move to Trash .
В Info.plist убедитесь, что нет ключа Main storyboard file base name. Если есть — удалите его.

3. Настройка Core Data
Добавьте модель Core Data:
В Xcode → File → New → File → Data Model → Назовите его SocialNetwork.xcdatamodeld → Create .
Создайте сущность Post в модели:
В правой панели (Data Model Inspector) укажите Name : Post.
Добавьте атрибуты:
postId → Type : Integer 16-bit → Optional 
title → Type : String → Optional 
body → Type : String → Optional 
avatarURL → Type : String → Optional 
Настройте генерацию кода для сущности:
В Data Model Inspector для сущности Post установите Codegen : Class Definition .

4. Настройка AppDelegate для Core Data
Откройте AppDelegate.swift и добавьте код для инициализации Core Data:

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SocialNetwork")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Core Data failed: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // Остальной код...
}

5. Создание View Controller
Создайте файл ViewController.swift:
File → New → File → Swift File → Назовите ViewController.
Добавьте базовую структуру:

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var posts: [PostModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadInitialData()
    }
    // Остальной код будет добавлен позже.
}
6. Создание ячейки таблицы
Создайте файл PostTableViewCell.swift:

import UIKit

class PostTableViewCell: UITableViewCell {
    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Настройка AutoLayout и добавление элементов.
        // Полный код см. в предыдущих ответах.
    }

    func configure(with model: PostModel) {
        // Заполнение данных в ячейку.
    }
}
7. Настройка ImageLoader
Создайте файл ImageLoader.swift:

import Foundation
import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                completion(nil)
                return
            }
            self.cache.setObject(image, forKey: url as NSURL)
            completion(image)
        }.resume()
    }
}
8. Реализация логики загрузки данных
Добавьте в ViewController.swift методы для работы с API и Core Data:

// Модель для отображения
struct PostModel {
    let postId: Int
    let title: String
    let body: String
    let avatarURL: URL?
}

// Модель для API
struct PostAPI: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

extension ViewController {
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        // Добавьте констрейнты для tableView.
    }

    private func loadInitialData() {
        posts = fetchPostsFromCoreData()
        tableView.reloadData()
        loadPostsFromAPI()
    }

    private func loadPostsFromAPI() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data else { return }
            do {
                let posts = try JSONDecoder().decode([PostAPI].self, from: data)
                self?.savePostsToCoreData(posts)
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }

    private func savePostsToCoreData(_ posts: [PostAPI]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // Реализация сохранения в Core Data (см. предыдущие ответы).
    }

    private func fetchPostsFromCoreData() -> [PostModel] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // Реализация загрузки из Core Data (см. предыдущие ответы).
    }
}
9. Настройка SceneDelegate
В SceneDelegate.swift инициализируйте начальный контроллер:

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
               let window = UIWindow(windowScene: windowScene)
               let rootViewController = ViewController()
               window.rootViewController = rootViewController
               window.makeKeyAndVisible()
               self.window = window
    }
 }

10. Тестирование
Запустите приложение на симуляторе/устройстве.
Проверьте:
Загрузку данных из API.
Сохранение в Core Data.
Обновление через pull-to-refresh.
Отображение аватарок через ImageLoader.
