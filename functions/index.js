const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { GoogleGenerativeAI } = require("@google/generative-ai");

initializeApp();

const db = getFirestore();

// Firebase CLI manages this secret — no Secret Manager SDK needed
const geminiApiKey = defineSecret("GEMINI_API_KEY");

/**
 * generateRecipe — HTTPS Callable
 * Bound to the GEMINI_API_KEY secret via Firebase CLI
 */
exports.generateRecipe = onCall(
  {
    region: "us-central1",
    secrets: [geminiApiKey],
    enforceAppCheck: false,
  },
  async (request) => {
    // 1. Auth check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in to generate a recipe.");
    }

    const uid = request.auth.uid;
    const { ingredients = [], preferences = {} } = request.data;

    if (!ingredients || ingredients.length === 0) {
      throw new HttpsError("invalid-argument", "Please provide at least one ingredient.");
    }

    // 2. Build prompt
    const prefLines = [];
    if (preferences.time) prefLines.push(`- Cooking time: ${preferences.time}`);
    if (preferences.diet) prefLines.push(`- Diet: ${preferences.diet}`);
    if (preferences.allergy) prefLines.push(`- Avoid (allergy): ${preferences.allergy}`);
    if (preferences.goal) prefLines.push(`- Goal: ${preferences.goal}`);
    if (preferences.dishType) prefLines.push(`- Dish type: ${preferences.dishType}`);

    const preferenceBlock = prefLines.length > 0
      ? `\n\nUser preferences:\n${prefLines.join("\n")}`
      : "";

    const prompt = `You are a professional chef assistant. Generate a recipe using the following ingredients.

Ingredients available: ${ingredients.join(", ")}${preferenceBlock}

Respond with ONLY a valid JSON object in this exact format (no markdown, no code blocks, just raw JSON):
{
  "title": "Recipe Name",
  "description": "A short enticing description (2-3 sentences).",
  "cookingTime": "25 Min",
  "difficulty": "Easy",
  "serves": 2,
  "ingredients": [
    { "name": "Ingredient Name", "quantity": "Amount + unit", "iconName": "sfSymbolName" }
  ],
  "instructions": [
    "Step one.",
    "Step two."
  ]
}

Rules:
- Use ONLY the provided ingredients plus common pantry staples (salt, pepper, oil, water).
- iconName must be a valid SF Symbol name (use "circle.fill" as a safe default).
- cookingTime format: "X Min" or "X Hr Y Min".
- difficulty must be one of: "Easy", "Medium", "Hard".
- Return ONLY the JSON. No extra text, no markdown fences.`;

    // 3. Call Gemini — key is injected by Firebase at runtime
    const genAI = new GoogleGenerativeAI(geminiApiKey.value());
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-lite" });

    let recipeData;
    try {
      const result = await model.generateContent(prompt);
      const text = result.response.text().trim();
      const jsonText = text.replace(/^```json\s*/i, "").replace(/```\s*$/i, "").trim();
      recipeData = JSON.parse(jsonText);
    } catch (err) {
      console.error("Gemini error:", err);
      throw new HttpsError("internal", "Failed to generate recipe. Please try again.");
    }

    // 4. Build + save Firestore document
    const recipeRef = db.collection("users").doc(uid).collection("recipes").doc();
    const recipeDoc = {
      id: recipeRef.id,
      title: recipeData.title ?? "Untitled Recipe",
      description: recipeData.description ?? "",
      cookingTime: recipeData.cookingTime ?? "20 Min",
      difficulty: recipeData.difficulty ?? "Easy",
      serves: recipeData.serves ?? 2,
      isFavorite: false,
      ingredients: recipeData.ingredients ?? [],
      instructions: recipeData.instructions ?? [],
      createdAt: FieldValue.serverTimestamp(),
      userId: uid,
    };

    await recipeRef.set(recipeDoc);
    console.log(`Recipe "${recipeDoc.title}" saved for user ${uid}`);

    return { recipe: recipeDoc };
  }
);
