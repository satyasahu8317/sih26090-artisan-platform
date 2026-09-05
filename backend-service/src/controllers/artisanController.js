import prisma from '../config/db.js';

export const getArtisanDashboard = async (req, res, next) => {
  try {
    const user = req.user;

    // Fetch the Artisan Profile first to get the artisanId
    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    // 1. Calculate Metrics from DB
    const productCount = await prisma.product.count({
      where: { artisanId: artisanProfile.id }
    });

    const publishedProductCount = await prisma.product.count({
      where: { 
        artisanId: artisanProfile.id,
        status: 'PUBLISHED'
      }
    });

    const pendingOrdersCount = await prisma.order.count({
      where: { 
        artisanId: artisanProfile.id,
        status: 'PENDING'
      }
    });

    const newEnquiriesCount = await prisma.enquiry.count({
      where: { 
        artisanId: artisanProfile.id,
        status: 'NEW'
      }
    });

    const unreadNotificationsCount = await prisma.notification.count({
      where: { 
        userId: user.id,
        isRead: false
      }
    });

    // 2. Fetch Recent Products (e.g., last 5)
    const recentProducts = await prisma.product.findMany({
      where: { artisanId: artisanProfile.id },
      orderBy: { createdAt: 'desc' },
      take: 5
    });

    res.status(200).json({
      success: true,
      data: {
        profile: {
          name: artisanProfile.name,
          craftType: artisanProfile.craftType,
        },
        summary: {
          productCount,
          publishedProductCount,
          pendingOrdersCount,
          newEnquiriesCount,
          unreadNotificationsCount,
        },
        recentProducts,
        latestOpportunity: null // Not implemented yet
      }
    });
  } catch (error) {
    next(error);
  }
};

export const getArtisanProfile = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: {
        artisanProfile: true
      }
    });

    if (!user || !user.artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    // Filter out sensitive fields
    const { otpHash, otpExpiresAt, otpAttempts, ...safeUser } = user;
    const { artisanProfile } = safeUser;
    delete safeUser.artisanProfile;

    res.status(200).json({
      success: true,
      data: {
        user: safeUser,
        artisanProfile: artisanProfile
      }
    });
  } catch (error) {
    next(error);
  }
};

export const getArtisanOrders = async (req, res, next) => {
  try {
    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: req.user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const { status } = req.query;
    const where = { artisanId: artisanProfile.id };
    if (status) {
      where.status = status;
    }

    const orders = await prisma.order.findMany({
      where,
      include: {
        buyer: {
          select: {
            name: true,
            businessName: true,
            businessType: true
          }
        },
        product: {
          select: {
            id: true,
            productName: true,
            imageUrl: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json({
      success: true,
      data: orders
    });
  } catch (error) {
    next(error);
  }
};

export const getArtisanEnquiries = async (req, res, next) => {
  try {
    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: req.user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const enquiries = await prisma.enquiry.findMany({
      where: { artisanId: artisanProfile.id },
      include: {
        buyer: {
          select: {
            name: true,
            businessName: true
          }
        },
        product: {
          select: {
            id: true,
            productName: true,
            imageUrl: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json({
      success: true,
      data: enquiries
    });
  } catch (error) {
    next(error);
  }
};
