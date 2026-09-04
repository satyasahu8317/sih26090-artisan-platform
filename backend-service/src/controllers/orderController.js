import prisma from '../config/db.js';
import { z } from 'zod';

const createOrderSchema = z.object({
  artisanId: z.string().uuid(),
  productId: z.string().uuid().optional(),
  requestedQty: z.number().int().positive(),
  unitPrice: z.number().positive().optional(),
  requiredBy: z.string().datetime().optional()
});

const partialAcceptSchema = z.object({
  acceptedQty: z.number().int().positive()
});

export const createOrder = async (req, res, next) => {
  try {
    if (req.user.role !== 'BUYER') {
      res.status(403);
      throw new Error('Only buyers can create orders');
    }

    const buyerProfile = await prisma.buyerProfile.findUnique({
      where: { userId: req.user.id }
    });

    if (!buyerProfile) {
      res.status(404);
      throw new Error('Buyer profile not found');
    }

    const { artisanId, productId, requestedQty, unitPrice, requiredBy } = createOrderSchema.parse(req.body);

    const artisan = await prisma.artisanProfile.findUnique({
      where: { id: artisanId }
    });

    if (!artisan) {
      res.status(404);
      throw new Error('Artisan not found');
    }

    if (productId) {
      const product = await prisma.product.findUnique({
        where: { id: productId }
      });
      if (!product) {
        res.status(404);
        throw new Error('Product not found');
      }
      if (product.artisanId !== artisanId) {
        res.status(400);
        throw new Error('Product does not belong to the specified artisan');
      }
    }

    const order = await prisma.order.create({
      data: {
        buyerId: buyerProfile.id,
        artisanId: artisanId,
        productId: productId,
        requestedQty,
        unitPrice,
        requiredBy: requiredBy ? new Date(requiredBy) : null,
        status: 'PENDING'
      }
    });

    await prisma.notification.create({
      data: {
        userId: artisan.userId,
        title: 'New Order Received',
        message: `You have received a new order for ${requestedQty} items.`,
        type: 'ORDER'
      }
    });

    res.status(201).json(order);
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400);
      return next(new Error(error.errors[0].message));
    }
    next(error);
  }
};

export const getOrder = async (req, res, next) => {
  try {
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        product: {
          select: { id: true, productName: true, imageUrl: true }
        },
        buyer: {
          select: { id: true, name: true, businessName: true }
        },
        artisan: {
          select: { id: true, name: true }
        }
      }
    });

    if (!order) {
      res.status(404);
      throw new Error('Order not found');
    }

    if (req.user.role === 'BUYER') {
      const buyerProfile = await prisma.buyerProfile.findUnique({ where: { userId: req.user.id } });
      if (!buyerProfile || order.buyerId !== buyerProfile.id) {
        res.status(403);
        throw new Error('You do not have permission to view this order');
      }
    } else if (req.user.role === 'ARTISAN') {
      const artisanProfile = await prisma.artisanProfile.findUnique({ where: { userId: req.user.id } });
      if (!artisanProfile || order.artisanId !== artisanProfile.id) {
        res.status(403);
        throw new Error('You do not have permission to view this order');
      }
    }

    res.status(200).json(order);
  } catch (error) {
    next(error);
  }
};

const getArtisanOrder = async (orderId, userId, res) => {
  const artisanProfile = await prisma.artisanProfile.findUnique({ where: { userId } });
  if (!artisanProfile) {
    res.status(403);
    throw new Error('Artisan profile not found');
  }

  const order = await prisma.order.findUnique({
    where: { id: orderId },
    include: { buyer: { select: { userId: true } } }
  });

  if (!order) {
    res.status(404);
    throw new Error('Order not found');
  }

  if (order.artisanId !== artisanProfile.id) {
    res.status(403);
    throw new Error('You do not have permission to update this order');
  }

  return order;
};

