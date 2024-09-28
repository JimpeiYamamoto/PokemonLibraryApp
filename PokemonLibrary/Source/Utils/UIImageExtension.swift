import Foundation
import UIKit

extension UIImage {
    public static func loadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) {
        DispatchQueue.global(qos: .default).async {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            } catch {
                completion(nil)
            }
        }
    }
}
