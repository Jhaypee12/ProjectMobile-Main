const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

// Use unique names so we don't clash with models registered in other route files.
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
    const { studentId } = req.query;

    // --- Enrolled courses count ---
    let coursesCount;
    if (studentId) {
      coursesCount = await Course.countDocuments({
        enrolledStudentIds: new mongoose.Types.ObjectId(studentId),
      });
    } else {
      coursesCount = await Course.countDocuments();
    }

    // --- Average grade (score/total per grade, averaged) ---
    const gradeQuery = studentId
      ? { student: new mongoose.Types.ObjectId(studentId) }
      : {};
    const grades = await Grade.find(gradeQuery, 'score total');

    let avg = 0;
    if (grades.length > 0) {
      let sum = 0;
      let count = 0;
      for (const g of grades) {
        if (!g.total) continue;
        sum += (g.score / g.total) * 100;
        count++;
      }
      avg = count === 0 ? 0 : sum / count;
    }

    // --- Due this week ---
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