export const acceptOrder = async (req, res, next) => {
  try {
    if (req.user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can update orders');
    }

    const order = await getArtisanOrder(req.params.id, req.user.id, res);

    if (order.status !== 'PENDING') {
      res.status(400);
      throw new Error('Only PENDING orders can be accepted');
    }

    const totalAmount = order.unitPrice ? order.requestedQty * order.unitPrice : null;

    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: {
        status: 'ACCEPTED',
        acceptedQty: order.requestedQty,
        totalAmount
      }
    });

    await prisma.notification.create({
      data: {
        userId: order.buyer.userId,
        title: 'Order Accepted',
        message: 'Your order has been fully accepted by the artisan.',
        type: 'ORDER'
      }
    });

    res.status(200).json(updatedOrder);
  } catch (error) {
    next(error);
  }
};

export const partialAcceptOrder = async (req, res, next) => {
  try {
    if (req.user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can update orders');
    }

    const { acceptedQty } = partialAcceptSchema.parse(req.body);

    const order = await getArtisanOrder(req.params.id, req.user.id, res);

    if (order.status !== 'PENDING') {
      res.status(400);
      throw new Error('Only PENDING orders can be partially accepted');
    }

    if (acceptedQty >= order.requestedQty) {
      res.status(400);
      throw new Error('Partial quantity must be less than requested quantity');
    }

    const totalAmount = order.unitPrice ? acceptedQty * order.unitPrice : null;

    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: {
        status: 'PARTIALLY_ACCEPTED',
        acceptedQty,
        totalAmount
      }
    });

    await prisma.notification.create({
      data: {
        userId: order.buyer.userId,
        title: 'Order Partially Accepted',
        message: `Your order has been partially accepted for ${acceptedQty} items.`,
        type: 'ORDER'
      }
    });

    res.status(200).json(updatedOrder);
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400);
      return next(new Error(error.errors[0].message));
    }
    next(error);
  }
};

export const rejectOrder = async (req, res, next) => {
  try {
    if (req.user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can update orders');
    }

    const order = await getArtisanOrder(req.params.id, req.user.id, res);

    if (order.status !== 'PENDING') {
      res.status(400);
      throw new Error('Only PENDING orders can be rejected');
    }

    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: { status: 'REJECTED' }
    });

    await prisma.notification.create({
      data: {
        userId: order.buyer.userId,
        title: 'Order Rejected',
        message: 'Your order was rejected by the artisan.',
        type: 'ORDER'
      }
    });

    res.status(200).json(updatedOrder);
  } catch (error) {
    next(error);
  }
};

export const markFulfilling = async (req, res, next) => {
  try {
    if (req.user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can update orders');
    }

    const order = await getArtisanOrder(req.params.id, req.user.id, res);

    if (order.status !== 'ACCEPTED' && order.status !== 'PARTIALLY_ACCEPTED') {
      res.status(400);
      throw new Error('Order must be ACCEPTED or PARTIALLY_ACCEPTED to begin fulfilling');
    }

    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: { status: 'FULFILLING' }
    });

    await prisma.notification.create({
      data: {
        userId: order.buyer.userId,
        title: 'Order Fulfilling',
        message: 'Your order is now being fulfilled.',
        type: 'ORDER'
      }
    });

    res.status(200).json(updatedOrder);
  } catch (error) {
    next(error);
  }
};

export const markCompleted = async (req, res, next) => {
  try {
    if (req.user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can update orders');
    }

    const order = await getArtisanOrder(req.params.id, req.user.id, res);

    if (order.status !== 'FULFILLING') {
      res.status(400);
      throw new Error('Order must be FULFILLING to be marked as COMPLETED');
    }

    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: { status: 'COMPLETED' }
    });

    await prisma.notification.create({
      data: {
        userId: order.buyer.userId,
        title: 'Order Completed',
        message: 'Your order has been completed.',
        type: 'ORDER'
      }
    });

    res.status(200).json(updatedOrder);
  } catch (error) {
    next(error);
  }
};
