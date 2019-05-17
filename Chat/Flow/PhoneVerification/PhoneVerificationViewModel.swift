//
//  PhoneVerificationViewModel.swift
//  Chat
//
//  Created by Vadim Koronchik on 5/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import RxSwift
import RxCocoa
import FirebaseAuth

final class PhoneVerificationViewModel: ViewModelProtocol {
    
    struct Input {
        let backButtonDidTap: AnyObserver<Void>
    }
    
    struct Output {
        let backButton: Driver<Void>
        let verificationCode = BehaviorRelay<String>(value: "")
        let authData: Observable<UserInfo>
    }
    
    let input: Input
    let output: Output
    let phoneNumber: String
    
    private let authDataSubject = PublishSubject<UserInfo>()
    private let backButtonSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        
        self.input = Input(backButtonDidTap: backButtonSubject.asObserver())
        self.output = Output(backButton: backButtonSubject.asDriver(onErrorJustReturn: ()),
                             authData: authDataSubject.asObservable())
    }
    
    func sendCode(_ code: String) {
        if let id = UserDefaults.standard.string(forKey: "authVerificationID") {
            FIRAuth.verifyPhoneNumber(verificationId: id, verificationCode: code) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let authData):
                    self?.uploadUser(authData: authData)
                }
            }
        }
    }
    
    private func uploadUser(authData: AuthDataResult) {
        let firUser = authData.user
        let imageUrl = URL(string: Constants.Firebase.Storage.profilePlaceholder)!
        let userId = firUser.uid
        let username = UIDevice.current.name.lowercased()
        let phoneNumber = firUser.phoneNumber ?? ""
        let user = UserInfo(phoneNumber: phoneNumber,
                            imageUrl: imageUrl,
                            userId: userId,
                            username: username)
        
        FIRDatabaseManager().uploadUser(user) { [weak self] (result) in
            switch result {
            case .success(let user):
                AuthService.shared.login(userId: user.userId)
                self?.authDataSubject.onNext(user)
            case .failure(let error):
                print(error)
            }
        }
    }
}
