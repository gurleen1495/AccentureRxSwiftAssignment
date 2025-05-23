//
//  LoginViewModel.swift
//  AccentureAssessment
//
//  Created by Gurleen kaur on 14/5/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class LoginViewModel {
    
    // Variables
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")

    // Check Validity
    var isEmailValid: Observable<(Bool, String)> {
        return email
            .map { [weak self] in self?.validateEmail($0) ?? (false, "") }
    }

    var isPasswordValid: Observable<(Bool, String)> {
        return password
            .map { [weak self] in self?.validatePassword($0) ?? (false, "") }
    }

    var isEnableLogin: Observable<Bool> {
        return Observable.combineLatest(isEmailValid, isPasswordValid)
            .map { $0.0 && $1.0 }
            .distinctUntilChanged()
    }

    // MARK: - Validation Functions
    private func validateEmail(_ email: String) -> (Bool, String) {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, Constants.Strings.kEnterEmail)
        }

        let emailTest = NSPredicate(format: Constants.Strings.kEmailFormat, Constants.Strings.kEmailRegX)
        let result = emailTest.evaluate(with: email)
        return result ? (true, Constants.Strings.kEmptyString) : (false, Constants.Strings.kEnterValidEmail)
    }

    private func validatePassword(_ password: String) -> (Bool, String) {
        let trimmed = password.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            return (false, Constants.Strings.kEnterPassword)
        }

        if trimmed.count > 15 {
            return (false, Constants.Strings.kEnterPasswordNotMoreThan15)
        }

        if trimmed.count < 8 {
            return (false, Constants.Strings.kEnterPasswordNotLessThan8)
        }

        return (true, Constants.Strings.kEmptyString)
    }
}
