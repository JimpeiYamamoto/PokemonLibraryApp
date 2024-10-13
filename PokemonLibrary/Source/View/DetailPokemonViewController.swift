import Foundation
import UIKit

public final class DetailPokemonViewController: UIViewController {

    private lazy var containerView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: [
                headerPokemonView,
                footerAbilityView,
                flavorTextView,
                UIView()
            ]
        )
        view.axis = .vertical
        view.spacing = 12.0
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        return view
    }()

    private let pokemonCardView: PokemonCardView = {
        let view = PokemonCardView()
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 1.0
        return view
    }()

    private let weightLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let heightLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var headerPokemonView: UIStackView = {
        let descriptionView = UIStackView(
            arrangedSubviews: [
                weightLabel,
                heightLabel
            ]
        )
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.axis = .vertical
        descriptionView.spacing = 12.0
        descriptionView.alignment = .center

        let containerView = UIStackView(
            arrangedSubviews: [
                pokemonCardView,
                descriptionView
            ]
        )
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .horizontal
        containerView.spacing = 8.0
        containerView.alignment = .center
        return containerView
    }()

    private let flavorTextView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.sizeToFit()
        return view
    }()

    private let footerAbilityView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8.0
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white

        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            pokemonCardView.widthAnchor.constraint(equalToConstant: 150),
            pokemonCardView.heightAnchor.constraint(equalToConstant: 150)
        ])

        NSLayoutConstraint.activate([
            headerPokemonView.heightAnchor.constraint(equalToConstant: 150),
            headerPokemonView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 32),
            headerPokemonView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -32),
        ])

        NSLayoutConstraint.activate([
            flavorTextView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 32),
            flavorTextView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -32),
            flavorTextView.topAnchor.constraint(equalTo: footerAbilityView.bottomAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            footerAbilityView.heightAnchor.constraint(equalToConstant: 35)
        ])

        let mockData = DetailPokemonViewDataModel.detailInformation(
            id: 4,
            name: "フシギバナ",
            weight: 100,
            height: 3,
            flavorText: "ほげほgへおhげおほげほげほgへおhげおほげほげほgへおhげおほげほげほgへおhげおほげほげほgへおhげおほげ",
            image: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!,
            sound: URL(string: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/1.ogg")!,
            abilities: ["ほげほげ", "ふーー", "ふがふがふが"]
        )

        pokemonCardView.configure(number: mockData.id, name: mockData.name, imageUrl: mockData.image)
        weightLabel.text = "重さ: \(mockData.weight) kg"
        heightLabel.text = "高さ: \(mockData.height) m"
        flavorTextView.text = mockData.flavorText
        mockData.abilities.forEach { text in
            let abilityView = AbilityView()
            abilityView.translatesAutoresizingMaskIntoConstraints = false
            abilityView.configure(abilityText: "  \(text)  ")
            footerAbilityView.addArrangedSubview(abilityView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}

public enum DetailPokemonViewDataModel {
    public struct detailInformation {
        public let id: Int
        public let name: String
        public let weight: Int
        public let height: Int
        public let flavorText: String
        public let image: URL
        public let sound: URL
        public let abilities: [String]
    }
}
