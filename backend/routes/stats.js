const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

const Course = mongoose.model(
  'StatsCourse',
  new mongoose.Schema({}, { strict: false, collection: 'courses' })
);
const Grade = mongoose.model(
  'StatsGrade',
  new mongoose.Schema({}, { strict: false, collection: 'grades' })
);
const Event = mongoose.model(
  'StatsEvent',
  new mongoose.Schema({}, { strict: false, collection: 'events' })
);
const Assessment = mongoose.model(
  'StatsAssessment',
  new mongoose.Schema({}, { strict: false, collection: 'assessments' })
);


router.get('/', async (req, res) => {
  try {
    const coursesCount = await Course.countDocuments();

    const grades = await Grade.find({}, 'score total');
    let avg = 0;
    if (grades.length > 0) {
      const sum = grades.reduce((acc, g) => {
        if (!g.total) return acc;
        return acc + (g.score / g.total) * 100;
      }, 0);
      avg = sum / grades.length;
    }

    const today = new Date();
    const in7Days = new Date();
    in7Days.setDate(today.getDate() + 7);
    const todayStr = today.toISOString().split('T')[0];
    const in7Str = in7Days.toISOString().split('T')[0];

    const upcomingEvents = await Event.countDocuments({
      date: { $gte: todayStr, $lte: in7Str },
    });

    const upcomingAssessments = await Assessment.countDocuments({
      due: { $gte: todayStr, $lte: in7Str },
    });

    res.json({
      averageGrade: Number(avg.toFixed(2)),
      enrolledCourses: coursesCount,
      dueThisWeek: upcomingEvents + upcomingAssessments,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;