//
//  RightSide.swift
//  Nudge
//
//  Created by Erik Gomez on 2/18/21.
//

import Foundation
import SwiftUI

// StandardModeRightSide
struct StandardModeRightSide: View {
    // Get the color scheme so we can dynamically change properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @EnvironmentObject var manager: PolicyManager
    
    // State variables
    @State var requireDualQuitButtons = Utils().requireDualQuitButtons()
    @State var pastRequiredInstallationDate = Utils().pastRequiredInstallationDate()
    @State var hasClickedSecondaryQuitButton = false
    @State var deferralCountUI = 0
    
    // Modal view for screenshot and device info
    @State var showSSDetail = false
    
    // Get the screen frame
    var screen = NSScreen.main?.visibleFrame
    
    // Nudge UI
    var body: some View {
        let darkMode = colorScheme == .dark
        let screenShotPath = Utils().getScreenShotPath(darkMode: darkMode)
        // Right side of Nudge
        VStack {
            // mainHeader
            VStack(alignment: .center) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        // mainHeader
                        HStack {
                            Text(getMainHeader())
                                .font(.largeTitle)
                                .minimumScaleFactor(0.5)
                                .frame(maxHeight: 25)
                                .lineLimit(1)
                        }
                        // subHeader
                        HStack {
                            Text(subHeader)
                                .font(.body)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
            }
            .frame(width: 510)
            
            // I'm kind of impressed with myself
            VStack {
                // mainContentHeader / mainContentSubHeader
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text(mainContentHeader)
                                .font(.callout)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        HStack {
                            Text(mainContentSubHeader)
                                .font(.callout)
                            Spacer()
                        }
                    }
                    Spacer()
                    // actionButton
                    Button(action: Utils().updateDevice, label: {
                        Text(actionButtonText)
                        }
                    )
                    .keyboardShortcut(.defaultAction)
                }
                .frame(width: 510, height: 50)
                
                // Horizontal line
                HStack{
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 1)
                }
                .frame(width: 510)
                
                // mainContentNote
                HStack {
                    Text(mainContentNote)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                    Spacer()
                }
                .frame(width: 510)
                
                // mainContentText
                HStack {
                    Text(mainContentText)
                        .font(.callout)
                        .font(.body)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .frame(minHeight: 125.0)
                .frame(maxHeight: 125.0)
                .frame(width: 510)
                
                HStack {
                    Spacer()
                    // screenShot
                    if FileManager.default.fileExists(atPath: screenShotPath) {
                        Button {
                            self.showSSDetail.toggle()
                        } label: {
                            Image(nsImage: Utils().createImageData(fileImagePath: screenShotPath))
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 120)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Click to zoom into screenshot".localized(desiredLanguage: getDesiredLanguage()))
                        .sheet(isPresented: $showSSDetail) {
                            ScreenShotZoom()
                        }
                        .onHover { inside in
                            if inside {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    } else {
                        if forceScreenShotIconMode() {
                            Button {
                                self.showSSDetail.toggle()
                            } label: {
                                Image("CompanyScreenshotIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 120)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Click to zoom into screenshot".localized(desiredLanguage: getDesiredLanguage()))
                            .sheet(isPresented: $showSSDetail) {
                                ScreenShotZoom()
                            }
                            .onHover { inside in
                                if inside {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                        } else {
                            Button {
                                self.showSSDetail.toggle()
                            } label: {
                                Image("CompanyScreenshotIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 120)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .hidden()
                            .help("Click to zoom into screenshot".localized(desiredLanguage: getDesiredLanguage()))
                            .sheet(isPresented: $showSSDetail) {
                                ScreenShotZoom()
                            }
                        }
                    }
                    Spacer()
                }
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(5)
            .frame(width: 550)
                
            // Bottom buttons
            HStack {
                // Separate the buttons with a spacer
                Spacer()
                #if DEBUG
                Button {
                    Utils().userInitiatedExit()
                } label: {
                    Text(primaryQuitButtonText)
                        .frame(minWidth: 35)
                }
                #endif
                
                if Utils().demoModeEnabled() || !pastRequiredInstallationDate && allowedDeferrals > self.deferralCountUI {
                    // secondaryQuitButton
                    if requireDualQuitButtons {
                        if self.hasClickedSecondaryQuitButton {
                            Button {} label: {
                                Text(secondaryQuitButtonText)
                            }
                            .hidden()
                        } else {
                            Button {
                                hasClickedSecondaryQuitButton = true
                                userHasClickedSecondaryQuitButton()
                            } label: {
                                Text(secondaryQuitButtonText)
                            }
                        }
                    } else {
                        Button {} label: {
                            Text(secondaryQuitButtonText)
                        }
                        .hidden()
                    }
                    
                    // primaryQuitButton
                    if requireDualQuitButtons {
                        if self.hasClickedSecondaryQuitButton {
                            Button {
                                Utils().userInitiatedExit()
                            } label: {
                                Text(primaryQuitButtonText)
                                    .frame(minWidth: 35)
                            }
                        } else {
                            Button {
                                hasClickedSecondaryQuitButton = true
                                userHasClickedSecondaryQuitButton()
                            } label: {
                                Text(primaryQuitButtonText)
                                    .frame(minWidth: 35)
                            }
                            .hidden()
                        }
                    } else {
                        Button {
                            Utils().userInitiatedExit()
                        } label: {
                            Text(primaryQuitButtonText)
                                .frame(minWidth: 35)
                        }
                    }
                }
            }
            .frame(width: 510)
        }
        .frame(width: 600, height: 450)
        // https://www.hackingwithswift.com/books/ios-swiftui/running-code-when-our-app-launches
        .onAppear(perform: nudgeStartLogic)
    }
}

#if DEBUG
// Xcode preview for both light and dark mode
struct StandardModeRightSidePreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(["en", "es", "fr"], id: \.self) { id in
                StandardModeRightSide().environmentObject(PolicyManager(withVersion:  try! OSVersion("11.2")))
                    .preferredColorScheme(.light)
                    .environment(\.locale, .init(identifier: id))
            }
            StandardModeRightSide().environmentObject(PolicyManager(withVersion:  try! OSVersion("11.2")))
                .preferredColorScheme(.dark)
        }
    }
}
#endif
