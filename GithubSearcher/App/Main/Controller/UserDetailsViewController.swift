//
//  UserDetailsViewController.swift
//  GithubSearcher
//
//  Created by Jiang on 27/07/2021.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift
import SafariServices

class UserDetailsViewController: BaseViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var joinDateLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblRepos: UITableView!
    
    var user:User?
    
    fileprivate var repos = BehaviorRelay<[Repository]>(value: [])
    fileprivate var allRepos = [Repository]()
    
    
    
    override func configureUI() {
        super.configureUI()
        
        RepoCell.registerWithNib(to: tblRepos)
        
        guard let user = self.user else { return }
        guard let username = user.username else { return }
        
        API.shared.showHudEnabled = false
        User.getDetails(username).observeOn(MainScheduler.asyncInstance).subscribe { user in
            API.shared.showHudEnabled = true
            
            self.logoImageView.loadImage(url: user.avatar_url)
            self.nameLbl.text = user.name
            self.emailLbl.text = user.email
            self.locationLbl.text = user.location
            self.joinDateLbl.text = user.createdAt?.string(withFormat: "EEE, dd MMM yyyy")
            self.followersLbl.text = "\(user.followers ?? 0) Followers"
            self.followingLbl.text = "Following \(user.following ?? 0)"
            self.bioLbl.text = user.bio
            
        } onError: { _ in
            API.shared.showHudEnabled = true
        }.disposed(by: disposeBag)
        
        
        loadRepos(user.username)
    }
    
    
    override func setupRx() {
        super.setupRx()
        
        repos.bind(to: tblRepos.rx.items(cellIdentifier: RepoCell.identifier, cellType: RepoCell.self)) { row, repo, cell in
            cell.reset(repo)
        }.disposed(by: disposeBag)
        
        tblRepos.rx.modelSelected(Repository.self).asSignal().debug().emit(onNext: { repo in
            self.showRepoDetail(repo)
        }).disposed(by: disposeBag)
        
        self.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { query in
                guard !query.isEmpty else {
                    self.repos.accept(self.allRepos)
                    return
                }
                
                self.repos.accept(self.allRepos.filter({$0.name?.lowercased().contains(query.lowercased()) == true}))
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func loadRepos(_ username:String?) {
        guard let username = username else { return }
        Repository.get(username).observeOn(MainScheduler.asyncInstance).subscribe { repos in
            self.reposLoaded(repos)
        } onError: { [weak self] error in
            self?.isLoading = false
        }.disposed(by: disposeBag)
    }
    
    fileprivate func reposLoaded(_ repos: [Repository]) {
        self.allRepos = repos
        self.repos.accept(repos)
    }
    
    func showRepoDetail(_ repo:Repository) {
        if let url = repo.html_url {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
}
