//
//  MyProfileVC.swift
//  Sinzak
//
//  Created by Doy Kim on 2023/02/12.
//

import UIKit
import RxSwift
import RxCocoa
import SkeletonView

final class MyProfileVC: SZVC {
    // MARK: - Properties
    let viewModel: MyProfileVM
    let mainView = MyProfileView()
    let disposeBag = DisposeBag()
    var userInfo: UserInfo?
    
    init(viewModel: MyProfileVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.profileSkeletonView.isHidden = false
        view.showAnimatedSkeleton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        viewModel.fetchProfile()
    }
    // MARK: - Helpers
    override func configure() {
        view.isSkeletonable = true
        
        bind()
    }
    override func setNavigationBar() {
        super.setNavigationBar()
        let setting = UIBarButtonItem(image: UIImage(named: "setting"),
                                      style: .plain,
                                      target: nil,
                                      action: nil)
        navigationItem.rightBarButtonItem = setting
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        
        mainView.scrollView.refreshControl?.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.mainView.scrollView.refreshControl?.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .asDriver()
            .drive(
                with: self,
                onNext: { owner, _ in
                    let vc = SettingVC()
                    owner
                        .navigationController?
                        .pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.profileEditButton.rx.tap
            .asDriver()
            .drive(
                with: self,
                onNext: { owner, _ in
                    guard let profile = owner.userInfo?.profile else { return }
                    let vc = EditProfileVC(profile: profile)
                    owner
                        .navigationController?
                        .pushViewController(vc, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func bindOutput() {
        
        viewModel.userInfo
            .asDriver(onErrorRecover: { _ in .never() })
            .drive(
                with: self,
                onNext: { owner, userInfo in
                    
                    owner.mainView.configureProfile(with: userInfo.profile)
                    owner.userInfo = userInfo
                    
                    if owner.view.sk.isSkeletonActive {
                        owner.view.hideSkeleton()
                        owner.mainView.profileSkeletonView.isHidden = true
                    }
                })
            .disposed(by: disposeBag)
    }
}
