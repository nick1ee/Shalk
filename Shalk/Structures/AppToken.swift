//
//  AppToken.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/12.
//  Copyright © 2017年 nicklee. All rights reserved.
//

enum ApptokenError: Error {

    case unsupportedTokenType

}

struct AppToken {

    enum TokenType: String {

        case email

        case password

    }

    struct Schema {

        static let email = "email"

        static let password = "password"

    }

    let emailToken: String

    let pwdToken: String

    init(email: String, password: String) {

        self.emailToken = email

        self.pwdToken = password

    }

}

// MARK: - Unboxable

import Unbox

extension AppToken.TokenType: UnboxableEnum { }

extension AppToken: Unboxable {

    init(unboxer: Unboxer) throws {

        let emailToken: String = try unboxer.unbox(key: Schema.email)

        let passwordToken: String = try unboxer.unbox(key: Schema.password)

        self.init(email: emailToken, password: passwordToken)

    }

}

// MARK: - Keychain

import KeychainAccess

extension Keychain {

    // MARK: Property

    static let appToken = Keychain(service: "\(Bundle.main.bundleIdentifier!).AppToken")

}

// MARK: - KeychainConvertible

extension AppToken: KeychainExportable {

    // MARK: KeychainExportable

    func save(to keychain: Keychain) throws {

        try keychain.set(emailToken, key: Schema.email)

        try keychain.set(pwdToken, key: Schema.password)

    }

}
