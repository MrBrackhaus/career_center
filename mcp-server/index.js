#!/usr/bin/env node

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { CallToolRequestSchema, ListToolsRequestSchema } = require("@modelcontextprotocol/sdk/types.js");
const sqlite3 = require('sqlite3').verbose();
const os = require('os');
const path = require('path');

// SQLite DB Path on Windows
const dbPath = path.join(os.homedir(), 'Documents', 'career_center.sqlite');

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Error opening database', err);
        process.exit(1);
    }
});

const server = new Server({
    name: "jobtracker-mcp",
    version: "1.0.0",
}, {
    capabilities: {
        tools: {}
    }
});

server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
        tools: [
            {
                name: "get_applications",
                description: "Holt eine Liste aller Bewerbungen aus dem JobTracker.",
                inputSchema: {
                    type: "object",
                    properties: {
                        status: {
                            type: "string",
                            description: "Optional: Filter nach Status (z.B. 'offen', 'versendet', 'absage', 'zusage')"
                        }
                    },
                    required: []
                }
            },
                                    {
                name: "get_user_profile",
                description: "Holt das Profil und die Einstellungen des Nutzers (z.B. Name, Skills, Lebenslauf-Daten). Wichtig, um personalisierte Anschreiben zu verfassen.",
                inputSchema: {
                    type: "object",
                    properties: {},
                    required: []
                }
            },
            {
                name: "get_application_details",
                description: "Holt alle Details einer bestimmten Bewerbung inklusive der hinterlegten Notizen (wo oft die Jobbeschreibung steht).",
                inputSchema: {
                    type: "object",
                    properties: {
                        id: { type: "integer" }
                    },
                    required: ["id"]
                }
            },
            {
                name: "add_application",
                description: "Fügt eine neue Bewerbung hinzu. Ideal, um aus einem rohen Text/URL eine strukturierte Bewerbung einzupflegen.",
                inputSchema: {
                    type: "object",
                    properties: {
                        company: { type: "string" },
                        position: { type: "string" },
                        status: { type: "string" },
                        job_description: { type: "string", description: "Der Text der Stellenanzeige (wird als Notiz gespeichert)" }
                    },
                    required: ["company", "position"]
                }
            },
            {
                name: "save_application_note",
                description: "Speichert eine Notiz zu einer Bewerbung. Perfekt, um ein von der KI generiertes, optimales Anschreiben direkt bei der Bewerbung zu hinterlegen!",
                inputSchema: {
                    type: "object",
                    properties: {
                        application_id: { type: "integer" },
                        content: { type: "string" }
                    },
                    required: ["application_id", "content"]
                }
            },
            {
                
                name: "update_status",
                description: "Aktualisiert den Status einer Bewerbung.",
                inputSchema: {
                    type: "object",
                    properties: {
                        id: { type: "integer" },
                        status: { type: "string" }
                    },
                    required: ["id", "status"]
                }
            }
        ]
    };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const name = request.params.name;
    const args = request.params.arguments || {};
    
    if (name === "get_applications") {
        return new Promise((resolve) => {
            let query = "SELECT id, company, position, status, applied_date FROM applications";
            let params = [];
            if (args.status) {
                query += " WHERE status = ?";
                params.push(args.status);
            }
            db.all(query, params, (err, rows) => {
                if (err) {
                    resolve({ content: [{ type: "text", text: `Error: ${err.message}` }], isError: true });
                } else {
                    resolve({ content: [{ type: "text", text: JSON.stringify(rows, null, 2) }] });
                }
            });
        });
    }
    
    if (name === "get_user_profile") {
        return new Promise((resolve) => {
            db.all("SELECT key, value FROM settings", [], (err, rows) => {
                if (err) resolve({ content: [{ type: "text", text: `Error: ${err.message}` }], isError: true });
                else resolve({ content: [{ type: "text", text: JSON.stringify(rows, null, 2) }] });
            });
        });
    }

    if (name === "get_application_details") {
        return new Promise((resolve) => {
            db.get("SELECT * FROM applications WHERE id = ?", [args.id], (err, app) => {
                if (err) return resolve({ content: [{ type: "text", text: `Error: ${err.message}` }], isError: true });
                if (!app) return resolve({ content: [{ type: "text", text: "Bewerbung nicht gefunden." }], isError: true });
                
                db.all("SELECT content, created_at FROM notes WHERE application_id = ?", [args.id], (err, notes) => {
                    app.notesList = notes || [];
                    resolve({ content: [{ type: "text", text: JSON.stringify(app, null, 2) }] });
                });
            });
        });
    }

    if (name === "save_application_note") {
        return new Promise((resolve) => {
            const query = "INSERT INTO notes (application_id, content, created_at) VALUES (?, ?, ?)";
            const date = Math.floor(Date.now() / 1000);
            db.run(query, [args.application_id, args.content, date], function(err) {
                if (err) resolve({ content: [{ type: "text", text: `Error: ${err.message}` }], isError: true });
                else resolve({ content: [{ type: "text", text: "Notiz erfolgreich hinterlegt" }] });
            });
        });
    }

    if (name === "add_application") {
        return new Promise((resolve) => {
            const query = "INSERT INTO applications (company, position, status, applied_date) VALUES (?, ?, ?, ?)";
            const status = args.status || 'offen';
            const date = Math.floor(Date.now() / 1000);
            
            db.run(query, [args.company, args.position, status, date], function(err) {
                if (err) {
                    return resolve({ content: [{ type: "text", text: `Error: ${err.message}` }], isError: true });
                }
                
                const appId = this.lastID;
                if (args.job_description) {
                    const noteQuery = "INSERT INTO notes (application_id, content, created_at) VALUES (?, ?, ?)";
                    db.run(noteQuery, [appId, args.job_description, date], function(noteErr) {
                        resolve({ content: [{ type: "text", text: `Bewerbung bei ${args.company} hinzugefügt` }] });
                    });
                } else {
                    resolve({ content: [{ type: "text", text: `Bewerbung hinzugefügt` }] });
                }
            });
        });
    }

    if (name === "update_status") {
        return new Promise((resolve) => {
            const query = "UPDATE applications SET status = ? WHERE id = ?";
            db.run(query, [args.status, args.id], function(err) {
                if (err) {
                    resolve({ content: [{ type: "text", text: `Error: ${err.message}` }], isError: true });
                } else {
                    resolve({ content: [{ type: "text", text: `Bewerbung ${args.id} auf Status '${args.status}' aktualisiert. (Changes: ${this.changes})` }] });
                }
            });
        });
    }

    return {
        content: [{ type: "text", text: `Unknown tool: ${name}` }],
        isError: true
    };
});

const transport = new StdioServerTransport();
server.connect(transport);




