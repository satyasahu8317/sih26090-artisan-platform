import prisma from '../config/db.js';
import { z } from 'zod';

const localizedStringSchema = z.object({
  en: z.string().min(1, 'English text is required'),
  hi: z.string().min(1, 'Hindi text is required')
});

const createProductSchema = z.object({
  productName: localizedStringSchema,
  category: z.string().min(1, 'Category is required'),
  material: z.string().optional().nullable(),
  description: localizedStringSchema,
  tags: z.array(z.string()).default([]),
  imageUrl: z.string().url().optional().nullable(),
  status: z.enum(['DRAFT', 'PUBLISHED']).default('DRAFT')
});

export const getMyProducts = async (req, res, next) => {
  try {
    const user = req.user;

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const products = await prisma.product.findMany({
      where: { artisanId: artisanProfile.id },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json({
      success: true,
      data: products
    });
  } catch (error) {
    next(error);
  }
};

export const createProduct = async (req, res, next) => {
  try {
    const user = req.user;

    // Verify user is ARTISAN
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can create products');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    // Validate request body
    const validatedData = createProductSchema.parse(req.body);

    // Create the product in the database
    const newProduct = await prisma.product.create({
      data: {
        productName: validatedData.productName,
        category: validatedData.category,
        material: validatedData.material,
        description: validatedData.description,
        tags: validatedData.tags,
        imageUrl: validatedData.imageUrl,
        status: validatedData.status,
        artisanId: artisanProfile.id // Explicitly backend-controlled
      }
    });

    res.status(201).json({
      success: true,
      data: newProduct
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        message: `Validation error: ${error.issues.map(e => e.message).join(', ')}`
      });
    }
    next(error);
  }
};
