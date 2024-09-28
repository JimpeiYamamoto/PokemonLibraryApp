import Foundation
import UIKit

public final class PokemonCardViewCell: UICollectionViewCell {
    static let reuseIdentifier = "pokemonCardViewCell"

    private lazy var containerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerView, spriteImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fill
        view.alignment = .center
        view.layer.cornerRadius = 8.0
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.red.cgColor
        return view
    }()

    private lazy var headerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [numberLabel, nameLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 4
        view.distribution = .fill
        view.alignment = .center
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 40),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let spriteImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
        ])

        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4),
            headerView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -4),
            headerView.heightAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            numberLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 4),
            numberLabel.heightAnchor.constraint(equalToConstant: 40),
            numberLabel.widthAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            spriteImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4),
            spriteImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -4),
            spriteImageView.heightAnchor.constraint(equalTo: spriteImageView.widthAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(number: String, name: String, imageUrl: URL) {
        numberLabel.text = number
        nameLabel.text = name

        UIImage.loadImage(
            from: imageUrl
        ) { [spriteImageView] image in
            spriteImageView.image = image
        }
    }
}
