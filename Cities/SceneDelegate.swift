//
//  SceneDelegate.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let mapView = UIHostingController(rootView: ListOfCitiesView())

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = mapView
        self.window = window
        window.makeKeyAndVisible()
    }


}
