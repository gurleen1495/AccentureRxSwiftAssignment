//
//  LoginViewController.swift
//  AccentureAssessment
//
//  Created by Gurleen kaur on 12/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - Outlets
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var lblErrorPassword: UILabel!
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFieldEmail.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        txtFieldPassword.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        viewModel.isEmailValid
            .map { $0.1 }
            .bind(to: lblErrorEmail.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isEmailValid
            .map { $0.0 }
            .bind(to: lblErrorEmail.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isPasswordValid
            .map { $0.1 }
            .bind(to: lblErrorPassword.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isPasswordValid
            .map { $0.0 }
            .bind(to: lblErrorPassword.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isEnableLogin
            .bind(to: btnLogin.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isEnableLogin
            .map { $0 ? 1.0 : 0.5 }
            .bind(to: btnLogin.rx.alpha)
            .disposed(by: disposeBag)
        
        btnLogin.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigateToMainScreen()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Functions
    func navigateToMainScreen() {
        UserDefaults.standard.set(true, forKey: Constants.Strings.kIsLoggedIn)
        if let tabBarVC = storyboard?.instantiateViewController(withIdentifier: Constants.Identifier.kMainTabBarController) as? UITabBarController {
            tabBarVC.modalPresentationStyle = .fullScreen
            present(tabBarVC, animated: true, completion: nil)
        }
    }
    
    func errorMessage(warningText: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: Constants.Assets.kExclamationCircle)?.withTintColor(.systemRed, renderingMode: .automatic)
        let fullString = NSMutableAttributedString(attachment: attachment)
        fullString.append(NSAttributedString(string: Constants.Strings.kSpaceString))
        fullString.append(NSAttributedString(string: warningText))
        return fullString
    }
    
}
