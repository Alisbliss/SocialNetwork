//
//  ViewController.swift
//  SocialNetWork
//
//  Created by Алеся Афанасенкова on 10.03.2025.
//

import UIKit
import CoreData

struct PostModel {
    let postId: Int
    let title: String
    let body: String
    let avatarURL: URL?
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var posts: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadInitialData()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        refreshControl.tintColor = .systemBlue
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func loadInitialData() {
        posts = fetchPostsFromCoreData()
        tableView.reloadData()
        loadPostsFromAPI()
    }
    
    @objc private func handleRefresh() {
        loadPostsFromAPI()
        refreshControl.endRefreshing()
    }
    
    // MARK: - API
    private func loadPostsFromAPI() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let posts = try JSONDecoder().decode([PostAPI].self, from: data)
                self?.savePostsToCoreData(posts)
            } catch {
                print("Error parsing posts: \(error)")
            }
        }.resume()
    }
    
    // MARK: - Core Data
    private func savePostsToCoreData(_ posts: [PostAPI]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        context.perform {
            posts.forEach { post in
                let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "postId == %d", post.id)
                
                do {
                    if let existing = try context.fetch(fetchRequest).first {
                        existing.title = post.title
                        existing.body = post.body
                        existing.avatarURL = self.avatarURL(for: post.userId)
                    } else {
                        let newPost = Post(context: context)
                        newPost.postId = Int16(post.id)
                        newPost.title = post.title
                        newPost.body = post.body
                        newPost.avatarURL = self.avatarURL(for: post.userId)
                    }
                } catch {
                    print("Error fetching existing post: \(error)")
                }
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.posts = self.fetchPostsFromCoreData()
                    self.tableView.reloadData()
                }
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    private func avatarURL(for userId: Int) -> String {
        let gender = userId % 2 == 0 ? "men" : "women"
        return "https://randomuser.me/api/portraits/med/\(gender)/\(userId).jpg"
    }
    
    private func fetchPostsFromCoreData() -> [PostModel] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { entity in
                guard
                      let title = entity.title,
                      let body = entity.body,
                      let avatarURLString = entity.avatarURL,
                      let avatarURL = URL(string: avatarURLString) else { return nil }
                return PostModel(postId: Int(entity.postId), title: title, body: body, avatarURL: avatarURL)
            }
        } catch {
            print("Error fetching posts: \(error)")
            return []
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

// MARK: - API Model
struct PostAPI: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

