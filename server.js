const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/todo')
  .then(() => console.log('✅ MongoDB Connected!'))
  .catch(err => console.log('❌ MongoDB Error:', err.message));

const todoSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },  
  isPrimary: { type: Boolean, default: false },   
  isDone: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});


const Todo = mongoose.model('Todo', todoSchema);

// APIs
app.get('/todos', async (req, res) => {
  const todos = await Todo.find().sort({ createdAt: -1 });
  console.log('📡 GET todos:', todos.length);
  res.json(todos);
});

app.post('/todos', async (req, res) => {
  console.log("POST", req.body?.title || 'No title');
  const todo = new Todo({
    title: req.body.title,
    description: req.body.description,     
    isPrimary: req.body.isPrimary || false 
  });
  await todo.save();
  res.json(todo);
});

app.put('/todos/:id', async (req, res) => {
  const todo = await Todo.findByIdAndUpdate(req.params.id, req.body, { new: true });
  console.log('✅ UPDATE:', todo?.title);
  res.json(todo);
});

app.delete('/todos/:id', async (req, res) => {
  await Todo.findByIdAndDelete(req.params.id);
  console.log('🗑️ DELETE');
  res.json({ message: 'Deleted' });
});

app.listen(5000, () => console.log('🚀 Server: http://localhost:5000'));
