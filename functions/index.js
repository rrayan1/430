const functions = require("firebase-functions");
const axios = require("axios");

exports.getDoctorRecommendation = functions.https.onCall(async (data, context) => {
  const prompt = data.prompt;

  // ✅ Add validation to avoid undefined errors
  if (!prompt || typeof prompt !== "string") {
    console.error("❌ Invalid or missing prompt.");
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The function must be called with a string "prompt".'
    );
  }

  try {
    const response = await axios.post(
      "https://api.cohere.ai/v1/generate",
      {
        model: "command",
        prompt: prompt,
        max_tokens: 300,
        temperature: 0.7,
      },
      {
        headers: {
          Authorization: "Bearer onIsdrG6qqVXMhNYKhCS0UTU9z9pJWPQOdR8fiW6",
          "Content-Type": "application/json",
        },
      }
    );

    console.log("✅ Cohere response:", response.data);

    return { reply: response.data.generations[0].text.trim() };
  } catch (error) {
    console.error("❌ Cohere API error:", error.response?.data || error.message);
    throw new functions.https.HttpsError('internal', 'AI call failed');
  }
});
