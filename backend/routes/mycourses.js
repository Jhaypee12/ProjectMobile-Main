const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

require('../models/User'); 

const myCourseSchema = new mongoose.Schema(
  {
    name: String,
    code: String,
    description: String,
    students: [
      {
        student: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        section: String,
        score: Number,
        grade: String,
      },
    ],
    modules: [{ title: String, content: String }],
  },
  { collection: 'mycourses' }
);

const MyCourse =
  mongoose.models.MyCourse || mongoose.model('MyCourse', myCourseSchema);

router.get('/', async (req, res) => {
  try {
    const list = await MyCourse.find().populate(
      'students.student',
      'firstName lastName email role'
    );
    res.json(list);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;