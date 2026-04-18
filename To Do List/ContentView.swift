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
    
    // 1. Adım: Odak durumu için bir değişken ekle
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                        
                        TextField("Aktivite ekleyin...", text: $yeniAktiviteBasligi)
                            .focused($isTextFieldFocused) // 2. Adım: TextField'ı buna bağla
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
                    // ... Liste içeriğin (aynı kalıyor)
                }
                .listStyle(.insetGrouped)
                // 3. Adım: Listeyi kaydırınca klavye kapansın
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Yapılacaklar Listesi")
            // 4. Adım: Ekranda bir yere basınca odağı kaldır (klavye kapanır)
            .onTapGesture {
                isTextFieldFocused = false
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
        isTextFieldFocused = false // Ekleme sonrası klavyeyi kapat
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
