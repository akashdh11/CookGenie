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

    @Query private var allPreferences: [UserPreferences]
    private var currentPreferences: UserPreferences? {
        guard let uid = viewModel.currentUser?.uid else { return nil }
        return allPreferences.first(where: { $0.userId == uid })
    }

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
                
                Section(header: Text("Usage")) {
                    StatCard(
                        icon: "fork.knife",
                        title: "Recipes Generated",
                        subtitle: "All time",
                        value: "\(currentPreferences?.generationCount ?? 0)"
                    )
                    .padding(.vertical, 4)
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

private struct StatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.accent)
                .frame(width: 44, height: 44)
                .background(Color("HistoryItemHighlight"))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 5)
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
        .environment(FirestoreService())
        .modelContainer(for: UserPreferences.self)
}
