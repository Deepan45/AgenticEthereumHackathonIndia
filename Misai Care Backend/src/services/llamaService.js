import axios from 'axios';
const LLAMA_API_URL = 'http://147.93.96.119:30000/ask';

export async function queryLlama(prompt) {
  console.log("📡 Sending prompt to LLaMA API...");
  try {
    const res = await axios.post(LLAMA_API_URL, { prompt });
    console.log("📨 LLaMA API raw response:", res.data);

    // ✅ FIX: check and return result
    if (res.data && res.data.result) {
      return res.data.result;
    } else {
      console.warn("⚠️ Unexpected response structure from LLaMA:", res.data);
      return "No valid response from LLaMA.";
    }
  } catch (error) {
    console.error("❌ LLaMA API error:", error.message);
    return "Error reaching LLaMA service.";
  }
}

// module.exports = { queryLlama };
