//
//  ViewController.swift
//  NewsApp
//
//  Created by Ravi Dwivedi on 27/02/23.
//

import UIKit
import SafariServices

class NewsFeedViewController: UIViewController {
    
    @IBOutlet weak var colletionView:UICollectionView!
    @IBOutlet weak var searchBar:UISearchBar!
    
    var newsCatgoryModels = [NewsFeedTabModels]()
    var selectedArr = [NewsFeedTabModels]()
    var previousSelected : IndexPath?
    var currentSelected : Int?
    var dispatchWorkItem:DispatchWorkItem? = nil
    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier:NewsTableViewCell.identifier)
        return tableView
    }()
    
    private let spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.tintColor = .label
        return spinner
    }()
    
    var newsFeedViewModel = NewsFeedViewModel()
    var articlesArray = [Articles]()
    //------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createSearchBar()
        Task{
            await getNews(query:"india")
        }
    }
    
    private func loadTabModels(){
        newsCatgoryModels = [ NewsFeedTabModels(categoryName:"Technology"),
                              NewsFeedTabModels(categoryName:"Google"),
                              NewsFeedTabModels(categoryName:"Tesla"),
                              NewsFeedTabModels(categoryName:"India"),
                              NewsFeedTabModels(categoryName:"Sports"),
                              NewsFeedTabModels(categoryName:"Cricket"),
                              NewsFeedTabModels(categoryName:"USA"),
                              NewsFeedTabModels(categoryName:"Arts"),
                              NewsFeedTabModels(categoryName:"Entertainment"),
                              NewsFeedTabModels(categoryName:"Trade"),
                              NewsFeedTabModels(categoryName:"Finance")
        ]
        
    }
    
    private func setupUI(){
        loadTabModels()
        colletionView.backgroundColor = .black
        self.title = TitleName.newsFeedTitle.rawValue
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(spinner)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print(isSearchEnable)
        setUIComponentFrames()
        
    }
    
    func setUIComponentFrames(){
        tableView.frame = CGRect(x: 0, y:colletionView.frame.size.height+230, width: view.bounds.size.width, height: view.bounds.size.height - colletionView.frame.size.height)
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = view.center
    }
    
    
    func getNews(query:String) async{
        
        if Reachability.isConnectedToNetwork() {
            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            Task{
                do{
                    let result = try await newsFeedViewModel.callNewsFeedApi(query:query)
                    if result.status == "ok" {
                        self.articlesArray.removeAll()
                        
                        if result.articles.count > 0 {
                            self.articlesArray = result.articles
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.spinner.stopAnimating()
                        }
                    }
                }
                catch let serviceError{
                    print("\(serviceError)")
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                    }
                    throw serviceError
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                let alert  = UIAlertController(title:"No Internet connection", message:"Please check your internet connection", preferredStyle: .alert)
                let action = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    //MARK:- Creating search bar
    private func createSearchBar(){
        searchBar.placeholder = "Search News"
        searchBar.showsCancelButton = true
        searchBar.delegate = self
    }
}

//MARK:- Delegate DataSource Tableview
extension NewsFeedViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else { return UITableViewCell()}
        let article = articlesArray[indexPath.row]
        cell.configure(with: article, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView .deselectRow(at: indexPath, animated: true)
        let models = articlesArray[indexPath.row]
        
        guard let url = URL(string: models.url ?? "") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220.0
    }
}

//MARK:- UISearchBarDelegate
extension NewsFeedViewController:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Do some search stuff
        //Debouance Technique
        searchBar.showsCancelButton = true
        self.dispatchWorkItem?.cancel()
        guard let text = searchBar.text, !text.isEmpty else{ return}
        print(text)
        let dispatchWorkItem = DispatchWorkItem {
            Task{
                await self.getNews(query: text)
            }
        }
        self.dispatchWorkItem = dispatchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: dispatchWorkItem)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        // self.articlesArray.removeAll()
        Task{
            await self.getNews(query:"india")
        }
    }
}

//MARK :- For Reloading the Data with New Category
extension NewsFeedViewController{
    func selectedNewsCategory(category: NewsFeedTabModels)   {
        //self.articlesArray.removeAll()
        Task{
            await self.getNews(query: category.categoryName)
        }
    }
}

//MARK:- CollectionView Delegate data Source
extension NewsFeedViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsCatgoryModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.colletionView.dequeueReusableCell(withReuseIdentifier:NewsTabCollectionViewCell.identifier, for: indexPath) as? NewsTabCollectionViewCell else {return UICollectionViewCell()}
        // To set the selected cell background color here
        if currentSelected != nil && currentSelected == indexPath.item
        {
            cell.backgroundColor = .systemRed
        }else{
            cell.backgroundColor = nil
        }
        
        let model = newsCatgoryModels[indexPath.item]
        cell.configure(with:model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if previousSelected != nil{
            if let cell = collectionView.cellForItem(at: previousSelected!){
                cell.backgroundColor = nil
            }
        }
        currentSelected = indexPath.item
        previousSelected = indexPath
        
        // For reload the selected cell
        self.colletionView.reloadItems(at: [indexPath])
        let model = newsCatgoryModels[indexPath.item]
        selectedNewsCategory(category: model)
        
    }
}

//MARK:- COllectionView Flow Layout Delegate
extension NewsFeedViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    /*
     func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
     let maxYPosition = collectionView.collectionViewLayout.collectionViewContentSize.width
     let collectionViewHeight = collectionView.bounds.height
     return CGPoint(x: 0, y: maxYPosition - collectionViewHeight)
     }
     
     */
}
