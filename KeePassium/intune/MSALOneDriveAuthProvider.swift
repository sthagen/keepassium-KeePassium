//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import IntuneMAMSwift
import KeePassiumLib
import MSAL

final class MSALOneDriveAuthProvider: OneDriveAuthProvider {
    typealias CompletionHandler = (Result<OAuthToken, RemoteError>) -> Void
    internal static let redirectURI = "msauth.com.keepassium.intune://auth"

    private let msalApplication: MSALPublicClientApplication?
    private let msalInitializationError: RemoteError?

    private static func getConfig(scope: OAuthScope) -> OneDriveAuthConfig {
        let scopes: [String]
        switch scope {
        case .fullAccess:
            scopes = [
                "user.read",
                "files.readwrite.all",
            ]
        case .appFolder:
            scopes = [
                "user.read",
                "files.readwrite.appfolder",
            ]
        }
        return OneDriveAuthConfig(redirectURI: redirectURI, scopes: scopes)
    }

    init() {
        do {
            var authority: MSALAuthority?
            if let authorityURLString = IntuneMAMSettings.aadAuthorityUriOverride, 
               let authorityURL = URL(string: authorityURLString)
            {
                authority = try MSALAADAuthority(url: authorityURL)
            }

            let authConfig = Self.getConfig(scope: .appFolder)
            let msalConfiguration = MSALPublicClientApplicationConfig(
                clientId: authConfig.clientID,
                redirectUri: authConfig.redirectURI,
                authority: authority
            )
            msalConfiguration.clientApplicationCapabilities = ["ProtApp"] 

            msalApplication = try MSALPublicClientApplication(configuration: msalConfiguration)
            msalInitializationError = nil
        } catch {
            msalApplication = nil
            msalInitializationError = RemoteError.getEquivalent(for: error)

            let nsError = error as NSError
            Diag.error("Failed to initialize MSAL [message: \(nsError.description)]")
            return
        }
    }

    func acquireToken(
        scope: OAuthScope,
        timeout: Timeout,
        presenter: UIViewController,
        completionQueue: OperationQueue,
        completion: @escaping CompletionHandler
    ) {
        guard let msalApplication else {
            Diag.warning("MSAL not initialized")
            completionQueue.addOperation { completion(.failure(self.msalInitializationError!)) }
            return
        }

        let webviewParameters = MSALWebviewParameters(authPresentationViewController: presenter)
        let authConfig = Self.getConfig(scope: scope)
        let interactiveParameters = MSALInteractiveTokenParameters(
            scopes: authConfig.scopes,
            webviewParameters: webviewParameters
        )
        msalApplication.acquireToken(with: interactiveParameters) { [weak self] result, error in
            self?.handleMSALResponse(
                result,
                error: error,
                completionQueue: completionQueue,
                completion: completion
            )
        }
    }

    func acquireTokenSilent(
        token: OAuthToken,
        timeout: Timeout,
        completionQueue: OperationQueue,
        completion: @escaping CompletionHandler
    ) {
        guard let msalApplication else {
            Diag.warning("MSAL not initialized")
            completionQueue.addOperation { completion(.failure(self.msalInitializationError!)) }
            return
        }

        guard let accountIdentifier = token.accountIdentifier else {
            let message = "Internal error: accountIdentifier is missing" 
            completionQueue.addOperation { completion(.failure(.appInternalError(message: message))) }
            return
        }
        guard let account = try? msalApplication.account(forIdentifier: accountIdentifier) else {
            return
        }
        let authConfig = Self.getConfig(scope: token.scope)
        let silentParameters = MSALSilentTokenParameters(scopes: authConfig.scopes, account: account)
        msalApplication.acquireTokenSilent(with: silentParameters) { [weak self] result, error in
            self?.handleMSALResponse(
                result,
                error: error,
                completionQueue: completionQueue,
                completion: completion
            )
        }
    }

    private func handleMSALResponse(
        _ authResult: MSALResult?,
        error: Error?,
        completionQueue: OperationQueue,
        completion: @escaping CompletionHandler
    ) {
        guard let authResult, error == nil else {
            let msalError = error!
            let mappedError = RemoteError.getEquivalent(for: msalError)
            Diag.error("Failed to acquire token [message: \(msalError.localizedDescription)]")
            completionQueue.addOperation {
                completion(.failure(mappedError))
            }
            return
        }

        guard let expiresOn = authResult.expiresOn else {
            completionQueue.addOperation {
                Diag.error("MSAL token is missing expiry date")
                completion(.failure(.misformattedResponse))
            }
            return
        }

        var oauthToken = OAuthToken(
            accessToken: authResult.accessToken,
            refreshToken: "", 
            acquired: .now,
            lifespan: expiresOn.timeIntervalSinceNow
        )
        oauthToken.accountIdentifier = authResult.account.identifier
        Diag.debug("MSAL token acquired successfully")
        completionQueue.addOperation {
            completion(.success(oauthToken))
        }
    }
}

fileprivate extension RemoteError {
    static func getEquivalent(for error: Error) -> RemoteError {
        let nsError = error as NSError
        guard nsError.domain == MSALErrorDomain else {
            return .general(error: error)
        }

        switch nsError.code {
        case MSALError.userCanceled.rawValue:
            return .cancelledByUser
        case MSALError.interactionRequired.rawValue:
            return .authorizationRequired(message: LString.titleOneDriveRequiresSignIn)
        case MSALError.serverError.rawValue:
            return .serverSideError(message: nsError.localizedDescription)
        default:
            return .general(error: error)
        }
    }
}
