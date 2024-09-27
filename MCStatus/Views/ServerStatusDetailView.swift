//
//  ServerDetailView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//

import SwiftUI
import MCStatusDataLayer
import AppIntents

//Show tip view
//Use SiriTipView
//
//SiriTipView(intent: ReorderIntent(), isVisible: $isVisible)
//    .siriTipViewStyle(.black)
//Show link to open Shortcuts app
//Use ShortcutsLink
//
//ShortcutsLink()
//     .shortcutsLinkStyle(.whiteOutline)


struct ServerStatusDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State var serverStatusViewModel: ServerStatusViewModel

    var parentViewRefreshCallBack: () -> Void
    
    
    var body: some View {
        ScrollView {
            Text("\(serverStatusViewModel.server.name)")
            Text("\(serverStatusViewModel.server.serverUrl + ":" + String(serverStatusViewModel.server.serverPort))")
            Text("\("Version: " + (serverStatusViewModel.status?.version ?? "Loading"))")
            Text("Online Players: " + String(serverStatusViewModel.status?.onlinePlayerCount ?? 0))
        }.refreshable {
            serverStatusViewModel.reloadData()
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Text("Edit")
                    }
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Label("Add Item", systemImage: "trash")
                    }
                }
            }
        }.alert("Delete Server?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            Button("Cancel", role: .cancel) { }
        }.sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditServerView(server: serverStatusViewModel.server, isPresented: $showingEditSheet) {
                    serverStatusViewModel.reloadData()
                    parentViewRefreshCallBack()
                }
            }
        }
    }
    
    private func deleteServer() {
        modelContext.delete(serverStatusViewModel.server)
        do {
            // Try to save
            try modelContext.save()
        } catch {
            // We couldn't save :(
            // Failures include issues such as an invalid unique constraint
            print(error.localizedDescription)
        }
        parentViewRefreshCallBack()
        self.presentationMode.wrappedValue.dismiss()
    }
}

