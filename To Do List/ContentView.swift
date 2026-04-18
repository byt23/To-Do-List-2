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
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                        
                        TextField("Aktivite ekleyin...", text: $yeniAktiviteBasligi)
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .onSubmit { ekle() }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    Button(action: ekle) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(yeniAktiviteBasligi.isEmpty ? .gray : .blue)
                    }
                    .disabled(yeniAktiviteBasligi.isEmpty)
                }
                .padding()

                List {
                    if aktiviteler.isEmpty {
                        ContentUnavailableView {
                            Label("Liste Boş", systemImage: "sparkles")
                        } description: {
                            Text("Yeni bir aktivite ekleyerek başlayın.")
                        }
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
                                            .font(.title2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: sil)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Yapılacaklar Listesi")
            .onTapGesture {
                isTextFieldFocused = false
            }
            .sheet(item: $duzenlenecekAktivite) { aktivite in
                EditView(aktivite: aktivite)
            }
        }
    }
    
    func ekle() {
        guard !yeniAktiviteBasligi.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        withAnimation {
            let yeni = Aktivite(isim: yeniAktiviteBasligi)
            modelContext.insert(yeni)
            
            yeniAktiviteBasligi = ""
            isTextFieldFocused = false
        }
        
        try? modelContext.save()
    }
    
    func sil(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(aktiviteler[index])
        }
        try? modelContext.save()
    }
}

struct EditView: View {
    @Bindable var aktivite: Aktivite
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Aktiviteyi Güncelle") {
                    TextField("İsim", text: $aktivite.isim)
                }
            }
            .navigationTitle("Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(200)])
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Aktivite.self, inMemory: true)
}
