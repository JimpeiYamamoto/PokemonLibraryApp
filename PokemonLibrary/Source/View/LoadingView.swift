import Foundation
import UIKit

public final class LoadingView: UIView {

    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(activityIndicator)
        backgroundColor = UIColor(white: 1, alpha: 0.7)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
