import prisma from '../config/db.js';

export const getMyNotifications = async (req, res, next) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json({
      success: true,
      data: notifications
    });
  } catch (error) {
    next(error);
  }
};

export const markNotificationRead = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Verify ownership
    const notification = await prisma.notification.findUnique({
      where: { id }
    });

    if (!notification) {
      res.status(404);
      throw new Error('Notification not found');
    }

    if (notification.userId !== req.user.id) {
      res.status(403);
      throw new Error('Not authorized to access this notification');
    }

    const updated = await prisma.notification.update({
      where: { id },
      data: { isRead: true }
    });

    res.status(200).json({
      success: true,
      data: updated
    });
  } catch (error) {
    next(error);
  }
};

export const markAllNotificationsRead = async (req, res, next) => {
  try {
    const result = await prisma.notification.updateMany({
      where: { 
        userId: req.user.id,
        isRead: false
      },
      data: { isRead: true }
    });

    res.status(200).json({
      success: true,
      message: `${result.count} notifications marked as read`
    });
  } catch (error) {
    next(error);
  }
};
