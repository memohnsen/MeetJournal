//
//  SettingsView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/26/25.
//

import SwiftUI
import RevenueCatUI

struct SettingsView: View {
    @State private var showCustomerCenter: Bool = false
    
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Export All Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .cardStyling()
                        
                        
                        Button{
                            showCustomerCenter = true
                        } label: {
                            HStack{
                                Text("Customer Support")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .cardStyling()
                        
                        HStack{
                            Text("Submit Feedback")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .cardStyling()
                        
                        HStack{
                            Text("Leave a Review")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .cardStyling()
                        
                        HStack{
                            Text("Open Source Code on Github")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .cardStyling()
                        
                        VStack {
                            HStack {
                                Spacer()
                                Link("Privacy Policy", destination: URL(string: "https://www.meetcal.app/privacy")!)
                                Text("•")
                                Link("Terms of Use", destination: URL(string: "https://www.meetcal.app/terms")!)
                                Text("•")
                                Link("User Agreement", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                Spacer()
                            }
                            
                            Text("MeetJournal Version: \(appVersion ?? "1.0.0")")
                                .foregroundStyle(.secondary)
                                .padding(.top)
                        }
                        .font(.system(size: 14))
                        .padding(.top)
                    }
                    .padding(.top)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCustomerCenter) {
                CustomerCenterView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
