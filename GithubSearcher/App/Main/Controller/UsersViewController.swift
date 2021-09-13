//
//  UsersViewController.swift
//  GithubSearcher
//
//  Created by Jiang on 26/07/2021.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift

class UsersViewController: BaseViewController {
    @IBOutlet weak var tblUsers: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var users = BehaviorRelay<[User]>(value: [])
    fileprivate var allUsers = [User]()

    override func configureUI() {
        super.configureUI()
        
        self.title = "GitHub Searcher"
        
        UserCell.registerWithNib(to: tblUsers)
    }
    
    override func setupRx() {
        super.setupRx()
        
        users.bind(to: tblUsers.rx.items(cellIdentifier: UserCell.identifier, cellType: UserCell.self)) { row, user, cell in
            cell.reset(user)
        }.disposed(by: disposeBag)
        
        tblUsers.rx.modelSelected(User.self).asSignal().debug().emit(onNext: { user in
            self.showUserDetail(user)
        }).disposed(by: disposeBag)
        tblUsers.rx.didScroll
            .subscribe(onNext: {
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        self.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { query in
                self.loadUsers(query)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppearFirstTime() {
        super.viewWillAppearFirstTime()
        loadUsers()
    }
    
    fileprivate func loadUsers(_ searchKey:String? = nil) {
        User.get(searchKey).observeOn(MainScheduler.asyncInstance).subscribe { users in
            self.usersLoaded(users)
        } onError: { [weak self] error in
            self?.isLoading = false
        }.disposed(by: disposeBag)
    }
    
    fileprivate func usersLoaded(_ users: [User]) {
        self.allUsers = users
        self.users.accept(users)
    }
    
    func showUserDetail(_ user:User) {
        guard let controller = UIManager.loadViewController(storyboard: "Main", controller: "sid_user_details") as? UserDetailsViewController else {
            return
        }
        controller.user = user
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
