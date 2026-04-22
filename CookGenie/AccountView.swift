//
//  AccountView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/25/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseAuth


struct AccountView: View {
    @Environment(AuthViewModel.self) private var viewModel
    @Environment(FirestoreService.self) private var firestoreService

    private var generationCount: Int {
        firestoreService.historyRecipes.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.accent)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.userName ?? "User")
                                .font(.headline)
                            Text(viewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Usage")) {
                    HStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 24))
                            .foregroundStyle(.accent)
                            .frame(width: 44, height: 44)
                            .background(Color("HistoryItemHighlight"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Recipes Generated")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("All time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(generationCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.signOut(firestoreService: firestoreService)
                    } label: {
                        HStack {
                            Text("Sign Out")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("HomeBackground").ignoresSafeArea())
            .navigationTitle("Account")
            .task {
                if let uid = viewModel.currentUser?.uid {
                    firestoreService.startHistoryListener(uid: uid)
                }
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
        .environment(FirestoreService())
}
