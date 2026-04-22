const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { GoogleGenerativeAI } = require("@google/generative-ai");

initializeApp();

const db = getFirestore();
const geminiApiKey = defineSecret("GEMINI_API_KEY");

exports.generateRecipe = onCall(
  {
    region: "us-central1",
    secrets: [geminiApiKey],
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in to generate a recipe.");
    }

    const uid = request.auth.uid;
    const { ingredients = [], preferences = {} } = request.data;

    if (!ingredients || ingredients.length === 0) {
      throw new HttpsError("invalid-argument", "Please provide at least one ingredient.");
    }

    // Promt Preparation
    const prefLines = [];
    if (preferences.time) prefLines.push(`- MAXIMUM COOKING TIME: ${preferences.time} (Strict limit)`);
    if (preferences.diet) prefLines.push(`- DIETARY RESTRICTION: Must be ${preferences.diet}`);
    if (preferences.allergy) prefLines.push(`- ALLERGY WARNING: Absolutely NO ${preferences.allergy}`);
    if (preferences.goal) prefLines.push(`- PRIMARY GOAL: Optimize for ${preferences.goal}`);
    if (preferences.dishType) prefLines.push(`- MEAL TYPE: This must be a ${preferences.dishType}`);

    const preferenceBlock = prefLines.length > 0
      ? `\n\n### MANDATORY CONSTRAINTS (DO NOT IGNORE):\n${prefLines.join("\n")}`
      : "";

    const prompt = `You are an elite professional chef assistant. 
Create a world-class recipe based on these specific ingredients: ${ingredients.join(", ")}.
${preferenceBlock}

### Requirements:
1. VALIDATION: Before generating, check if the ingredients are real edible food items. If they are gibberish (e.g., "aaa", "xyz"), non-edible objects, or random characters, do NOT create a recipe. Instead, return ONLY the "error" field in the JSON with a polite explanation.
2. The recipe MUST strictly follow all the mandatory constraints listed above.
3. Use ONLY the provided ingredients PLUS common pantry staples (salt, pepper, oil, water).
4. cookingTime MUST be in the format: "X Min" or "X Hr Y Min".
5. difficulty MUST be exactly one of: "Easy", "Medium", "Hard".
6. iconName MUST be chosen ONLY from this whitelist of valid SF Symbols:
   - Vegetables: "carrot.fill", "leaf.fill", "camera.macro", "mushroom.fill", "tree.fill" (for broccoli)
   - Fruits: "apple.logo", "strawberry.fill", "orange.fill", "lemon.fill"
   - Meat/Protein: "fish.fill", "bird.fill" (for chicken/turkey), "egg.fill", "fossil.shell.fill", "meat.fill"
   - Dairy/Liquid: "drop.fill", "cup.and.saucer.fill", "milk.fill", "bottle.condiment.fill"
   - Grains/Baking: "circle.grid.3x3.fill", "birthday.cake.fill", "muffin.fill", "croissant.fill", "bread.fill"
   - Seasoning/Spice: "flame.fill", "sparkles", "atom", "herb"
   - Meals/Prepared: "pizza.fill", "hamburger.fill", "popcorn.fill", "bowl.fill", "mug.fill", "wineglass.fill"
   - General: "fork.knife", "takeoutbag.and.cup.and.straw.fill"
   Use "fork.knife" if no specific match is found.
7. The response must be a single JSON object.

### Response Schema:
{
  "error": "String (Only if ingredients are invalid/not food. Otherwise omit this field)",
  "title": "String",
  "description": "String",
  "cookingTime": "String",
  "difficulty": "String",
  "serves": Number,
  "ingredients": [
    { "name": "String", "quantity": "String", "iconName": "String" }
  ],
  "instructions": [
    "String"
  ]
}`;

    // Init Gemini with JSON Mode
    const genAI = new GoogleGenerativeAI(geminiApiKey.value());
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash-lite",
      generationConfig: {
        responseMimeType: "application/json",
      }
    });

    let recipeData;
    try {
      const result = await model.generateContent(prompt);
      const text = result.response.text();
      recipeData = JSON.parse(text);

      if (recipeData.error) {
        throw new HttpsError("invalid-argument", recipeData.error);
      }

      console.log(`Successfully generated JSON for recipe: ${recipeData.title}`);
    } catch (err) {
      console.error("AI Generation Error:", err);
      if (err instanceof HttpsError) {
        throw err;
      }
      throw new HttpsError("internal", "Our AI chef is currently busy. Please try again in a moment.");
    }

    // Write to Firestore
    const recipeRef = db.collection("users").doc(uid).collection("recipes").doc();
    const recipeDoc = {
      id: recipeRef.id,
      title: recipeData.title || "Untitled Recipe",
      description: recipeData.description || "",
      cookingTime: recipeData.cookingTime || "30 Min",
      difficulty: recipeData.difficulty || "Medium",
      serves: recipeData.serves || 2,
      isFavorite: false,
      ingredients: recipeData.ingredients || [],
      instructions: recipeData.instructions || [],
      createdAt: FieldValue.serverTimestamp(),
      userId: uid,
    };

    await recipeRef.set(recipeDoc);

    return { recipe: recipeDoc };
  }
);
