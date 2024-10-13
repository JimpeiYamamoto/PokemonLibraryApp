import Foundation
import UIKit
import RxCocoa
import RxSwift

public final class PokemonCardViewCell: UICollectionViewCell {
    public let pokemonCardView: PokemonCardView = {
        let view = PokemonCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    static let reuseIdentifier = "pokemonCardViewCell"

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pokemonCardView)
        NSLayoutConstraint.activate([
            pokemonCardView.rightAnchor.constraint(equalTo: rightAnchor),
            pokemonCardView.leftAnchor.constraint(equalTo: leftAnchor),
            pokemonCardView.topAnchor.constraint(equalTo: topAnchor),
            pokemonCardView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        pokemonCardView.numberLabel.text = ""
        pokemonCardView.nameLabel.text = ""
        pokemonCardView.spriteImageView.image = nil
    }
}
