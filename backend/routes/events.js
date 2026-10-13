const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

const eventSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    type: { type: String, default: 'Event' },
    date: { type: String, required: true }, 
  },
  { collection: 'events' }
);

const Event = mongoose.model('Event', eventSchema);

router.get('/', async (req, res) => {
  try {
    const items = await Event.find().sort({ date: 1, _id: 1 });
    res.json(items);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { title, type, date } = req.body;
    const created = await Event.create({
      title,
      type: type ?? 'Event',
      date,
    });
    res.status(201).json(created);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { title, type, date } = req.body;
    const updated = await Event.findByIdAndUpdate(
      req.params.id,
      { title, type, date },
      { new: true, runValidators: true }
    );
    if (!updated) return res.status(404).json({ message: 'Not found' });
    res.json(updated);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

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