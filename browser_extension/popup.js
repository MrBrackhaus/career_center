const PORT = 47392;
const SERVER_URL = `http://127.0.0.1:${PORT}/api`;

function getBrowser() {
  return typeof browser !== 'undefined' ? browser : chrome;
}


async function getToken() {
  try {
    const res = await fetch(`${SERVER_URL}/status`);
    if (res.ok) {
      const data = await res.json();
      return data.token;
    }
  } catch(e) {
    console.error('Failed to get token', e);
  }
  return '';
}

function showStatus(msg, isError = false, duration = 3000) {
  const el = document.getElementById('status');
  el.textContent = msg;
  el.style.color = isError ? '#f38ba8' : '#a6e3a1';
  if (duration > 0) setTimeout(() => { el.textContent = ''; }, duration);
}

// ── Import Job Listing ────────────────────────────────────────────────────────
document.getElementById('btn-import').addEventListener('click', async () => {
  try {
    const [tab] = await getBrowser().tabs.query({ active: true, currentWindow: true });

    const results = await getBrowser().scripting.executeScript({
      target: { tabId: tab.id },
      func: () => document.documentElement.outerHTML
    });

    const html = results[0].result;

    // Screenshot der aktuellen Ansicht aufnehmen
    let screenshot = null;
    try {
      screenshot = await new Promise((resolve) => {
        getBrowser().tabs.captureVisibleTab(tab.windowId, { format: 'png', quality: 80 }, (dataUrl) => {
          if (getBrowser().runtime.lastError) {
            console.error(getBrowser().runtime.lastError);
            resolve(null);
          } else {
            resolve(dataUrl); // Dies ist ein Base64 String: "data:image/png;base64,..."
          }
        });
      });
    } catch (e) {
      console.warn('Screenshot fehlgeschlagen', e);
    }

    const token = await getToken();
    const response = await fetch(`${SERVER_URL}/import`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-api-token': token },
      body: JSON.stringify({ url: tab.url, html, screenshot })
    });

    if (response.ok) {
      showStatus('✅ Erfolgreich gesendet!');
    } else {
      showStatus('⚠️ App antwortet nicht', true);
    }
  } catch (err) {
    showStatus('❌ Fehler: App läuft?', true);
    console.error(err);
  }
});

// ── Autofill Application Form ─────────────────────────────────────────────────
document.getElementById('btn-autofill').addEventListener('click', async () => {
  const btn = document.getElementById('btn-autofill');
  btn.disabled = true;
  showStatus('⏳ Profil wird geladen…', false, 0);

  try {
    // 1. Fetch profile from the local app
    const token = await getToken();
    const response = await fetch(`${SERVER_URL}/profile`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json', 'x-api-token': token }
    });

    if (!response.ok) {
      showStatus('⚠️ App nicht erreichbar', true);
      btn.disabled = false;
      return;
    }

    const profile = await response.json();

    if (profile.error) {
      showStatus('⚠️ Kein Profil hinterlegt', true);
      btn.disabled = false;
      return;
    }

    // 2. Get the active tab
    const [tab] = await getBrowser().tabs.query({ active: true, currentWindow: true });

    // 3. Inject profile data as a global variable, then run the filler script
    await getBrowser().scripting.executeScript({
      target: { tabId: tab.id },
      func: (profileData) => { window.__bzProfile = profileData; },
      args: [profile]
    });

    await getBrowser().scripting.executeScript({
      target: { tabId: tab.id },
      files: ['content_autofill.js']
    });

    showStatus('🎯 Formular wird ausgefüllt!');
  } catch (err) {
    showStatus('❌ Fehler: App läuft?', true);
    console.error(err);
  } finally {
    btn.disabled = false;
  }
});
