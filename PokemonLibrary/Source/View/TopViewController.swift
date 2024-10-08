import UIKit
import RxSwift
import RxRelay
import RxCocoa

public final class TopViewController: UIViewController {

    let viewStream: ViewStream
    let disposeBag = DisposeBag()

    public init(viewStream: ViewStream) {
        self.viewStream = viewStream
        super.init(nibName: nil, bundle: nil)

        viewStream.output.pokemonCards
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                var snapshot = NSDiffableDataSourceSnapshot<TopViewDataModel.Section, TopViewDataModel.Item>()
                snapshot.deleteAllItems()
                snapshot.appendSections([.identity])
                snapshot.appendItems(result, toSection: .identity)
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .disposed(by: disposeBag)

        viewStream.output.isLoadingViewHidden
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isHidden in
                self?.loadingView.isHidden = isHidden
            }
            .disposed(by: disposeBag)

        collectionView.rx.contentOffset
            .map { [weak self] _ -> [IndexPath] in
                self?.collectionView.indexPathsForVisibleItems ?? []
            }
            .subscribe { viewStream.input.didScrollCollectionView.accept($0) }
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.register(PokemonCardViewCell.self, forCellWithReuseIdentifier: PokemonCardViewCell.reuseIdentifier)
        return view
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<TopViewDataModel.Section, TopViewDataModel.Item>(
        collectionView: collectionView
    ) { collectionView, indexPath, itemIdentifier in

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PokemonCardViewCell.reuseIdentifier,
            for: indexPath
        ) as? PokemonCardViewCell

        cell?.configure(
            number: itemIdentifier.number,
            name: itemIdentifier.name,
            imageUrl: itemIdentifier.imageUrl
        )
        return cell
    }

    private lazy var collectionViewLayout = UICollectionViewCompositionalLayout { section, environment in

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 1,
            leading: 1,
            bottom: 1,
            trailing: 1
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

        view.addSubview(collectionView)
        collectionView.dataSource = dataSource
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 100),
            loadingView.widthAnchor.constraint(equalToConstant: 100),
        ])

//        viewStream.input.viewDidLoad.accept(())
    }
}

public enum TopViewDataModel {
    enum Section {
        case identity
    }

    struct Item: Hashable {
        private let offset: Int
        let number: Int
        let name: String
        let imageUrl: URL?

        public init(offset: Int, number: Int, name: String, imageUrl: URL?) {
            self.offset = offset
            self.number = number
            self.name = name
            self.imageUrl = imageUrl
        }
    }
}
