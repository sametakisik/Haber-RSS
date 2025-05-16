//
//  SourceSelectorViewController.swift.swift
//  Haber
//
//  Created by Trakya4 on 2.05.2025.
//

import UIKit

class SourceSelectorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let sources = [
        ("TRT Haber", [
            ("Gündem", "https://www.trthaber.com/gundem_articles.rss"),
            ("Dünya", "https://www.trthaber.com/dunya_articles.rss"),
            ("Ekonomi", "https://www.trthaber.com/ekonomi_articles.rss"),
            ("Spor", "https://www.trthaber.com/spor_articles.rss"),
            ("Sağlık", "https://www.trthaber.com/saglik_articles.rss")
        ], "trt_logo"),

        ("Hürriyet", [
            ("Spor", "https://www.hurriyet.com.tr/rss/spor"),
            ("Magazin", "https://www.hurriyet.com.tr/rss/magazin")
        ], "hurriyet_logo"),
        
        ("Sabah", [
            ("Gündem", "https://www.sabah.com.tr/rss/gundem.xml"),
            ("Dünya", "https://www.sabah.com.tr/rss/dunya.xml"),
            ("Ekonomi", "https://www.sabah.com.tr/rss/ekonomi.xml"),
            ("Spor", "https://www.sabah.com.tr/rss/spor.xml"),
            ("Sağlık", "https://www.sabah.com.tr/rss/saglik.xml")
        ], "sabah_logo")
    ]



    @IBOutlet weak var tableView: UITableView!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNews" {
            if let destinationVC = segue.destination as? ViewController {
                destinationVC.selectedSiteName = "TRT Haber" // Örnek
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SourceCell", for: indexPath)
        
        let source = sources[indexPath.row]
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = UIImage(named: source.2) // logo adı
        }

        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = source.0
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSource = sources[indexPath.row]
        let selectedSourceName = selectedSource.0
        let selectedSourceURL = selectedSource.1

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let newsVC = storyboard.instantiateViewController(withIdentifier: "NewsVC") as? ViewController {
            newsVC.selectedSiteName = selectedSourceName
            newsVC.rssURLString = selectedSourceURL // ← burası artık [(String, String)] tipinde olmalı
        // ZATEN VAR

            let navController = UINavigationController(rootViewController: newsVC)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        }

    }


}
