//
//  AddServerView.swift
//  hasChanges
//
//  Created by Kyrylo Onyshchuk on 15.08.2022.
//

import SwiftUI

struct AddServerView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var url = "https://www.hackingwithswift.com/example.txt"
    @State private var showingError = false
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextEditor(text: $url)
                    .frame(minHeight: 60)
                        .navigationTitle("Server URL:")
                    
//                        .onSubmit {
//                            save()
//                        }
//                    HStack {
//                        //Spacer()
//
//                        Button("Cancel", action: close)
//                            .keyboardShortcut(.cancelAction)
//
//                        Button("Save", action: save)
//                            .keyboardShortcut(.defaultAction)
//                    }
                    
                }
                Section {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                }
            }
            
            .alert("Invalid URL", isPresented: $showingError) {
                
            } message: {
                Text("Please make sure your URL starts with https:// so we can fetch its data correctly.")
            }
            .navigationTitle("Add server") //form
        }
    }
    
    func save() {
        guard url.hasPrefix("https://") else {
            showingError.toggle()
            return
        }
        
        let newServer = Server(context: moc)
        newServer.id = UUID()
        newServer.url = URL(string: url)
        newServer.lastChange = .now
        newServer.hasChange = false
        try? moc.save()
    }
    
    func close() {
        dismiss()
    }
}

struct AddServerView_Previews: PreviewProvider {
    static var previews: some View {
        AddServerView()
    }
}
