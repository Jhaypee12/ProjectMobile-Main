const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    firstName: String,
    lastName: String,
    email: { type: String, unique: true, lowercase: true },
    password: String,
    role: { type: String, default: 'STUDENT' },
  },
  { collection: 'students' }  
);

module.exports = mongoose.model('User', userSchema);