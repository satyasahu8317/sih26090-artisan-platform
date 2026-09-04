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
  imageUrl: z.string().url().optional().nullable(),
  // status is ignored for creation, we force DRAFT
});

const updateProductSchema = z.object({
  productName: localizedStringSchema.optional(),
  category: z.string().min(1, 'Category is required').optional(),
  material: z.string().optional().nullable(),
  description: localizedStringSchema.optional(),
  tags: z.array(z.string()).optional(),
  imageUrl: z.string().url().optional().nullable(),
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
        imageUrl: validatedData.imageUrl,
        status: 'DRAFT', // Always force DRAFT on creation
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

export const getProduct = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can access this route');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const product = await prisma.product.findFirst({
      where: {
        id: req.params.id,
        artisanId: artisanProfile.id
      }
    });

    if (!product) {
      res.status(404);
      throw new Error('Product not found or unauthorized');
    }

    res.status(200).json({
      success: true,
      data: product
    });
  } catch (error) {
    next(error);
  }
};

export const updateProduct = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can update products');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    // Verify ownership
    const existingProduct = await prisma.product.findFirst({
      where: {
        id: req.params.id,
        artisanId: artisanProfile.id
      }
    });

    if (!existingProduct) {
      res.status(404);
      throw new Error('Product not found or unauthorized');
    }

    // Validate update body
    const validatedData = updateProductSchema.parse(req.body);

    const updatedProduct = await prisma.product.update({
      where: { id: existingProduct.id },
      data: validatedData
    });

    res.status(200).json({
      success: true,
      data: updatedProduct
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

export const deleteProduct = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can delete products');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    // Verify ownership
    const existingProduct = await prisma.product.findFirst({
      where: {
        id: req.params.id,
        artisanId: artisanProfile.id
      }
    });

    if (!existingProduct) {
      res.status(404);
      throw new Error('Product not found or unauthorized');
    }

    await prisma.product.delete({
      where: { id: existingProduct.id }
    });

    res.status(200).json({
      success: true,
      message: 'Product deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

export const publishProduct = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can publish products');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    // Verify ownership
    const existingProduct = await prisma.product.findFirst({
      where: {
        id: req.params.id,
        artisanId: artisanProfile.id
      }
    });

    if (!existingProduct) {
      res.status(404);
      throw new Error('Product not found or unauthorized');
    }

    const updatedProduct = await prisma.product.update({
      where: { id: existingProduct.id },
      data: { status: 'PUBLISHED' }
    });

    res.status(200).json({
      success: true,
      data: updatedProduct
    });
  } catch (error) {
    next(error);
  }
};

export const unpublishProduct = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can unpublish products');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    // Verify ownership
    const existingProduct = await prisma.product.findFirst({
      where: {
        id: req.params.id,
        artisanId: artisanProfile.id
      }
    });

    if (!existingProduct) {
      res.status(404);
      throw new Error('Product not found or unauthorized');
    }

    const updatedProduct = await prisma.product.update({
      where: { id: existingProduct.id },
      data: { status: 'DRAFT' }
    });

    res.status(200).json({
      success: true,
      data: updatedProduct
    });
  } catch (error) {
    next(error);
  }
};
