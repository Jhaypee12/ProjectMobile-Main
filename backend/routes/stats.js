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
const MyCourse = mongoose.model(
  'StatsMyCourse',
  new mongoose.Schema({}, { strict: false, collection: 'mycourses' })
);

router.get('/', async (req, res) => {
  try {
    const { studentId } = req.query;

    let myEnrollments = [];
    if (studentId) {
      const myDocs = await MyCourse.find({
        'students.student': new mongoose.Types.ObjectId(studentId),
      }).lean();

      for (const m of myDocs) {
        for (const s of (m.students || [])) {
          const sid = s.student ? s.student.toString() : '';
          if (sid === studentId) {
            myEnrollments.push({
              courseName: m.name || '',
              score: Number(s.score) || 0,
            });
          }
        }
      }
    }

    let avg = 0;
    if (studentId) {
      if (myEnrollments.length > 0) {
        const sum = myEnrollments.reduce((acc, e) => acc + e.score, 0);
        avg = sum / myEnrollments.length;
      }
    } else {
      const grades = await Grade.find({}, 'score total');
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
    }

    const coursesCount = studentId
      ? myEnrollments.length
      : await Course.countDocuments();

    const today = new Date();
    const in7 = new Date();
    in7.setDate(today.getDate() + 7);
    const todayStr = today.toISOString().split('T')[0];
    const in7Str = in7.toISOString().split('T')[0];

    let dueCount = 0;
    if (studentId) {
      if (myEnrollments.length > 0) {
    
        const lowerNames = myEnrollments.map((e) =>
          e.courseName.toLowerCase().trim()
        );
        const all = await Assessment.find({
          due: { $gte: todayStr, $lte: in7Str },
        });
        dueCount = all.filter((a) => {
          if (!a.course) return false;
          return lowerNames.includes(a.course.toLowerCase().trim());
        }).length;
      }
    } else {
      const upcomingAssessments = await Assessment.countDocuments({
        due: { $gte: todayStr, $lte: in7Str },
      });
      const upcomingEvents = await Event.countDocuments({
        date: { $gte: todayStr, $lte: in7Str },
      });
      dueCount = upcomingAssessments + upcomingEvents;
    }

    res.json({
      averageGrade: Number(avg.toFixed(2)),
      enrolledCourses: coursesCount,
      dueThisWeek: dueCount,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;