const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

// Mongo connection from env var
mongoose.connect(process.env.MONGO_URL, { useNewUrlParser: true, useUnifiedTopology: true });

app.get('/', (req, res) => res.send('Tasky App Running'));

app.listen(3000, () => console.log('App running on port 3000'));
