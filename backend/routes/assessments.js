const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

require('../models/User');

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

const Assessment =
  mongoose.models.Assessment ||
  mongoose.model('Assessment', assessmentSchema);

const myCourseSchema = new mongoose.Schema(
  {},
  { strict: false, collection: 'mycourses' }
);

const MyCourse =
  mongoose.models.MyCourse || mongoose.model('MyCourse', myCourseSchema);

router.get('/', async (req, res) => {
  try {
    let items = await Assessment.find()
      .sort({ due: 1, _id: -1 })
      .lean();

    if (req.query.student) {
      const studentId = req.query.student;

      const myDocs = await MyCourse.find({
        'students.student': new mongoose.Types.ObjectId(studentId),
      }).lean();

      const myCourseNames = new Set();
      for (const m of myDocs) {
        if (m.name) myCourseNames.add(m.name.toLowerCase().trim());
      }

      items = items.filter((a) => {
        if (!a.course) return false;
        return myCourseNames.has(a.course.toLowerCase().trim());
      });
    }

    res.json(items);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { name, course, type, due, status, description, section } =
      req.body;
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
    const { name, course, type, due, status, description, section } =
      req.body;
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