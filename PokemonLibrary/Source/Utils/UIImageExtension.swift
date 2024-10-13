import Foundation
import UIKit

extension UIImage {
    public static func loadImageData(
        from url: URL?,
        completion: @escaping (Data?) -> Void
    ) {
        DispatchQueue.global(qos: .default).async {
            guard let url = url else {
                completion(nil)
                return 
            }
            do {
                let imageData = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    completion(imageData)
                }
            } catch {
                completion(nil)
            }
        }
    }
}
