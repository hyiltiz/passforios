//
//  CredentialProviderViewController.swift
//  passAutoFillExtension
//
//  Created by Yishi Lin on 2018/9/24.
//  Copyright © 2018 Bob Sun. All rights reserved.
//

import AuthenticationServices
import passKit

class CredentialProviderViewController: ASCredentialProviderViewController {
    var passcodelock: PasscodeExtensionDisplay {
        PasscodeExtensionDisplay(extensionContext: self.extensionContext)
    }

    var embeddedNavigationController: UINavigationController {
        children.first as! UINavigationController
    }

    var passwordsViewController: PasswordsViewController {
        embeddedNavigationController.viewControllers.first as! PasswordsViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passcodelock.presentPasscodeLockIfNeeded(self)

        let passwordsTableEntries = PasswordStore.shared.fetchPasswordEntityCoreData(withDir: false).compactMap { PasswordTableEntry($0) }
        let dataSource = PasswordsTableDataSource(entries: passwordsTableEntries)
        passwordsViewController.dataSource = dataSource
        passwordsViewController.selectionDelegate = self
    }

    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        let url = serviceIdentifiers.first.flatMap { URL(string: $0.identifier) }
        passwordsViewController.navigationItem.prompt = url?.host
    }
}

extension CredentialProviderViewController: PasswordSelectionDelegate {
    func selected(password: PasswordTableEntry) {
        let passwordEntity = password.passwordEntity

        decryptPassword(in: self, with: passwordEntity) { password in
            let username = password.getUsernameForCompletion()
            let password = password.password
            let passwordCredential = ASPasswordCredential(user: username, password: password)
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential)
        }
    }
}
