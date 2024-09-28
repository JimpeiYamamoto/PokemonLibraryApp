import Foundation
import UIKit

public protocol ApiClientType {
    func request<T: Decodable>(
        url: URL,
        onSuccess: @escaping (_ data: T) -> Void,
        onError: @escaping (_ error: Error?) -> Void
    )
}

public final class ApiClient: ApiClientType {
    public func request<T: Decodable>(
        url: URL,
        onSuccess: @escaping (_ data: T) -> Void,
        onError: @escaping (_ error: Error?) -> Void
    ) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil,
                  let _ = urlResponse as? HTTPURLResponse
            else {
                onError(error)
                print("error: ", error ?? "")
                return
            }

            let decoder = JSONDecoder()
            guard let data = data else { return }
            do {
                let decoded = try decoder.decode(T.self, from: data)
                onSuccess(decoded)
            } catch {
                print("error: ", error)
                onError(error)
            }
        }

        task.resume()
    }
}

