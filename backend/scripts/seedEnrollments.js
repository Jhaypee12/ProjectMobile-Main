require('dotenv').config();
const mongoose = require('mongoose');

const User = mongoose.model(
  'User',
  new mongoose.Schema({}, { strict: false, collection: 'students' })
);

const Course = mongoose.model(
  'Course',
  new mongoose.Schema({}, { strict: false, collection: 'courses' })
);

async function seed() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log('Connected to MongoDB');

  const students = await User.find({ role: 'STUDENT' });
  console.log(`Found ${students.length} students`);

  if (students.length === 0) {
    console.log('No students found. Register some students first.');
    return mongoose.disconnect();
  }

  const courses = await Course.find();
  console.log(`Found ${courses.length} courses`);

  for (let i = 0; i < courses.length; i++) {
    const enrolled = [students[i % students.length]._id];
    if (students.length > 1) {
      enrolled.push(students[(i + 1) % students.length]._id);
    }

    await Course.updateOne(
      { _id: courses[i]._id },
      { $set: { enrolledStudentIds: enrolled } }
    );

    console.log(
      `Enrolled ${enrolled.length} student(s) into "${courses[i].name}"`
    );
  }

  console.log('Done');
  mongoose.disconnect();
}

seed().catch((e) => {
  console.error(e);
  mongoose.disconnect();
});