const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

const assessmentSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    course: { type: String, default: '' },
    type: { type: String, default: 'Assignment' },
    due: { type: String, default: '' },
    status: { type: String, default: 'Pending' },
    description: { type: String, default: '' },
    section: { type: String, default: '' },
  },
  { collection: 'assessments' }
);

const Assessment = mongoose.model('Assessment', assessmentSchema);

router.get('/', async (req, res) => {
  try {
    const items = await Assessment.find().sort({ due: 1, _id: -1 });
    res.json(items);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { name, course, type, due, status, description, section } = req.body;
    const created = await Assessment.create({
      name,
      course: course ?? '',
      type: type ?? 'Assignment',
      due: due ?? '',
      status: status ?? 'Pending',
      description: description ?? '',
      section: section ?? '',
    });
    res.status(201).json(created);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { name, course, type, due, status, description, section } = req.body;
    const updated = await Assessment.findByIdAndUpdate(
      req.params.id,
      { name, course, type, due, status, description, section },
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
    const removed = await Assessment.findByIdAndDelete(req.params.id);
    if (!removed) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;