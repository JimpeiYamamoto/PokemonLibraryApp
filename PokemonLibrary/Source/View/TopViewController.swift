import UIKit
import RxSwift
import RxRelay
import RxCocoa
import ViewStream

public final class TopViewController: UIViewController {

    let viewStream: TopViewStreamType
    let disposeBag = DisposeBag()

    public init(viewStream: TopViewStreamType) {
        self.viewStream = viewStream
        super.init(nibName: nil, bundle: nil)

        viewStream.output.pokemonCards
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                var snapshot = NSDiffableDataSourceSnapshot<TopViewStreamDataModel.Section, TopViewStreamDataModel.Item>()
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

        viewStream.output.tappedID
            .observe(on: MainScheduler.instance)
            .subscribe { id in
                let nextVC = DetailPokemonViewController(
                    viewStream: DetailPokemonViewStream(
                        useCase: DetailPokemonViewUseCase.shared,
                        state: .init(selectedPokemonID: .init(value: id))
                    )
                )
                nextVC.modalPresentationStyle = .fullScreen
                self.present(nextVC, animated: true)
            }
            .disposed(by: disposeBag)

        collectionView.rx.contentOffset
            .map { [weak self] _ -> [IndexPath] in
                self?.collectionView.indexPathsForVisibleItems ?? []
            }
            .subscribe { viewStream.input.didScrollCollectionView.accept($0) }
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                viewStream.input.didTapItem.accept(indexPath)
            })
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
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<TopViewStreamDataModel.Section, TopViewStreamDataModel.Item>(
        collectionView: collectionView
    ) { [weak self] collectionView, indexPath, itemIdentifier in
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PokemonCardViewCell.reuseIdentifier,
            for: indexPath
        ) as? PokemonCardViewCell

        guard let me = self,
              let _cell = cell
        else { return cell }

        _cell.pokemonCardView.configure(
            number: itemIdentifier.number,
            name: itemIdentifier.name,
            imageUrl: itemIdentifier.imageUrl,
            imageData: itemIdentifier.imageData
        )

        _cell.pokemonCardView.didLoadImage
            .map { ($0, itemIdentifier.number) }
            .bind(to: me.viewStream.input.didLoadImage)
            .disposed(by: _cell.disposeBag)

        return _cell
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
    }
}

