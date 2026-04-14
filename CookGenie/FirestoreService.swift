//
//  FirestoreService.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import Foundation
import FirebaseFirestore

@Observable
final class FirestoreService {

    private let db = Firestore.firestore()
    private var historyListener: ListenerRegistration?
    private var favoritesListener: ListenerRegistration?

    var historyRecipes: [Recipe] = []
    var favoriteRecipes: [Recipe] = []
    var isLoading = false
    var error: String?

    // MARK: - Listeners

    /// Starts a real-time listener for all recipes ordered by creation date.
    func startHistoryListener(uid: String) {
        historyListener?.remove()
        historyListener = db
            .collection("users").document(uid).collection("recipes")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.error = error.localizedDescription
                    return
                }
                self.historyRecipes = snapshot?.documents.compactMap { doc in
                    Recipe(firestoreData: doc.data())
                } ?? []
            }
    }

    /// Starts a real-time listener for recipes where isFavorite == true.
    func startFavoritesListener(uid: String) {
        favoritesListener?.remove()
        favoritesListener = db
            .collection("users").document(uid).collection("recipes")
            .whereField("isFavorite", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.error = error.localizedDescription
                    return
                }
                self.favoriteRecipes = snapshot?.documents.compactMap { doc in
                    Recipe(firestoreData: doc.data())
                } ?? []
            }
    }

    /// Stops all active Firestore listeners (call on sign out).
    func stopAllListeners() {
        historyListener?.remove()
        favoritesListener?.remove()
        historyListener = nil
        favoritesListener = nil
        historyRecipes = []
        favoriteRecipes = []
    }

    // MARK: - Mutations

    /// Toggles the isFavorite flag on a recipe in Firestore.
    func toggleFavorite(uid: String, recipeId: String, isFavorite: Bool) {
        db.collection("users").document(uid)
            .collection("recipes").document(recipeId)
            .updateData(["isFavorite": isFavorite]) { error in
                if let error {
                    print("Error toggling favorite: \(error)")
                }
            }
    }
}
