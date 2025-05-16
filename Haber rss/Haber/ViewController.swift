import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, XMLParserDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sourceNameLabel: UILabel!
    @IBOutlet weak var categorySegment: UISegmentedControl!

    var rssURLString: [(String, String)]? // Kategorilerin ismi ve URL'lerini tutan bir dizi
    var selectedSiteName: String?

    var newsTitles: [String] = []
    var newsDates: [String] = []
    var newsDescriptions: [String] = []
    var newsLinks: [String] = [] // <guid> içindeki linkleri tutacak


    var currentElement = ""
    var foundTitle = ""
    var foundDate = ""
    var foundDescription = ""
    var foundLink = ""
    var insideItem = false // item etiketi içinde miyiz?

    // Haberleri URL üzerinden yükleme fonksiyonu
    func loadNews(from urlString: String) {
        
        guard let url = URL(string: urlString) else {
            print("URL oluşturulamadı: \(urlString)")
            return
        }

        // Önceki verileri temizle
        newsTitles.removeAll()
        newsDescriptions.removeAll()
        newsDates.removeAll()

        print("Veri çekiliyor: \(url.absoluteString)")
        print(url)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Veri alınırken hata oluştu: \(error)")
                return
            }

            guard let data = data else {
                print("Veri alınamadı.")
                return
            }

            print("Veri başarıyla alındı, boyut: \(data.count) byte")

            let parser = XMLParser(data: data)
            parser.delegate = self

            if !parser.parse() {
                print("XML parse edilemedi.")
            } else {
                print("XML parse edildi.")
            }
        }

        task.resume()
    }

    // Kategori değiştiğinde haberleri yükle
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        // selectedSegmentIndex -1 olmadığında çalışmasını sağlıyoruz.
        if selectedIndex >= 0, let urlString = rssURLString?[selectedIndex].1 {
            loadNews(from: urlString) // Yeni haberleri yükle
            
            // TableView'u güncelle
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let backItem = UIBarButtonItem()
           backItem.title = "Geri"
           navigationItem.backBarButtonItem = backItem
        tableView.delegate = self
        tableView.dataSource = self
        sourceNameLabel.text = selectedSiteName ?? "Bilinmeyen Site"

        // Eğer rssURLString boş değilse ve içeriyorsa, ilk URL'yi alıyoruz
        if let categories = rssURLString, !categories.isEmpty {
            let urlString = categories[0].1 // İlk kategori için URL'yi alıyoruz
            loadNews(from: urlString)

            // Segmented control'ü kategorilere göre ayarla
            categorySegment.removeAllSegments()
            for (index, category) in categories.enumerated() {
                categorySegment.insertSegment(withTitle: category.0, at: index, animated: false)
            }
            categorySegment.selectedSegmentIndex = 0
        }
    }


    // MARK: - XMLParser Delegate



    func parserDidEndDocument(_ parser: XMLParser) {
        print("Bulunan Başlıklar: \(newsTitles)")
        DispatchQueue.main.async {
            self.tableView.reloadData() // Tabloyu güncelle
        }
    }


    // MARK: - TableView DataSource
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                    namespaceURI: String?, qualifiedName qName: String?,
                    attributes attributeDict: [String : String] = [:]) {
            
            currentElement = elementName
            
            if elementName == "item" {
                insideItem = true
                foundTitle = ""
                foundDescription = ""
                foundDate = ""
                foundLink = "" // item başladığında sıfırla

            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            guard insideItem else { return } // sadece item içindeyken işlem yap

            switch currentElement {
            case "title":
                foundTitle += string
            case "description":
                foundDescription += string
            case "pubDate":
                foundDate += string
            case "guid":
                foundLink += string

            default:
                break
            }
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String,
                    namespaceURI: String?, qualifiedName qName: String?) {
            
            if elementName == "item" {
                newsTitles.append(foundTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                newsDescriptions.append(foundDescription.trimmingCharacters(in: .whitespacesAndNewlines))
                newsDates.append(foundDate.trimmingCharacters(in: .whitespacesAndNewlines))
                newsLinks.append(foundLink.trimmingCharacters(in: .whitespacesAndNewlines))

                insideItem = false
            }
        }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)

        cell.textLabel?.numberOfLines = 0 // Satır sınırı yok
        cell.textLabel?.lineBreakMode = .byWordWrapping // Kelimeye göre kır

        cell.textLabel?.text = newsTitles[indexPath.row]
        return cell
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            if let indexPath = tableView.indexPathForSelectedRow,
               let detailVC = segue.destination as? DetailViewController {
                detailVC.newsTitle = newsTitles[indexPath.row]
                detailVC.newsDate = newsDates[indexPath.row]
                detailVC.newsDescription = newsDescriptions[indexPath.row]
                detailVC.newsLink = newsLinks[indexPath.row]

            }
        }
    }
}
