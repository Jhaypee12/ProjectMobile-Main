const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

const announcementSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    message: { type: String, required: true },
    course: { type: String, default: 'ALL' }, 
    section: { type: String, default: '' },   
    date: { type: String, required: true },   
  },
  { collection: 'announcements' }
);

const Announcement = mongoose.model('Announcement', announcementSchema);

router.get('/', async (req, res) => {
  try {
    const items = await Announcement.find().sort({ date: -1, _id: -1 });
    res.json(items);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// CREATE
router.post('/', async (req, res) => {
  try {
    const { title, message, course, section, date } = req.body;
    const created = await Announcement.create({
      title,
      message,
      course: course ?? 'ALL',
      section: section ?? '',
      date: date ?? new Date().toISOString().split('T')[0],
    });
    res.status(201).json(created);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// UPDATE
router.put('/:id', async (req, res) => {
  try {
    const { title, message, course, section, date } = req.body;
    const updated = await Announcement.findByIdAndUpdate(
      req.params.id,
      { title, message, course, section, date },
      { new: true, runValidators: true }
    );
    if (!updated) return res.status(404).json({ message: 'Not found' });
    res.json(updated);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// DELETE
router.delete('/:id', async (req, res) => {
  try {
    const removed = await Announcement.findByIdAndDelete(req.params.id);
    if (!removed) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;