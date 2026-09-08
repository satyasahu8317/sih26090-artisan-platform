import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import prisma from '../config/db.js';
import { sendSms } from '../utils/smsService.js';

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });
};

const msg91WidgetRequest = async (path, body = {}) => {
  const widgetId = process.env.MSG91_WIDGET_ID;
  const tokenAuth = process.env.MSG91_TOKEN_AUTH;

  if (!widgetId || !tokenAuth) {
    throw new Error('MSG91 widget configuration is missing');
  }

  const response = await fetch(`https://control.msg91.com/api/v5/widget/${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ widgetId, tokenAuth, ...body }),
  });

  const data = await response.json();
  if (!response.ok) {
    const error = new Error(data?.message || 'MSG91 widget request failed');
    error.status = response.status;
    throw error;
  }

  return data;
};

export const sendMsg91Otp = async (req, res, next) => {
  try {
    const { identifier } = req.body;
    if (!identifier || !/^\d{10,15}$/.test(identifier)) {
      res.status(400);
      throw new Error('A valid mobile number with country code is required');
    }

    res.status(200).json(await msg91WidgetRequest('sendOtpMobile', { identifier }));
  } catch (error) {
    next(error);
  }
};

export const verifyMsg91Otp = async (req, res, next) => {
  try {
    const { reqId, otp } = req.body;
    if (!reqId || !otp) {
      res.status(400);
      throw new Error('MSG91 request ID and OTP are required');
    }

    res.status(200).json(await msg91WidgetRequest('verifyOtp', { reqId, otp }));
  } catch (error) {
    next(error);
  }
};

export const retryMsg91Otp = async (req, res, next) => {
  try {
    const { reqId, retryChannel } = req.body;
    if (!reqId) {
      res.status(400);
      throw new Error('MSG91 request ID is required');
    }

    res.status(200).json(
      await msg91WidgetRequest('retryOtp', { reqId, ...(retryChannel ? { retryChannel } : {}) }),
    );
  } catch (error) {
    next(error);
  }
};

export const requestOtp = async (req, res, next) => {
  try {
    const { mobileNumber, role } = req.body;

    if (!mobileNumber || !role) {
      res.status(400);
      throw new Error('Please provide mobileNumber and role');
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpHash = await bcrypt.hash(otp, 10);
    const otpExpiresAt = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY_MINUTES) || 5) * 60000);

    let user = await prisma.user.findUnique({
      where: {
        mobileNumber_role: { mobileNumber, role },
      },
    });

    if (user) {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { otpHash, otpExpiresAt, otpAttempts: 0 },
      });
    } else {
      user = await prisma.user.create({
        data: {
          mobileNumber,
          role,
          otpHash,
          otpExpiresAt,
          otpAttempts: 0,
        },
      });
    }

    await sendSms(mobileNumber, `Your OTP is: ${otp}`);

    res.status(200).json({ message: 'OTP sent successfully' });
  } catch (error) {
    next(error);
  }
};

export const verifyOtp = async (req, res, next) => {
  try {
    const { mobileNumber, role, otp } = req.body;

    const user = await prisma.user.findUnique({
      where: {
        mobileNumber_role: { mobileNumber, role },
      },
    });

    if (!user) {
      res.status(404);
      throw new Error('User not found');
    }

    if (!user.otpHash || !user.otpExpiresAt || user.otpExpiresAt < new Date()) {
      res.status(400);
      throw new Error('OTP has expired or is invalid');
    }

    const isMatch = await bcrypt.compare(otp, user.otpHash);

    if (!isMatch) {
      await prisma.user.update({
        where: { id: user.id },
        data: { otpAttempts: user.otpAttempts + 1 },
      });
      res.status(400);
      throw new Error('Invalid OTP');
    }

    
    await prisma.user.update({
      where: { id: user.id },
      data: { otpHash: null, otpExpiresAt: null, otpAttempts: 0 },
    });

    const token = generateToken(user.id);
    const isNewUser = user.status === 'PENDING';
    const redirect = isNewUser
      ? `/${role.toLowerCase()}/register`
      : `/${role.toLowerCase()}/home`;

    res.status(200).json({ token, isNewUser, redirect });
  } catch (error) {
    next(error);
  }
};

export const verifyMsg91 = async (req, res, next) => {
  try {
    const { accessToken, role } = req.body;

    if (!accessToken) {
      res.status(400);
      throw new Error('Please provide MSG91 accessToken');
    }

    // Call isolated service
    const { verifyMsg91AccessToken } = await import('../services/msg91Service.js');
    const msg91Result = await verifyMsg91AccessToken(accessToken);
    const mobileNumber = msg91Result.mobileNumber;

    let user;

    if (role) {
      // First try with mobileNumber and role if provided
      user = await prisma.user.findUnique({
        where: {
          mobileNumber_role: { mobileNumber, role },
        },
      });
    }

    if (!user) {
      // If role wasn't provided or user not found with that role, try to find any user with that mobile
      const users = await prisma.user.findMany({
        where: { mobileNumber },
      });

      if (users.length === 1) {
        user = users[0];
      } else if (users.length > 1 && !role) {
        res.status(400);
        throw new Error('Multiple accounts found for this mobile number. Please specify a role.');
      }
    }

    // If still no user, we must create one. 
    if (!user) {
      if (!role) {
        res.status(400);
        throw new Error('Role is required for new user registration');
      }

      user = await prisma.user.create({
        data: {
          mobileNumber,
          role,
          status: 'PENDING',
        },
      });
    }

    // Ensure OTP cleanup is done safely
    await prisma.user.update({
      where: { id: user.id },
      data: { otpHash: null, otpExpiresAt: null, otpAttempts: 0 },
    });

    const token = generateToken(user.id);
    const isNewUser = user.status === 'PENDING';
    const activeRole = user.role;
    const redirect = isNewUser
      ? `/${activeRole.toLowerCase()}/register`
      : `/${activeRole.toLowerCase()}/home`;

    res.status(200).json({ token, isNewUser, redirect });
  } catch (error) {
    if (error.message.includes('MSG91') || error.message.includes('extract mobile')) {
      res.status(401); // Unauthorized if it's a token validation issue
    }
    next(error);
  }
};

export const register = async (req, res, next) => {
  try {
    const user = req.user;
    const { role } = req.params;

    if (user.role !== role.toUpperCase()) {
      res.status(400);
      throw new Error('Role mismatch');
    }

    if (user.status === 'ACTIVE') {
      res.status(400);
      throw new Error('User is already registered');
    }

    if (role === 'artisan') {
      const { name, craftType, state, district, preferredLanguage } = req.body;
      await prisma.artisanProfile.create({
        data: {
          userId: user.id,
          name,
          craftType,
          state,
          district,
          preferredLanguage,
        },
      });
    } else if (role === 'buyer') {
      const { name, businessName, businessType, state, district } = req.body;
      await prisma.buyerProfile.create({
        data: {
          userId: user.id,
          name,
          businessName,
          businessType,
          state,
          district,
        },
      });
    } else {
      res.status(400);
      throw new Error('Invalid role');
    }

    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: { status: 'ACTIVE' },
    });

    const token = generateToken(updatedUser.id);

    res.status(200).json({
      token,
      redirect: `/${role}/home`,
    });
  } catch (error) {
    next(error);
  }
};

export const getMe = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: {
        artisanProfile: true,
        buyerProfile: true,
      },
    });

    const redirect = user.status === 'PENDING'
      ? `/${user.role.toLowerCase()}/register`
      : `/${user.role.toLowerCase()}/home`;

    res.status(200).json({
      user,
      redirect,
    });
  } catch (error) {
    next(error);
  }
};
