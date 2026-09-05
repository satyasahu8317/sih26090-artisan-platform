import prisma from '../config/db.js';
import { z } from 'zod';

const createEnquirySchema = z.object({
  artisanId: z.string().uuid(),
  productId: z.string().uuid().optional(),
  message: z.string().min(1, "Message is required"),
});

const updateEnquiryStatusSchema = z.object({
  status: z.enum(['READ', 'RESPONDED', 'CLOSED']),
});

export const createEnquiry = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'BUYER') {
      res.status(403);
      throw new Error('Only buyers can create enquiries');
    }

    const buyerProfile = await prisma.buyerProfile.findUnique({
      where: { userId: user.id },
    });

    if (!buyerProfile) {
      res.status(404);
      throw new Error('Buyer profile not found');
    }

    const validatedData = createEnquirySchema.parse(req.body);

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { id: validatedData.artisanId },
      include: { user: true }
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan not found');
    }

    if (validatedData.productId) {
      const product = await prisma.product.findUnique({
        where: { id: validatedData.productId },
      });

      if (!product) {
        res.status(404);
        throw new Error('Product not found');
      }

      if (product.artisanId !== validatedData.artisanId) {
        res.status(400);
        throw new Error('Product does not belong to the specified artisan');
      }
    }

    const enquiry = await prisma.enquiry.create({
      data: {
        buyerId: buyerProfile.id,
        artisanId: validatedData.artisanId,
        productId: validatedData.productId,
        message: validatedData.message,
        status: 'NEW',
      },
    });

    // Create Notification for the artisan
    await prisma.notification.create({
      data: {
        userId: artisanProfile.userId,
        title: 'New Enquiry',
        message: `You have received a new enquiry from ${buyerProfile.name || 'a buyer'}.`,
        type: 'ENQUIRY',
        isRead: false,
      }
    });

    res.status(201).json({
      success: true,
      data: enquiry,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400);
      return res.status(400).json({
        success: false,
        message: `Validation error: ${error.issues.map(e => e.message).join(', ')}`
      });
    }
    next(error);
  }
};

export const getEnquiry = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = req.user;

    const enquiry = await prisma.enquiry.findUnique({
      where: { id },
      include: {
        buyer: {
          select: {
            id: true,
            name: true,
            businessName: true,
          }
        },
        artisan: {
          select: {
            id: true,
            name: true,
            craftType: true,
          }
        },
        product: {
          select: {
            id: true,
            productName: true,
            imageUrl: true,
          }
        },
      }
    });

    if (!enquiry) {
      res.status(404);
      throw new Error('Enquiry not found');
    }

    if (user.role === 'BUYER') {
      const buyerProfile = await prisma.buyerProfile.findUnique({
        where: { userId: user.id },
      });
      if (!buyerProfile || enquiry.buyerId !== buyerProfile.id) {
        res.status(403);
        throw new Error('You do not have permission to view this enquiry');
      }
    } else if (user.role === 'ARTISAN') {
      const artisanProfile = await prisma.artisanProfile.findUnique({
        where: { userId: user.id },
      });
      if (!artisanProfile || enquiry.artisanId !== artisanProfile.id) {
        res.status(403);
        throw new Error('You do not have permission to view this enquiry');
      }
    } else {
      res.status(403);
      throw new Error('Unauthorized role');
    }

    res.status(200).json({
      success: true,
      data: enquiry,
    });
  } catch (error) {
    next(error);
  }
};

export const updateEnquiryStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = req.user;

    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can update enquiry status');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const existingEnquiry = await prisma.enquiry.findUnique({
      where: { id },
    });

    if (!existingEnquiry) {
      res.status(404);
      throw new Error('Enquiry not found');
    }

    if (existingEnquiry.artisanId !== artisanProfile.id) {
      res.status(403);
      throw new Error('You do not have permission to update this enquiry');
    }

    const validatedData = updateEnquiryStatusSchema.parse(req.body);

    const updatedEnquiry = await prisma.enquiry.update({
      where: { id },
      data: {
        status: validatedData.status,
      },
    });

    res.status(200).json({
      success: true,
      data: updatedEnquiry,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400);
      return res.status(400).json({
        success: false,
        message: `Validation error: ${error.issues.map(e => e.message).join(', ')}`
      });
    }
    next(error);
  }
};

const addEnquiryMessageSchema = z.object({
  message: z.string().min(1, "Message cannot be empty"),
});

export const getEnquiryMessages = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = req.user;

    const enquiry = await prisma.enquiry.findUnique({
      where: { id },
      include: {
        buyer: true,
        artisan: true,
      }
    });

    if (!enquiry) {
      res.status(404);
      throw new Error('Enquiry not found');
    }

    if (user.role === 'BUYER' && enquiry.buyer.userId !== user.id) {
      res.status(403);
      throw new Error('You do not have permission to view messages for this enquiry');
    }

    if (user.role === 'ARTISAN' && enquiry.artisan.userId !== user.id) {
      res.status(403);
      throw new Error('You do not have permission to view messages for this enquiry');
    }

    const messages = await prisma.enquiryMessage.findMany({
      where: { enquiryId: id },
      orderBy: { createdAt: 'asc' },
      include: {
        sender: {
          select: {
            id: true,
            role: true,
            artisanProfile: { select: { name: true } },
            buyerProfile: { select: { name: true, businessName: true } }
          }
        }
      }
    });

    res.status(200).json({
      success: true,
      data: messages
    });
  } catch (error) {
    next(error);
  }
};

export const addEnquiryMessage = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = req.user;

    const enquiry = await prisma.enquiry.findUnique({
      where: { id },
      include: {
        buyer: true,
        artisan: true,
      }
    });

    if (!enquiry) {
      res.status(404);
      throw new Error('Enquiry not found');
    }

    let otherPartyUserId;

    if (user.role === 'BUYER' && enquiry.buyer.userId === user.id) {
      otherPartyUserId = enquiry.artisan.userId;
    } else if (user.role === 'ARTISAN' && enquiry.artisan.userId === user.id) {
      otherPartyUserId = enquiry.buyer.userId;
    } else {
      res.status(403);
      throw new Error('You do not have permission to send messages in this enquiry');
    }

    const validatedData = addEnquiryMessageSchema.parse(req.body);

    const enquiryMessage = await prisma.enquiryMessage.create({
      data: {
        enquiryId: id,
        senderId: user.id,
        message: validatedData.message,
      }
    });

    // Update enquiry status if artisan is replying to a NEW enquiry
    if (user.role === 'ARTISAN' && enquiry.status === 'NEW') {
      await prisma.enquiry.update({
        where: { id },
        data: { status: 'RESPONDED' }
      });
    }

    // Create Notification for the OTHER participant
    await prisma.notification.create({
      data: {
        userId: otherPartyUserId,
        title: 'New Enquiry Message',
        message: `You have a new message regarding an enquiry.`,
        type: 'ENQUIRY',
        isRead: false,
      }
    });

    res.status(201).json({
      success: true,
      data: enquiryMessage
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
