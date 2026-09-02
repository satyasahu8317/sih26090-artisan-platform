import fs from 'fs';
import Groq from 'groq-sdk';

function getGroqClient() {
  if (!process.env.GROQ_API_KEY) {
    throw new Error("GROQ_API_KEY is not configured");
  }

  return new Groq({
    apiKey: process.env.GROQ_API_KEY
  });
}

const languageMap = {
  hindi: 'hi',
  english: 'en',
  tamil: 'ta',
  telugu: 'te',
  bengali: 'bn',
  marathi: 'mr',
  kannada: 'kn',
  malayalam: 'ml',
  gujarati: 'gu',
  punjabi: 'pa'
};

export const transcribeAudioFile = async (filePath) => {
  try {
    const groq = getGroqClient();
    const transcription = await groq.audio.transcriptions.create({
      file: fs.createReadStream(filePath),
      model: "whisper-large-v3-turbo",
      response_format: "verbose_json",
    });

    const detectedLang = transcription.language ? transcription.language.toLowerCase() : '';
    const mappedLang = languageMap[detectedLang] || 'unknown';

    return {
      text: transcription.text,
      language: mappedLang,
    };
  } catch (error) {
    console.error('Groq Whisper API Error:', error);
    const err = new Error(`Speech-to-text provider failed: ${error.message}`);
    err.status = 502;
    throw err;
  }
};
