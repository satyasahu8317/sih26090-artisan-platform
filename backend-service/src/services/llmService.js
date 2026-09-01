import Groq from 'groq-sdk';

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

export const generateStructuredCatalogue = async (text) => {
  const systemPrompt = `You are an AI catalogue assistant designed for Indian artisans and micro-entrepreneurs.

Your task is to convert an artisan's natural-language product description into a professional e-commerce catalogue.

The artisan may describe the product in Hindi, English, or another Indian language.

Extract information only from what the artisan says.

Generate:

1. Product name
2. Product category
3. Material
4. Professional product description
5. Relevant search tags

Generate the product name and description in both English and Hindi.

IMPORTANT:

Never invent facts.

Do not assume:
- material
- price
- dimensions
- weight
- origin
- certifications
- quality claims
- manufacturing process

If information is not provided, use null or "Not specified".

The description should improve the presentation of the artisan's information but must not introduce unsupported facts.

CATEGORY RULES:

1. Infer the category from the product description when sufficient information exists.
2. Select the closest matching category from the allowed list.
3. Do not return null for category.
4. If none of the categories reasonably match the product, return "Other".

Allowed categories are ONLY:
- Wood Craft
- Pottery
- Textile
- Handloom
- Embroidery
- Metal Craft
- Jewellery
- Basketry
- Leather Craft
- Painting
- Home Decor
- Other

Return ONLY valid JSON according to the schema.`;

  try {
    const response = await groq.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: systemPrompt,
        },
        {
          role: 'user',
          content: `Extract product details from this text and return it as JSON:\n\n"${text}"`,
        },
      ],
      model: 'openai/gpt-oss-120b',
      temperature: 0,
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "artisan_catalogue",
          strict: true,
          schema: {
            type: "object",
            properties: {
              productName: {
                type: "object",
                properties: {
                  en: { type: "string" },
                  hi: { type: "string" }
                },
                required: ["en", "hi"],
                additionalProperties: false
              },
              category: { 
                type: "string",
                enum: [
                  "Wood Craft",
                  "Pottery",
                  "Textile",
                  "Handloom",
                  "Embroidery",
                  "Metal Craft",
                  "Jewellery",
                  "Basketry",
                  "Leather Craft",
                  "Painting",
                  "Home Decor",
                  "Other"
                ]
              },
              material: { type: ["string", "null"] },
              description: {
                type: "object",
                properties: {
                  en: { type: "string" },
                  hi: { type: "string" }
                },
                required: ["en", "hi"],
                additionalProperties: false
              },
              tags: {
                type: "array",
                items: { type: "string" }
              }
            },
            required: ["productName", "category", "material", "description", "tags"],
            additionalProperties: false
          }
        }
      },
    });

    const content = response.choices[0]?.message?.content;
    if (!content) {
      throw new Error('No content returned from LLM');
    }

    // Since we are using strict json_schema, the response should be valid JSON
    let parsedJson;
    try {
      parsedJson = JSON.parse(content);
    } catch (error) {
      throw new Error('LLM did not return valid JSON');
    }

    return parsedJson;
  } catch (error) {
    console.error('Groq API Error:', error);
    throw new Error(`LLM generation failed: ${error.message}`);
  }
};
