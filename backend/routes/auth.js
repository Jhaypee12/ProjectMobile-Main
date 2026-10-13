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


// REGISTER
router.post('/register', async (req, res) => {
  try {
    const { firstName, lastName, email, password } = req.body;
    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) return res.status(400).json({ message: 'That email is already registered' });

    const user = await User.create({ firstName, lastName, email, password, role: 'STUDENT' });
    res.status(201).json({ id: user._id, firstName, lastName, email, role: user.role });
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
      return res.status(400).json({ message: 'Wrong email, password or role' });
    }
    res.json({ id: user._id, firstName: user.firstName, lastName: user.lastName, email: user.email, role: user.role });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});


// CREATE
router.post('/', async (req, res) => {
  try {
    const { firstName, lastName, email, password, role } = req.body;
    const user = await User.create({ firstName, lastName, email, password, role });
    res.status(201).json(user);
  } catch (e) {
    if (e.code === 11000) return res.status(400).json({ message: 'Email already exists' });
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
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { firstName, lastName, email, password, role },
      { new: true, runValidators: true }
    ).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (e) {
    if (e.code === 11000) return res.status(400).json({ message: 'Email already exists' });
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