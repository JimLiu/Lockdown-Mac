//
//  BlockListsView.swift
//  Lockdown
//
//  Created by Johnny Lin on 12/6/19.
//  Copyright © 2019 Confirmed, Inc. All rights reserved.
//

import SwiftUI

struct BlockListsView: View {
    
    @State private var newDomain: String = ""
    
    var blockLists: [BlockList] = getLockdownBlockLists()
    @State var customBlockedDomains: [CustomBlockedDomain] = getCustomBlockedDomains()
    
    var body: some View {

        VStack(spacing: 0.0) {
            VStack {
                Text("Block Lists")
                    .font(cFontHeader2)
                    .padding(.vertical, 10)
                Text("Block all your apps from connecting to the domains and sites below. For your convenience, Lockdown also has pre-configured suggestions.")
                    .font(cFontRegular)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 12)
            }
            
            Divider()
                .padding(.vertical, 0)
            
            HStack(spacing: 0.0) {
                
                VStack(spacing: 0.0) {
                    Text("Suggested Defaults")
                    .font(cFontTitle)
                    .padding(.vertical, 10)
                    List (blockLists, id: \.name) { blockList in
                        BlockListRow(blockList: blockList)
                    }
                }
                
                Divider()
                
                VStack(spacing: 0.0) {
                    Text("Custom Domains")
                    .font(cFontTitle)
                    .padding(.vertical, 10)
                    HStack {
                        TextField("New Blocked Domain (e.g, google.com)", text: $newDomain, onCommit: {
                            // TODO: url checking
                            self.addDomain()
                        })
                        Button(action: {
                            self.addDomain()
                        }) {
                            Text("Add")
                            .font(cFontSmall)
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)
                    List (getCustomBlockedDomains().enumerated().map({ $0 }), id: \.element.domain) { index, customDomain in
                        VStack (alignment: .leading, spacing: 0.0) {
                            HStack {
                                Text(customDomain.domain)
                                .font(cFontTitle)
                                .multilineTextAlignment(.leading)
                                    .padding(.leading, 7.0)
                                .padding(.vertical, 0)
                                Spacer()
                                Button(
                                    action: {
                                        setUserBlockedDomain(domain: customDomain.domain, enabled: !customDomain.enabled)
                                        FirewallController.shared.restart()
                                }) {
                                    Text(customDomain.enabled ? "Blocked" : "Not Blocked")
                                    .font(cFontSmall)
                                }
                                Button(action: {
                                    deleteUserBlockedDomain(domain: customDomain.domain)
                                    self.customBlockedDomains.remove(at: index)
                                    FirewallController.shared.restart()
                                }) {
                                    Text("×")
                                        .padding(.bottom, 2)
                                        .foregroundColor(Color(NSColor.labelColor))
                                        .frame(width: 16, height: 16)
                                }
                                .frame(width: 16, height: 16)
                                .buttonStyle(GrayButtonStyle())
                                .opacity(0.3)
                                .cornerRadius(8)
                            }
                            .padding(.bottom, 8)
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(width: viewWidth * 1.9, height: viewHeight * 2/3)
    }
    
    func addDomain() {
        if self.newDomain.count > 0 {
            self.customBlockedDomains.append(CustomBlockedDomain(domain: self.newDomain.lowercased(), enabled: true))
            addUserBlockedDomain(domain: self.newDomain.lowercased())
            self.newDomain = ""
            FirewallController.shared.restart()
        }
    }
    
}

struct BlockListsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BlockListsView()
        }
    }
}

struct BlockListRow: View {
    
    @State private var showDomains = false
    @State var blockList: BlockList
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0.0) {
            HStack {
                Text(blockList.lockdownGroup.name)
                .font(cFontTitle)
                .multilineTextAlignment(.leading)
                    .padding(.leading, 7.0)
                .padding(.vertical, 0)
                Spacer()
                Button(
                    action: {
                        self.blockList.lockdownGroup.enabled = !self.blockList.lockdownGroup.enabled
                        var ldDefaults = getLockdownBlockedDomains()
                        ldDefaults.lockdownDefaults[self.blockList.lockdownGroup.internalID] = self.blockList.lockdownGroup
                        defaults.set(try? PropertyListEncoder().encode(ldDefaults), forKey: kLockdownBlockedDomains)
                        FirewallController.shared.restart()
                }) {
                    Text(blockList.lockdownGroup.enabled ? "Blocked" : "Not Blocked")
                    .font(cFontSmall)
                }
                Button(action: {
                    self.showDomains.toggle()
                }) {
                    Text("?")
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color(NSColor.labelColor))
                }
                .popover(isPresented: $showDomains) {
                    DomainsModalView(showModal: self.$showDomains, title: self.blockList.lockdownGroup.name, blockListDomains: self.blockList.lockdownGroup.domains.keys.sorted())
                }
                .frame(width: 16, height: 16)
                .buttonStyle(GrayButtonStyle())
                .opacity(0.3)
                .cornerRadius(8)
            }
            .padding(.bottom, 8)
            Divider()
        }
    }
    
}

#if DEBUG
struct BlockListRow_Previews: PreviewProvider {
    static var previews: some View {
        BlockListRow(blockList: BlockList(name: "Doop", lockdownGroup: LockdownGroup(version: 1, internalID: "doop", name: "Doop List", iconURL: "", enabled: true, domains: [:], ipRanges: [:])))
    }
}
#endif
