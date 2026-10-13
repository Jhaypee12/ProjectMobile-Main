const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

const courseSchema = new mongoose.Schema(
  {
    name: String,
    code: String,
    instructor: String,
    description: String,
    grade: String,
    score: Number,
    enrolledStudentIds: [
      { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    ],
  },
  { collection: 'courses' }
);

const Course = mongoose.model('Course', courseSchema);

router.get('/', async (req, res) => {
  try {
    const courses = await Course.find().populate(
      'enrolledStudentIds',
      'firstName lastName email role'
    );
    res.json(courses);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const {
      name,
      code,
      instructor,
      description,
      grade,
      score,
      enrolledStudentIds,
    } = req.body;
    const created = await Course.create({
      name,
      code,
      instructor,
      description,
      grade,
      score,
      enrolledStudentIds: enrolledStudentIds ?? [],
    });
    res.status(201).json(created);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const {
      name,
      code,
      instructor,
      description,
      grade,
      score,
      enrolledStudentIds,
    } = req.body;
    const updated = await Course.findByIdAndUpdate(
      req.params.id,
      {
        name,
        code,
        instructor,
        description,
        grade,
        score,
        enrolledStudentIds: enrolledStudentIds ?? [],
      },
      { new: true }
    );
    if (!updated) return res.status(404).json({ message: 'Not found' });
    res.json(updated);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const removed = await Course.findByIdAndDelete(req.params.id);
    if (!removed) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;