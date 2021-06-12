//
//  LoginView.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 09.06.2021.
//

import SwiftUI
import FBSDKLoginKit
import GoogleSignIn

struct LoginView: View {
    
    private var loginManager = LoginManager()
    @AppStorage("loginStatus") private var loginStatus = LoginStatus.loggedOut
    
    var body: some View {
        VStack {
            Text("eKreative YouTube Feed")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.accentColor)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            Spacer()
            
            Text("Please login using one of these services:")
                .foregroundColor(.secondary)
            Spacer()
            
            Button(action: facebookLoginHandler) {
                Text(loginStatus == .loggedInFacebook ? "Log out" : "Login with Facebook")
            }
            .padding()
            .frame(maxWidth: 200, alignment: .center)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: 200, alignment: .center)
            .animation(Animation.default.speed(2.0))
            
            Button(action: googleLoginHandler) {
                Text(loginStatus == .loggedInGoogle ? "Log out" : "Login with Google")
            }
            .padding()
            .frame(maxWidth: 200, alignment: .center)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(Animation.default.speed(2.0))
            
            Spacer()
            
        }
    }
    
    func facebookLoginHandler() {
        if loginStatus != .loggedInFacebook {
            loginManager.logIn(permissions: ["public_profile"], from: nil) { result, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                if !(result?.isCancelled ?? true) {
                    if loginStatus == .loggedInGoogle {
                        GoogleSignInWrapper().logout()
                    }
                    loginStatus = .loggedInFacebook
                }
            }
        } else {
            loginManager.logOut()
            loginStatus = .loggedOut
        }
    }
    
    func googleLoginHandler() {
        if loginStatus != .loggedInGoogle {
            GoogleSignInWrapper().login()
        } else {
            GoogleSignInWrapper().logout()
        }
    }
}

struct GoogleSignInWrapper : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<GoogleSignInWrapper>) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<GoogleSignInWrapper>) {
        
    }
    
    func login() {
        let lastController = UIApplication.shared.rootViewController
        GIDSignIn.sharedInstance()?.presentingViewController = lastController
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func logout() {
        let lastController = UIApplication.shared.rootViewController
        GIDSignIn.sharedInstance()?.presentingViewController = lastController
        GIDSignIn.sharedInstance()?.disconnect()
        GIDSignIn.sharedInstance()?.signOut()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}
