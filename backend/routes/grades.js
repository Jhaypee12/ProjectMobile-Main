const express = require('express');
const mongoose = require('mongoose');

const User = require('../models/User');  
const router = express.Router();

const gradeSchema = new mongoose.Schema(
  {
    course: { type: String, default: '' },
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    assessment: { type: mongoose.Schema.Types.ObjectId, ref: 'Assessment' },
    submission: { type: String, default: '' },
    score: { type: Number, default: 0 },
    total: { type: Number, default: 0 },
    feedback: { type: String, default: '' },
  },
  { collection: 'grades' }
);

const Grade = mongoose.model('Grade', gradeSchema);

router.get('/', async (req, res) => {
  try {
    const grades = await Grade.find()
      .populate('student', 'firstName lastName email')
      .sort({ _id: -1 });
    res.json(grades);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { course, student, assessment, submission, score, total, feedback } =
      req.body;
    const created = await Grade.create({
      course,
      student,
      assessment: assessment || undefined,
      submission,
      score,
      total,
      feedback,
    });
    const populated = await created.populate('student', 'firstName lastName email');
    res.status(201).json(populated);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { course, student, assessment, submission, score, total, feedback } =
      req.body;
    const updated = await Grade.findByIdAndUpdate(
      req.params.id,
      { course, student, assessment, submission, score, total, feedback },
      { new: true }
    ).populate('student', 'firstName lastName email');
    if (!updated) return res.status(404).json({ message: 'Not found' });
    res.json(updated);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const removed = await Grade.findByIdAndDelete(req.params.id);
    if (!removed) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;