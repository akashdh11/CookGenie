//
//  AccountView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import SwiftUI
import FirebaseAuth
import SwiftData

private extension Notification.Name {
    static let generationCountDidChange = Notification.Name("generationCountDidChange")
}

struct AccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthViewModel.self) private var viewModel
    @Environment(FirestoreService.self) private var firestoreService

    @State private var refreshToken = UUID()

    // Start Firestore listeners when the user is known
    private var uid: String? { viewModel.currentUser?.uid }
    
    private var generationCount: Int {
        guard let uid = uid else { return 0 }
        let key = "generationCount.\(uid)"
        // Access refreshToken to make this computed property reactive
        _ = refreshToken
        return UserDefaults.standard.integer(forKey: key)
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
                    StatCard(
                        icon: "fork.knife",
                        title: "Recipes Generated",
                        subtitle: "All time",
                        value: "\(generationCount)"
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
            .onReceive(NotificationCenter.default.publisher(for: .generationCountDidChange)) { _ in
                refreshToken = UUID()
            }
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
}
