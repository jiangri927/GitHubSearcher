//
//  RepoCell.swift
//  GithubSearcher
//
//  Created by 222 on 12/09/2021.
//

import UIKit

class RepoCell: BaseTableViewCell {
    override class var identifier: String {
        return "repo_cell"
    }
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var forksLbl: UILabel!
    @IBOutlet weak var starsLbl: UILabel!
    
    func reset(_ repo: Repository) {
        nameLbl.text = repo.name
        forksLbl.text = "\(repo.forks_count ?? 0) Forks"
        starsLbl.text = "\(repo.stargazers_count ?? 0) Stars"
    }
}
