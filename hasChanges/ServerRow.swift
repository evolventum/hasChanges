//
//  ServerRow.swift
//  hasChanges
//
//  Created by Kyrylo Onyshchuk on 15.08.2022.
//

import SwiftUI

struct ServerRow: View {
    @Environment(\.managedObjectContext) var moc
    let server: Server
    @State private var serverHasChanged = false
    
    var body: some View {
        HStack {
            Button {
                acknowledgeChanges(for: server)
                //testChanges(for: server)
            } label: {
                Circle()
                    .fill(serverHasChanged ? .red : .green)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
            
            VStack(alignment: .leading) {
                Link(server.url!.absoluteString, destination: server.url!)
                    .font(.body)
                Text("Last change: \(server.lastChange!.formatted() )")
                    .font(.footnote)
                Text(serverHasChanged ? "true" : "false")
                    .font(.footnote)
            }
        }
    }
    
    func acknowledgeChanges(for server: Server) {
        if server.hasChange {
            serverHasChanged = true
            print(server.hasChange ? "true" : "false")
        } else {
            print(server.hasChange ? "true" : "false")
            serverHasChanged = false
            server.objectWillChange.send()
            try? moc.save()
            return
        }
        
        server.objectWillChange.send()
        server.hasChange = false
        try? moc.save()
    }
}
