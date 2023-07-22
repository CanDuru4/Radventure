//
//  TabBarViewController.swift
//  Radventure
//
//  Created by Can Duru on 22.06.2023.
//

//MARK: Import
import UIKit

class TabBarViewController : UITabBarController {
    
//MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = UIColor(named: "AppColor3")!
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .systemGray
        setupVCs()
    }
    
//MARK: Create ViewControllers
    func setupVCs() {
          viewControllers = [
            createNavController(for: HomeMapViewController(), title: NSLocalizedString("", comment: ""), image: UIImage(systemName: "map.fill")!.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(named: "AppColor2")!)),
            createNavController(for: ScoreboardViewController(), title: NSLocalizedString("", comment: ""), image: (UIImage(systemName: "flag.checkered.2.crossed")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(named: "AppColor2")!) ?? UIImage(systemName: "flag.filled.and.flag.crossed")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(named: "AppColor2")!) ?? UIImage(systemName: "checkerboard.rectangle")!.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(named: "AppColor2")!)))
          ]
      }
    
//MARK: Set Tabbar Items
    var i = -1
    fileprivate func createNavController(for rootViewController: UIViewController,
                                                    title: String,
                                                    image: UIImage) -> UIViewController {
          let items = ["Map", "Scoreboard"]
          i = i+1
          let navController = UINavigationController(rootViewController: rootViewController)

          navController.tabBarItem.title = items[i]
          navController.tabBarItem.image = image
          navController.navigationBar.prefersLargeTitles = false
          rootViewController.navigationItem.title = title
          return navController
      }
}
