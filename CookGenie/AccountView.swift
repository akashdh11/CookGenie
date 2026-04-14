//
//  AccountView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import SwiftUI
import FirebaseAuth
import SwiftData

struct AccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthViewModel.self) private var viewModel
    @Environment(FirestoreService.self) private var firestoreService

    // Start Firestore listeners when the user is known
    private var uid: String? { viewModel.currentUser?.uid }

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

                Section {
                    Button(role: .destructive) {
                        viewModel.signOut(modelContext: modelContext, firestoreService: firestoreService)
                    } label: {
                        HStack {
                            Text("Sign Out")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
}
