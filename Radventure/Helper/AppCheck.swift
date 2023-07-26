//
//  AppChecl.swift
//  Radventure
//
//  Created by Can Duru on 21.07.2023.
//

import Foundation
import FirebaseAppCheck
import FirebaseCore


class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}
