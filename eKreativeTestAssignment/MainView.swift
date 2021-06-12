//
//  ContentView.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 09.06.2021.
//

import SwiftUI
import FBSDKLoginKit
import GoogleSignIn

struct MainView: View {
    var fbLoginManager: LoginManager
    @AppStorage("loginStatus") private var loginStatus = LoginStatus.loggedOut
    var body: some View {
        NavigationView {
            if loginStatus == .loggedOut {
                LoginView()
                    .navigationBarItems(trailing: EmptyView())
            }
            else {
                YoutubeChannelView(Bundle.main.object(forInfoDictionaryKey: "YoutubeChannelURL") as! String)
                    .navigationBarItems(trailing: Button("Log out", action: signOut))
            }
        }
    }
    
    func signOut() {
        switch loginStatus {
        case .loggedInFacebook:
            fbLoginManager.logOut()
            loginStatus = .loggedOut
        case .loggedInGoogle:
            GIDSignIn.sharedInstance()?.disconnect()
            GIDSignIn.sharedInstance()?.signOut()
        default: break
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(fbLoginManager: LoginManager())
    }
}
