//
//  KeychainConvertible.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/12.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - KeychainInitializable

import KeychainAccess

protocol KeychainInitializable {

    // MARK: Init

    init(keychain: Keychain) throws

}

// MARK: - KeychainExportable

protocol KeychainExportable {

    func save(to keychain: Keychain) throws

}

// MARK: - KeychainConvertible

protocol KeychainConvertible: KeychainInitializable, KeychainExportable {

}

// MARK: - KeychainError

enum KeychainError: Error {

    // MARK: Property

    case missingValue(forKey: String)

}
