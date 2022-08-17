//
//  ContentView.swift
//  hasChanges
//
//  Created by Kyrylo Onyshchuk on 15.08.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [] ) var servers: FetchedResults<Server>
    @State private var showingAddScreen = false
    @State private var lastRefreshDate = Date.now
    @State private var refreshInProgress = false
    @State private var delayInMinutes: Float = 1
    @State private var changesDetected = false
    let exampleUrl = URL(string: "https://www.apple.com")!
        
    
    private var refreshTask: Task<Void, Error>?
    //private var delay: UInt64 = 1_000_000_000 * 60 // 1 min between refreshes
    
    var body: some View {
        NavigationView {
            List {
                ForEach(servers) { server in
                    HStack {
                        Button {
                            guard server.hasChange else { return }
                            
                            server.objectWillChange.send()
                            server.hasChange = false
                            try? moc.save()
                        } label: {
                            Circle()
                                .fill(server.hasChange ? .red : .green)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.borderless)
                        
                        VStack(alignment: .leading) {
                            Link(server.url!.absoluteString, destination: server.url!)
                                .font(.body)
                            Text("Last change: \(server.lastChange!.formatted() )")
                                .font(.footnote)
//                            Text(server.hasChange ? "true" : "false")
//                                .font(.footnote)
                        }
                    }
                    .foregroundColor(server.hasChange ? .primary : .secondary)
                }
                .onDelete(perform: delete)
            }
            //            .navigationTitle("hasChanges")
            //            .font(.subheadline)
            
            //toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    VStack {
                        Text("Last Refresh: ")
                            .font(.footnote)
                        Text("\(lastRefreshDate.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                    }
                }
                
                //                ToolbarItem(placement: .navigationBarTrailing) {
                //                    VStack {
                //                        Text("\(Int(delayInMinutes)) minutes")
                //                            .font(.footnote)
                //                        Slider(value: $delayInMinutes, in: 1...30)
                //                            .frame(width: 100)
                //                    }
                //
                //                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refresh) {
                        if refreshInProgress {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }
                    .padding()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddScreen.toggle()
                    } label: {
                        Label("Add server", systemImage: "plus")
                    }
                }
                
            }//toolbar
            .sheet(isPresented: $showingAddScreen) {
                AddServerView()
            }
        }
    }
        
    
    @MainActor private func refreshAllServers() async {
            //defer { queueRefresh() }
            
            guard servers.isEmpty == false else { return }
            
            refreshInProgress = true
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            let session = URLSession(configuration: .ephemeral)
            changesDetected = false
            
            for server in servers {
                print("Fetching \(server.url!.absoluteString)")
                print("old content is: ", server.content?.map { String(format: "%02x", $0) }.joined() ?? "nil")
                //print(server.content! as NSData)
                if let (newData, _) = try? await session.data(from: server.url!) {
                    //print("succefully fetched request")
                    if newData != server.content {
                        if server.content != nil {
                            server.objectWillChange.send()
                            //print("changes detected!")
                            changesDetected = true
                            server.hasChange = true
                        }
                        
                        server.lastChange = .now
                        server.content = newData
                    }
                }
                //print("new content is: ", server.content?.map { String(format: "%02x", $0) }.joined() ?? "nil")
            }
            
            if changesDetected {
                //NSApp.requestUserAttention(.criticalRequest)
                print("changes detected!")
                try? moc.save()
                
            }
            
            lastRefreshDate = .now
            refreshInProgress = false
            
        }
    
    public func refresh() {
        guard refreshInProgress == false else { return }
        refreshTask?.cancel()

        Task {
            await refreshAllServers()
        }
        try? moc.save()
        print("")
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            // find this book in our fetch request
            let server = servers[offset]
            
            // delete it from the context
            moc.delete(server)
        }
        
        // save the context
        try? moc.save()
    }
    
//    init() {
//        refresh()
//    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
