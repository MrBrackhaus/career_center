const { spawn } = require('child_process');

const server = spawn('node', ['index.js'], { cwd: './mcp-server' });

const request = {
  jsonrpc: "2.0",
  id: 1,
  method: "tools/call",
  params: {
    name: "add_application",
    arguments: {
      company: "Landbäckerei Stinges",
      position: "IT-Systemadministrator / IT-Support (m/w/d)",
      status: "versendet",
      job_description: "Bewerbung als IT-Systemadministrator / IT-Support (m/w/d)\n\nSehr geehrte Damen und Herren,\n\ndie Kombination aus technischer Administration und der direkten Unterstützung von Mitarbeitern macht die IT für mich so spannend. Als Fachinformatiker für Systemintegration (IHK) aus der direkten Nachbarschaft in Nettetal möchte ich meine Hands-on-Mentalität bei der Landbäckerei Stinges einbringen.\n\nIm Rahmen meiner praxisorientierten IHK-Ausbildung habe ich fundierte Erfahrung im direkten Anwendersupport gesammelt. Das Beheben von Störungen, die Einrichtung von Systemen und die verständliche Beratung von Kollegen gehörten dabei zu meinen zentralen Aufgaben. Meine IHK-Projektarbeit – die Umsetzung einer Zabbix-Monitoringlösung – hat mir zudem gezeigt, wie wichtig eine proaktive Systemüberwachung für einen reibungslosen Betriebsablauf ist.\n\nIn meinem eigenen IT-Labor vertiefe ich meine Kenntnisse im Microsoft-Umfeld kontinuierlich. Ich administriere Windows-Server, verwalte das Active Directory und arbeite intensiv mit Netzwerkkomponenten. Durch meine langjährige Erfahrung im Einzelhandel weiß ich zudem genau, wie wichtig lösungsorientierte und freundliche Kommunikation im Support-Alltag ist.\n\nNach der abgeschlossenen familiären Pflege meiner Mutter stehe ich dem Arbeitsmarkt seit Juni 2026 wieder in vollem Umfang zur Verfügung. Ich freue mich darauf, Ihr Team als zuverlässiger Allrounder zu verstärken.\n\nÜber die Einladung zu einem persönlichen Gespräch freue ich mich sehr.\n\nMit freundlichen Grüßen\n\nMichael Kurz"
    }
  }
};

let output = '';

server.stdout.on('data', (data) => {
  output += data.toString();
  try {
    const lines = output.split('\n');
    for (const line of lines) {
      if (line.trim() === '') continue;
      const json = JSON.parse(line);
      if (json.id === 1) {
        console.log("Ergebnis vom MCP Server:", JSON.stringify(json.result, null, 2));
        server.kill();
        process.exit(0);
      }
    }
  } catch (e) {
    // waiting for full json
  }
});

server.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

server.stdin.write(JSON.stringify({
  jsonrpc: "2.0",
  id: 0,
  method: "initialize",
  params: {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "test-client", version: "1.0.0" }
  }
}) + "\n");

server.stdin.write(JSON.stringify(request) + "\n");
