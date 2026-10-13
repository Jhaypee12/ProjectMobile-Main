const express = require('express');
const mongoose = require('mongoose');
const User = require('../models/User');

const router = express.Router();

const validId = (req, res, next) => {
  if (!mongoose.isValidObjectId(req.params.id)) {
    return res.status(400).json({ message: 'Invalid id' });
  }
  next();
};

/* ---------- AUTH ---------- */

// REGISTER
router.post('/register', async (req, res) => {
  try {
    const { firstName, lastName, email, password } = req.body;
    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists)
      return res
        .status(400)
        .json({ message: 'That email is already registered' });

    const user = await User.create({
      firstName,
      lastName,
      email,
      password,
      role: 'STUDENT',
    });
    res.status(201).json({
      id: user._id,
      firstName,
      lastName,
      email,
      role: user.role,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// LOGIN
router.post('/login', async (req, res) => {
  try {
    const { email, password, role } = req.body;
    const user = await User.findOne({
      email: email.toLowerCase(),
      role: role.toUpperCase(),
    });
    if (!user || user.password !== password) {
      return res
        .status(400)
        .json({ message: 'Wrong email, password or role' });
    }
    res.json({
      id: user._id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      role: user.role,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// CHANGE PASSWORD — verifies the current password before updating
router.post('/change-password', async (req, res) => {
  try {
    const { userId, currentPassword, newPassword } = req.body;

    if (!userId || !currentPassword || !newPassword) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    if (newPassword.length < 8 || newPassword.length > 16) {
      return res
        .status(400)
        .json({ message: 'New password must be 8 to 16 characters' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.password !== currentPassword) {
      return res
        .status(400)
        .json({ message: 'Current password is incorrect' });
    }

    user.password = newPassword;
    await user.save();

    res.json({ message: 'Password updated' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// RESET PASSWORD — used by the Forgot Password modal (no email step)
router.post('/reset-password', async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res
        .status(400)
        .json({ message: 'Email and new password are required' });
    }

    if (newPassword.length < 8 || newPassword.length > 16) {
      return res
        .status(400)
        .json({ message: 'Password must be 8 to 16 characters' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(404).json({ message: 'No account with that email' });
    }

    user.password = newPassword;
    await user.save();

    res.json({ message: 'Password reset successfully' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

/* ---------- CRUD ---------- */

// CREATE
router.post('/', async (req, res) => {
  try {
    const { firstName, lastName, email, password, role } = req.body;
    const user = await User.create({
      firstName,
      lastName,
      email,
      password,
      role,
    });
    res.status(201).json(user);
  } catch (e) {
    if (e.code === 11000)
      return res.status(400).json({ message: 'Email already exists' });
    res.status(500).json({ message: e.message });
  }
});

// READ all
router.get('/', async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// READ one
router.get('/:id', validId, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// UPDATE
router.put('/:id', validId, async (req, res) => {
  try {
    const { firstName, lastName, email, password, role } = req.body;
    const update = { firstName, lastName, email, role };
    if (password && password.length > 0) update.password = password;

    const user = await User.findByIdAndUpdate(req.params.id, update, {
      new: true,
      runValidators: true,
    }).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (e) {
    if (e.code === 11000)
      return res.status(400).json({ message: 'Email already exists' });
    res.status(500).json({ message: e.message });
  }
});

// DELETE
router.delete('/:id', validId, async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ message: 'User deleted' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;