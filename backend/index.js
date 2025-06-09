// backend/index.js

const express = require('express');
const { Firestore } = require('@google-cloud/firestore');

// Create a new Express app
const app = express();

// Create a new Firestore client
const firestore = new Firestore();

// --- How Authentication Works ---
// When your code is running on Cloud Run (or other GCP services), the
// Google Cloud client library automatically finds the credentials of the
// service account associated with it. This means you don't need to manage
// API keys in your code. It's secure and automatic!

// --- API Endpoints ---

// A test endpoint to make sure the API is up
app.get('/api/test', (req, res) => {
    res.json({ message: 'test api: Hello from the Soccer Site API!' });
});

app.get('/', (req, res) => {
    res.send('v2: Hello from the Soccer Site API!');
});

// An endpoint to get all clubs from the 'clubs' collection
app.get('/api/team', async (req, res) => {
    try {
        const teamCollection = firestore.collection('team');
        const snapshot = await teamCollection.get();

        if (snapshot.empty) {
            res.status(404).json({ error: 'No teams found' });
            return;
        }

        const teams = [];
        snapshot.forEach(doc => {
            // We combine the document's auto-generated ID with its data
            teams.push({ id: doc.id, ...doc.data() });
        });

        res.status(200).json(teams);

    } catch (error) {
        console.error("Error fetching teams:", error);
        res.status(500).json({ error: 'Failed to fetch teams' });
    }
});

// --- Start the server ---
const port = process.env.PORT || 8080;
app.listen(port, () => {
    console.log(`API server listening on port ${port}`);
});