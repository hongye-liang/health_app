const express = require('express');
const axios = require('axios');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = 3000;
const ANTHROPIC_API_URL = 'https://api.anthropic.com/v1/messages';
const API_KEY = 'api key';

app.post('/ai-analysis', async (req, res) => {
  const { inputText } = req.body;

  try {
    const response = await axios.post(
      ANTHROPIC_API_URL,
      {
        model: "claude-3-sonnet-20240229",
        max_tokens: 1024,
        messages: [
          {
            role: "user",
            content: inputText
          }
        ]
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': API_KEY,
          'anthropic-version': '2023-06-01'
        }
      }
    );
    
    res.json(response.data);
  } catch (error) {
    console.error('Error communicating with Claude API:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Failed to communicate with Claude API' });
  }
});

// app.listen(PORT, () => {
  app.listen(3000,'0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
