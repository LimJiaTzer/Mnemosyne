//
//  MnemosyneApp.swift
//  Mnemosyne
//
//  Created by Lim Jia Tzer on 6/8/25.
//

import SwiftUI

@main
struct MnemosyneApp: App {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task{
                    await openImmersiveSpace(id: "ImmersiveSpace")
                }
        }
        ImmersiveSpace(id: "ImmersiveSpace"){
            ImmersiveView()
        }
    }
}

