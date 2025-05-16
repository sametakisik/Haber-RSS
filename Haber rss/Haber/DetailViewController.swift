//
//  DetailViewController.swift
//  Haber
//
//  Created by Trakya18 on 30.04.2025.
//

import UIKit


class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var imageView: UIImageView!

    
    var newsTitle: String?
    var newsDate: String?
    var newsDescription: String?
    var newsLink: String?
    
    @IBAction func openInSafari(_ sender: Any) {
        if let link = newsLink, let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }

    
    func extractImageAndText(from html: String) -> (imageUrl: String?, text: String) {
        var imageUrl: String? = nil
        var text = html

        if let imgTagRange = html.range(of: "<img[^>]*src=[\"']([^\"']+)[\"'][^>]*>", options: .regularExpression) {
            let imgTag = String(html[imgTagRange])
            
            if let srcRange = imgTag.range(of: "(?<=src=\")[^\"]+", options: .regularExpression) {
                imageUrl = String(imgTag[srcRange])
            }

            // img etiketini metinden çıkar
            text.removeSubrange(imgTagRange)
        }

        // Kalan HTML taglarını temizle (sadece düz metin kalsın)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        return (imageUrl, text.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z" // RSS formatı
        
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "tr_TR")
            outputFormatter.dateFormat = "d MMMM yyyy, HH:mm" // İstenen format
            return outputFormatter.string(from: date)
        }
        
        return dateString // Hata olursa orijinalini döndür
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.red

        titleLabel.text = newsTitle  // Başlık buraya
        dateLabel.text = newsDate
        
        imageView.layer.shadowColor = UIColor.black.cgColor
            imageView.layer.shadowOpacity = 0.3
            imageView.layer.shadowOffset = CGSize(width: 2, height: 2)
            imageView.layer.shadowRadius = 6
            imageView.layer.masksToBounds = false

        

        if let description = newsDescription {
            let result = extractImageAndText(from: description)

            // Resmi yükle
            if let imageUrlStr = result.imageUrl, let imageUrl = URL(string: imageUrlStr) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                }
                if let date = newsDate {
                    dateLabel.text = formatDate(date)
                }
            }

            // Açıklamayı TextView içinde göster
            descriptionTextView.text = result.text
        }
    }


    }
