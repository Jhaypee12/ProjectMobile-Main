const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

require('../models/User');

const eventSchema = new mongoose.Schema(
  {
    course: { type: String, default: '' },
    title: { type: String, required: true },
    section: { type: String, default: '' },
    type: { type: String, default: 'Event' },
    date: { type: String, required: true },
  },
  { collection: 'events' }
);

const Event =
  mongoose.models.Event || mongoose.model('Event', eventSchema);

const myCourseSchema = new mongoose.Schema(
  {},
  { strict: false, collection: 'mycourses' }
);

const MyCourse =
  mongoose.models.MyCourse || mongoose.model('MyCourse', myCourseSchema);

router.get('/', async (req, res) => {
  try {
    let items = await Event.find().sort({ date: 1, _id: 1 }).lean();

    if (req.query.student) {
      const studentId = req.query.student;

      const myDocs = await MyCourse.find({
        'students.student': new mongoose.Types.ObjectId(studentId),
      }).lean();

      const myCourseNames = new Set();
      for (const m of myDocs) {
        if (m.name) myCourseNames.add(m.name.toLowerCase().trim());
      }

      items = items.filter((e) => {
        if (!e.course) return false;
        return myCourseNames.has(e.course.toLowerCase().trim());
      });
    }

    res.json(items);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

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