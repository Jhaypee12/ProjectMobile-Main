const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

const eventSchema = new mongoose.Schema(
  {
    course: { type: String, default: '' },
    title: { type: String, required: true },
    section: { type: String, default: '' },
    type: { type: String, default: 'Event' }, // Quiz / Assignment / Event
    date: { type: String, required: true },   // "YYYY-MM-DD"
  },
  { collection: 'events' }
);

const Event = mongoose.model('Event', eventSchema);

// GET all
router.get('/', async (req, res) => {
  try {
    const items = await Event.find().sort({ date: 1, _id: 1 });
    res.json(items);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// CREATE
router.post('/', async (req, res) => {
  try {
    const { course, title, section, type, date } = req.body;
    const created = await Event.create({
      course: course ?? '',
      title,
      section: section ?? '',
      type: type ?? 'Event',
      date,
    });
    res.status(201).json(created);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// UPDATE
router.put('/:id', async (req, res) => {
  try {
    const { course, title, section, type, date } = req.body;
    const updated = await Event.findByIdAndUpdate(
      req.params.id,
      { course, title, section, type, date },
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
    const removed = await Event.findByIdAndDelete(req.params.id);
    if (!removed) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;