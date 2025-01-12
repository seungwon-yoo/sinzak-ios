//
//  SignupNameVC.swift
//  Sinzak
//
//  Created by Doy Kim on 2022/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

final class SignupNameVC: SZVC {
    // MARK: - Properties
    let mainView = SignupNameView()
    var viewModel: SignupNameVM
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.nameTextField.becomeFirstResponder()
    }
    
    // MARK: - Init
    
    init(viewModel: SignupNameVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
        
    // MARK: - Helpers
    override func configure() {
        bind()
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        mainView.nameTextField.rx.value
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.nameTextFieldInput(name: text)
            })
            .disposed(by: disposeBag)
        
        mainView.checkButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.viewModel.tapCheckButton()
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeignt in
                guard let self = self else { return }
                if keyboardVisibleHeignt > 0 {
                    self.mainView.nextButton.snp.updateConstraints {
                        $0.bottom.equalToSuperview().inset(keyboardVisibleHeignt + 16.0)
                    }
                    self.view.layoutIfNeeded()
                    
                } else {
                    self.mainView.nextButton.snp.updateConstraints {
                        $0.bottom.equalToSuperview().inset(24.0)
                    }
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        mainView.nextButton.rx.tap
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.viewModel.tapNextButton()
            }
            .disposed(by: disposeBag)
    }
    
    func bindOutput() {
        viewModel.isValidCheckButton
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(mainView.checkButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let doubleCheckResult = viewModel.doubleCheckResult
            .asDriver(onErrorJustReturn: .beforeCheck)

        doubleCheckResult
            .drive(onNext: { [weak self] result in
                switch result {
                case .beforeCheck:
                    self?.mainView.nameValidationLabel.text = result.info
                    
                case .success:
                    self?.mainView.nameValidationLabel.text = result.info
                    self?.mainView.nameValidationLabel.textColor = result.color
                    
                case .fail:
                    self?.mainView.nameValidationLabel.text = result.info
                    self?.mainView.nameValidationLabel.textColor = result.color
                }
            })
            .disposed(by: disposeBag)
        
        doubleCheckResult
            .map { result in
                switch result {
                case .success:
                    return true
                default:
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
            .drive(mainView.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.pushSignupGenreVC
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .bind(onNext: { owner, vc in
                owner.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
