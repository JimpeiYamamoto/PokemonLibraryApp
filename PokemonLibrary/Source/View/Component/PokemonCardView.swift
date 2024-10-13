import Foundation
import UIKit
import RxCocoa
import RxSwift

public class PokemonCardView: UIView {
    public let didLoadImage = PublishRelay<Data>()
    private let disposeBag = DisposeBag()

    public let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    public let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let spriteImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        addSubview(numberLabel)
        addSubview(nameLabel)
        addSubview(spriteImageView)

        layer.borderWidth = 3.0
        layer.borderColor = UIColor.lightGray.cgColor

        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            numberLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
        ])

        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
        ])

        NSLayoutConstraint.activate([
            spriteImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            spriteImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            spriteImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            spriteImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(number: Int, name: String, imageUrl: URL?, imageData: Data?) {
        numberLabel.text = "\(number)"
        nameLabel.text = name
        if let imageData = imageData {
            self.spriteImageView.image =  UIImage(data: imageData)
            return
        }

        UIImage.loadImageData(
            from: imageUrl
        ) { [weak self] imageData in
            guard let loadedImageData = imageData else {
                return
            }
            self?.spriteImageView.image =  UIImage(data: loadedImageData)
            self?.didLoadImage.accept(loadedImageData)
        }
    }
}
