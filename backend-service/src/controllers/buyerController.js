import prisma from '../config/db.js';
import { z } from 'zod';

const updateBuyerSchema = z.object({
  name: z.string().min(1, 'Name cannot be empty').optional(),
  businessName: z.string().min(1, 'Business name cannot be empty').optional(),
  businessType: z.string().min(1, 'Business type cannot be empty').optional(),
  state: z.string().min(1, 'State cannot be empty').optional(),
  district: z.string().min(1, 'District cannot be empty').optional(),
}).strict();

/**
 * PATCH /api/v1/buyers/me
 * Update the authenticated buyer's own profile.
 */
export const updateBuyerProfile = async (req, res, next) => {
  try {
    if (req.user.role !== 'BUYER') {
      res.status(403);
      throw new Error('Only buyers can update buyer profiles');
    }

    const buyerProfile = await prisma.buyerProfile.findUnique({
      where: { userId: req.user.id },
    });

    if (!buyerProfile) {
      res.status(404);
      throw new Error('Buyer profile not found');
    }

    const data = updateBuyerSchema.parse(req.body);

    if (Object.keys(data).length === 0) {
      res.status(400);
      throw new Error('No valid fields provided for update');
    }

    const updated = await prisma.buyerProfile.update({
      where: { id: buyerProfile.id },
      data,
    });

    res.status(200).json({ success: true, data: updated });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        message: `Validation error: ${error.issues.map((e) => e.message).join(', ')}`,
      });
    }
    next(error);
  }
};
