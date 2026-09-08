import Razorpay from 'razorpay';
import crypto from 'crypto';
import prisma from '../config/db.js';

let razorpay;
try {
  if (process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
    razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
  }
} catch (error) {
  console.error("Failed to initialize Razorpay:", error);
}

export const createPayment = async (req, res, next) => {
  try {
    const { id: orderId } = req.params;

    if (req.user.role !== 'BUYER') {
      return res.status(403).json({ success: false, message: 'Only buyers can initiate payments' });
    }

    const buyerProfile = await prisma.buyerProfile.findUnique({
      where: { userId: req.user.id }
    });

    if (!buyerProfile) {
      return res.status(404).json({ success: false, message: 'Buyer profile not found' });
    }
    const buyerId = buyerProfile.id;

    const order = await prisma.order.findUnique({
      where: { id: orderId }
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (order.buyerId !== buyerId) {
      return res.status(403).json({ success: false, message: 'Unauthorized to pay for this order' });
    }

    // Idempotency: already paid
    if (order.paymentStatus === 'SUCCESS') {
      return res.status(200).json({
        success: true,
        data: {
          orderId: order.id,
          razorpayOrderId: order.razorpayOrderId,
          amount: order.amountPaidPaise,
          currency: 'INR',
          keyId: process.env.RAZORPAY_KEY_ID,
          paymentStatus: order.paymentStatus
        }
      });
    }

    if (order.status !== 'ACCEPTED' && order.status !== 'PARTIALLY_ACCEPTED') {
      return res.status(400).json({ success: false, message: 'Only accepted orders can be paid' });
    }

    if (!order.totalAmount || order.totalAmount <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid total amount' });
    }

    const amountInPaise = Math.round(order.totalAmount * 100);

    // Idempotency: pending Razorpay order exists and amount matches
    if (order.paymentStatus === 'PENDING' && order.razorpayOrderId && order.amountPaidPaise === amountInPaise) {
      return res.status(200).json({
        success: true,
        data: {
          orderId: order.id,
          razorpayOrderId: order.razorpayOrderId,
          amount: amountInPaise,
          currency: 'INR',
          keyId: process.env.RAZORPAY_KEY_ID
        }
      });
    }

    // Need to create a new Razorpay order
    if (!razorpay) {
      return res.status(500).json({ success: false, message: 'Razorpay is not configured on the server' });
    }

    const options = {
      amount: amountInPaise,
      currency: "INR",
      receipt: `rcpt_${order.id.substring(0, 20)}`
    };

    const rzpOrder = await razorpay.orders.create(options);

    // Update the application order
    await prisma.order.update({
      where: { id: order.id },
      data: {
        razorpayOrderId: rzpOrder.id,
        amountPaidPaise: amountInPaise,
        paymentStatus: 'PENDING'
      }
    });

    return res.status(200).json({
      success: true,
      data: {
        orderId: order.id,
        razorpayOrderId: rzpOrder.id,
        amount: amountInPaise,
        currency: 'INR',
        keyId: process.env.RAZORPAY_KEY_ID
      }
    });

  } catch (error) {
    console.error("Razorpay create payment error:", error);
    next(error);
  }
};

export const verifyPayment = async (req, res, next) => {
  try {
    const { id: orderId } = req.params;
    const { razorpay_payment_id, razorpay_order_id, razorpay_signature } = req.body;

    if (req.user.role !== 'BUYER') {
      return res.status(403).json({ success: false, message: 'Only buyers can verify payments' });
    }

    if (!razorpay_payment_id || typeof razorpay_payment_id !== 'string' ||
        !razorpay_order_id || typeof razorpay_order_id !== 'string' ||
        !razorpay_signature || typeof razorpay_signature !== 'string') {
      return res.status(400).json({ success: false, message: 'Missing or invalid payment verification fields' });
    }

    const buyerProfile = await prisma.buyerProfile.findUnique({
      where: { userId: req.user.id }
    });

    if (!buyerProfile) {
      return res.status(404).json({ success: false, message: 'Buyer profile not found' });
    }
    const buyerId = buyerProfile.id;

    const order = await prisma.order.findUnique({
      where: { id: orderId }
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (order.buyerId !== buyerId) {
      return res.status(403).json({ success: false, message: 'Unauthorized to verify this order' });
    }

    // Idempotency: if already success, verify consistency
    if (order.paymentStatus === 'SUCCESS') {
      if (order.razorpayOrderId !== razorpay_order_id) {
         return res.status(400).json({ success: false, message: 'Razorpay Order ID mismatch for already successful order' });
      }
      if (order.razorpayPaymentId && order.razorpayPaymentId !== razorpay_payment_id) {
        return res.status(400).json({ success: false, message: 'Payment ID mismatch for already successful order' });
      }
      return res.status(200).json({
        success: true,
        message: 'Payment already verified successfully',
        data: { paymentStatus: order.paymentStatus, paidAt: order.paidAt }
      });
    }

    if (order.razorpayOrderId !== razorpay_order_id) {
      return res.status(400).json({ success: false, message: 'Invalid Razorpay Order ID' });
    }

    if (!process.env.RAZORPAY_KEY_SECRET) {
       return res.status(500).json({ success: false, message: 'Razorpay secret not configured' });
    }

    // Verify signature
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET);
    hmac.update(razorpay_order_id + "|" + razorpay_payment_id);
    const expectedSignature = hmac.digest('hex');

    let isValid = false;
    try {
      // Use timing-safe comparison to prevent timing attacks
      if (expectedSignature.length === razorpay_signature.length) {
         isValid = crypto.timingSafeEqual(Buffer.from(expectedSignature), Buffer.from(razorpay_signature));
      }
    } catch (e) {
      isValid = false;
    }

    if (!isValid) {
      return res.status(400).json({ success: false, message: 'Invalid payment signature' });
    }

    // Signature is valid, update order
    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: {
        paymentStatus: 'SUCCESS',
        razorpayPaymentId: razorpay_payment_id,
        paidAt: new Date()
      }
    });

    return res.status(200).json({
      success: true,
      message: 'Payment verified successfully',
      data: {
        paymentStatus: updatedOrder.paymentStatus,
        paidAt: updatedOrder.paidAt
      }
    });

  } catch (error) {
    console.error("Razorpay verify payment error:", error);
    next(error);
  }
};
