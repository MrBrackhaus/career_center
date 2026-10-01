const PORT = 47392;
const SERVER_URL = `http://127.0.0.1:${PORT}/api`;
const TOKEN_STORAGE_KEY = 'apiToken';
// Server-Limit für /api/import liegt bei 5 MB – mit Sicherheitsabstand bleiben.
const MAX_IMPORT_BYTES = 4.5 * 1024 * 1024;

function getBrowser() {
  return typeof browser !== 'undefined' ? browser : chrome;
}

// ── Token (Kopplung mit der App) ──────────────────────────────────────────────
// Der Token wird NICHT mehr vom Server abgefragt, sondern einmalig vom Nutzer
// aus den App-Einstellungen kopiert und lokal in storage.local gespeichert.
async function getToken() {
  try {
    const data = await getBrowser().storage.local.get(TOKEN_STORAGE_KEY);
    return (data && data[TOKEN_STORAGE_KEY]) || '';
  } catch (e) {
    console.error('Token konnte nicht gelesen werden', e);
    return '';
  }
}

async function saveToken(token) {
  if (token) {
    await getBrowser().storage.local.set({ [TOKEN_STORAGE_KEY]: token });
  } else {
    await getBrowser().storage.local.remove(TOKEN_STORAGE_KEY);
  }
}

function showStatus(msg, isError = false, duration = 3000) {
  const el = document.getElementById('status');
  el.textContent = msg;
  el.style.color = isError ? '#f38ba8' : '#a6e3a1';
  if (duration > 0) setTimeout(() => { el.textContent = ''; }, duration);
}

function openTokenSection() {
  document.getElementById('token-section').open = true;
  document.getElementById('token-input').focus();
}

/** Liefert den gespeicherten Token oder zeigt einen Hinweis und gibt '' zurück. */
async function requireToken() {
  const token = await getToken();
  if (!token) {
    showStatus('🔑 Bitte zuerst den App-Token eintragen (Einstellungen → KI & Automatisierung).', true, 0);
    openTokenSection();
  }
  return token;
}

function handleForbidden() {
  showStatus('⛔ Token ungültig – bitte in der App neu kopieren und hier eintragen.', true, 0);
  openTokenSection();
}

function byteLength(str) {
  return new TextEncoder().encode(str).length;
}

// ── Token-Eingabe initialisieren ──────────────────────────────────────────────
(async () => {
  const token = await getToken();
  const input = document.getElementById('token-input');
  input.value = token;
  if (!token) {
    document.getElementById('token-section').open = true;
  }
})();

document.getElementById('btn-save-token').addEventListener('click', async () => {
  const token = document.getElementById('token-input').value.trim();
  try {
    await saveToken(token);
    if (token) {
      showStatus('✅ Token gespeichert');
      document.getElementById('token-section').open = false;
    } else {
      showStatus('Token entfernt', true);
    }
  } catch (e) {
    showStatus('❌ Token konnte nicht gespeichert werden', true);
    console.error(e);
  }
});

// ── Import Job Listing ────────────────────────────────────────────────────────
document.getElementById('btn-import').addEventListener('click', async () => {
  try {
    const token = await requireToken();
    if (!token) return;

    const [tab] = await getBrowser().tabs.query({ active: true, currentWindow: true });

    const results = await getBrowser().scripting.executeScript({
      target: { tabId: tab.id },
      func: () => document.documentElement.outerHTML
    });

    const html = results[0].result;

    // Screenshot der aktuellen Ansicht aufnehmen (optional)
    let screenshot = null;
    try {
      screenshot = await getBrowser().tabs.captureVisibleTab(tab.windowId, { format: 'png' });
    } catch (e) {
      console.warn('Screenshot fehlgeschlagen', e);
    }

    let body = JSON.stringify({ url: tab.url, html, screenshot });
    let screenshotDropped = false;
    if (screenshot && byteLength(body) > MAX_IMPORT_BYTES) {
      // Lieber ohne Screenshot senden als komplett fehlschlagen.
      body = JSON.stringify({ url: tab.url, html, screenshot: null });
      screenshotDropped = true;
    }
    if (byteLength(body) > MAX_IMPORT_BYTES) {
      showStatus('⚠️ Seite ist zu groß zum Senden', true);
      return;
    }

    const response = await fetch(`${SERVER_URL}/import`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-api-token': token },
      body
    });

    if (response.status === 403) {
      handleForbidden();
    } else if (response.ok) {
      showStatus(screenshotDropped
        ? '✅ Gesendet (ohne Screenshot – zu groß)'
        : '✅ Erfolgreich gesendet!');
    } else {
      showStatus(`⚠️ App meldet Fehler (${response.status})`, true);
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

  try {
    const token = await requireToken();
    if (!token) return;

    showStatus('⏳ Profil wird geladen…', false, 0);

    // 1. Fetch profile from the local app
    const response = await fetch(`${SERVER_URL}/profile`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json', 'x-api-token': token }
    });

    if (response.status === 403) {
      handleForbidden();
      return;
    }

    if (!response.ok) {
      showStatus('⚠️ App nicht erreichbar', true);
      return;
    }

    const profile = await response.json();

    if (profile.error) {
      showStatus('⚠️ Kein Profil hinterlegt', true);
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
