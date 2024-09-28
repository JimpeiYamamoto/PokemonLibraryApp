import UIKit
import PokemonAPI
import RxSwift
import RxRelay

public final class ViewController: UIViewController {

    let viewStream: ViewStream
    let disposeBag = DisposeBag()

    public init(viewStream: ViewStream) {
        self.viewStream = viewStream
        super.init(nibName: nil, bundle: nil)

        viewStream.output.nameLabelText
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                self?.nameLabel.text = result
            }
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.text = "empty"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.collectionViewLayout = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.register(PokemonCardViewCell.self, forCellWithReuseIdentifier: PokemonCardViewCell.reuseIdentifier)
        return view
    }()

    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(
        collectionView: collectionView
    ) { collectionView, indexPath, itemIdentifier in

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PokemonCardViewCell.reuseIdentifier,
            for: indexPath
        ) as? PokemonCardViewCell

        cell?.configure(number: itemIdentifier.number, name: itemIdentifier.name, imageUrl: itemIdentifier.imageUrl)
        return cell
    }

    private lazy var collectionViewLayout = UICollectionViewCompositionalLayout { section, environment in

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0/3.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        return section
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(nameLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        viewStream.input.viewDidLoad.accept(())

        let pokemonCardView = PokemonCardViewCell()
        pokemonCardView.configure(
            number: "1",
            name: "フシギダネ",
            imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!
        )
        view.addSubview(pokemonCardView)
        pokemonCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pokemonCardView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4),
            pokemonCardView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -4),
            pokemonCardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])

        collectionView.dataSource = dataSource
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.identity])
        snapshot.appendItems(
            [
                .init(
                    offset: 0,
                    number: "1",
                    name: "フシギダネ",
                    imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!
                ),
                .init(
                    offset: 1,
                    number: "1",
                    name: "フシギダネ",
                    imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!
                ),
                .init(
                    offset: 2,
                    number: "1",
                    name: "フシギダネ",
                    imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!
                ),
                .init(
                    offset: 3,
                    number: "1",
                    name: "フシギダネ",
                    imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!
                ),
            ],
            toSection: .identity
        )
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ViewController {
    enum Section {
        case identity
    }

    struct Item: Hashable {
        private let offset: Int
        let number: String
        let name: String
        let imageUrl: URL

        public init(offset: Int, number: String, name: String, imageUrl: URL) {
            self.offset = offset
            self.number = number
            self.name = name
            self.imageUrl = imageUrl
        }
    }
}
