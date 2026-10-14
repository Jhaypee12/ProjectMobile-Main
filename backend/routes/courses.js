const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

require('../models/User');

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

const Course =
  mongoose.models.Course || mongoose.model('Course', courseSchema);

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
    let courses = await Course.find().lean();

    if (req.query.student) {
      const studentId = req.query.student;

      const myDocs = await MyCourse.find({
        'students.student': new mongoose.Types.ObjectId(studentId),
      }).lean();

      const enrollment = {};
      for (const m of myDocs) {
        for (const s of (m.students || [])) {
          const sid = s.student ? s.student.toString() : '';
          if (sid === studentId) {
            enrollment[m.name] = {
              score: s.score ?? 0,
              grade: s.grade ?? '',
              section: s.section ?? '',
            };
          }
        }
      }

      courses = courses
        .filter((c) => enrollment[c.name] !== undefined)
        .map((c) => ({
          ...c,
          ...enrollment[c.name],
        }));
    }

    res.json(courses);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// CREATE
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

// UPDATE
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

// DELETE
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