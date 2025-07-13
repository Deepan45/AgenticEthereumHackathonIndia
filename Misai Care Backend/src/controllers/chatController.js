import { getAnswer } from '../services/chatService.js';

export async function handleChat(req, res) {
  const question = req.body.message;

  console.log("💬 Received chat request:");
  console.log("📥 Message:", question);

  if (!question) {
    console.log("❌ Missing message in request body");
    return res.status(400).json({ error: 'Message is required' });
  }

  try {
    const answer = await getAnswer(question);
    console.log("✅ LLaMA response:", answer);
    res.json({ answer });
  } catch (error) {
    console.error("🔥 Error in chatController:", error.message);
    res.status(500).json({ error: 'Something went wrong' });
  }
}

// module.exports = { handleChat };