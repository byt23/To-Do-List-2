//
//  ContentView.swift
//  To Do List
//
//  Created by BERKAY TURAN on 18.04.2026.
//

import SwiftUI
import SwiftData


@Model
class Aktivite {
    var isim: String
    var tarih: Date
    
    init(isim: String, tarih: Date = .now) {
        self.isim = isim
        self.tarih = tarih
    }
}


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Aktivite.tarih, order: .reverse) private var aktiviteler: [Aktivite]
    
    @State private var yeniAktiviteBasligi = ""
    @State private var duzenlenecekAktivite: Aktivite?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                        TextField("Aktivite ekleyin...", text: $yeniAktiviteBasligi)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    Button(action: ekle) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(yeniAktiviteBasligi.isEmpty ? .gray : .blue)
                    }
                    .disabled(yeniAktiviteBasligi.isEmpty)
                }
                .padding()

                List {
                    if aktiviteler.isEmpty {
                        ContentUnavailableView("Liste Boş", systemImage: "sparkles", description: Text("Yeni bir aktivite ekleyerek başlayın."))
                    } else {
                        Section("Mevcut Aktiviteler") {
                            ForEach(aktiviteler) { aktivite in
                                HStack {
                                    Image(systemName: "figure.run")
                                        .foregroundColor(.blue)
                                    Text(aktivite.isim)
                                    Spacer()
                                    Button {
                                        duzenlenecekAktivite = aktivite
                                    } label: {
                                        Image(systemName: "pencil.circle")
                                            .foregroundColor(.gray)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .onDelete(perform: sil)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Yapılacaklar Listesi")
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .sheet(item: $duzenlenecekAktivite) { aktivite in
                EditView(aktivite: aktivite)
            }
        }
    }
    
    func ekle() {
        let yeni = Aktivite(isim: yeniAktiviteBasligi)
        modelContext.insert(yeni)
        yeniAktiviteBasligi = ""
    }
    
    func sil(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(aktiviteler[index])
        }
    }
}

struct EditView: View {
    @Bindable var aktivite: Aktivite
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Aktivite İsmi", text: $aktivite.isim)
            }
            .navigationTitle("Düzenle")
            .toolbar {
                Button("Tamam") { dismiss() }
            }
        }
        .presentationDetents([.height(200)])
    }
}
