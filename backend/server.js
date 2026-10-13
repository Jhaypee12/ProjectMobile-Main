require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./routes/auth'));
app.use('/api/courses', require('./routes/courses'));
app.use('/api/announcements', require('./routes/announcements'));
app.use('/api/assessments', require('./routes/assessments'));
app.use('/api/grades', require('./routes/grades'));
app.use('/api/events', require('./routes/events'));
app.use('/api/stats', require('./routes/stats'));

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.log('MongoDB error:', err.message));

app.get('/', (req, res) => res.send('Lumen server is running'));

app.listen(process.env.PORT, () =>
  console.log('Server on port ' + process.env.PORT));