/**
 * Bewerbungszentrale - Form Autofill Content Script
 * Injected into job portal pages by the browser extension.
 * Uses heuristic label/name matching to fill standard application form fields.
 */
(function(profile) {
  'use strict';

  if (!profile || typeof profile !== 'object') return;

  let filledCount = 0;

  // ── Text normalization ────────────────────────────────────────────────────
  // Splits attribute/label text into lowercase word tokens: camelCase and
  // PascalCase are split ("firstName" → first, name), everything that is not
  // a letter acts as separator ("company_name" → company, name).
  function tokenize(text) {
    if (!text) return [];
    return String(text)
      .replace(/([\p{Ll}\d])(\p{Lu})/gu, '$1 $2')
      .replace(/(\p{Lu}+)(\p{Lu}\p{Ll})/gu, '$1 $2')
      .toLowerCase()
      .split(/[^\p{L}]+/u)
      .filter(Boolean);
  }

  // A keyword token matches a text token exactly, or – for keywords with at
  // least 4 letters – as a word prefix ("telefon" → "telefonnummer",
  // "geburt" → "geburtsdatum"). Short keywords like "ort" or "tel" must match
  // a whole word, so "passwort" or "hotel" never match.
  function tokenMatches(token, kw) {
    return token === kw || (kw.length >= 4 && token.startsWith(kw));
  }

  // Multi-word keywords ("date of birth") must appear as consecutive words.
  function containsKeyword(tokens, kwTokens) {
    if (kwTokens.length === 1) {
      return tokens.some(t => tokenMatches(t, kwTokens[0]));
    }
    for (let i = 0; i + kwTokens.length <= tokens.length; i++) {
      if (kwTokens.every((k, j) => tokens[i + j] === k)) return true;
    }
    return false;
  }

  // ── Collect descriptive text of a form field ──────────────────────────────
  function labelText(el) {
    const parts = [];
    if (el.labels) {
      for (const label of el.labels) parts.push(label.textContent);
    }
    if (el.id) {
      try {
        const label = document.querySelector(`label[for="${CSS.escape(el.id)}"]`);
        if (label) parts.push(label.textContent);
      } catch (_) { /* ignore invalid selectors */ }
    }
    const labelledBy = el.getAttribute('aria-labelledby');
    if (labelledBy) {
      for (const id of labelledBy.split(/\s+/)) {
        const ref = id && document.getElementById(id);
        if (ref) parts.push(ref.textContent);
      }
    }
    parts.push(el.closest('label')?.textContent ?? '');
    parts.push(el.previousElementSibling?.textContent ?? '');
    return parts.join(' ');
  }

  function fieldTokens(el) {
    return tokenize([
      el.name, el.id, el.placeholder, el.getAttribute('autocomplete'),
      el.getAttribute('aria-label'),
      el.getAttribute('data-testid'),
      labelText(el),
    ].filter(Boolean).join(' '));
  }

  // ── Field type helpers ────────────────────────────────────────────────────
  function fieldType(el) {
    const tag = el.tagName.toLowerCase();
    if (tag === 'select') return 'select';
    if (tag === 'textarea') return 'textarea';
    return (el.getAttribute('type') || 'text').toLowerCase();
  }

  function isVisible(el) {
    return el.getClientRects().length > 0;
  }

  function isFilled(el) {
    if (el._bzFilled) return true;
    if (fieldType(el) === 'select') {
      return el.selectedIndex > 0 && el.value !== '';
    }
    return typeof el.value === 'string' && el.value.trim() !== '';
  }

  // German date (dd.mm.yyyy, also d.m.yyyy) → ISO yyyy-mm-dd for <input type=date>.
  function toIsoDate(value) {
    const v = String(value).trim();
    if (/^\d{4}-\d{2}-\d{2}$/.test(v)) return v;
    const m = v.match(/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/);
    if (!m) return null;
    const day = m[1].padStart(2, '0');
    const month = m[2].padStart(2, '0');
    return `${m[3]}-${month}-${day}`;
  }

  // ── Helper: try to fill a single input/textarea/select ────────────────────
  function fillField(el, rawValue) {
    if (!rawValue || !el || el.disabled || el.readOnly) return false;
    let value = String(rawValue);
    const type = fieldType(el);

    if (type === 'select') {
      // Try to match one of the options
      const needle = value.toLowerCase();
      for (const opt of el.options) {
        if (!opt.value && !opt.text.trim()) continue;
        if (opt.text.toLowerCase().includes(needle) ||
            opt.value.toLowerCase().includes(needle)) {
          el.value = opt.value;
          el.dispatchEvent(new Event('change', { bubbles: true }));
          filledCount++;
          return true;
        }
      }
      return false;
    }

    if (type === 'date') {
      const iso = toIsoDate(value);
      if (!iso) return false;
      value = iso;
    }

    // Use the native value setter of the element's own prototype so that
    // React/Vue detect the change (HTMLInputElement setter on a <textarea>
    // would throw "Illegal invocation").
    const proto = type === 'textarea'
      ? window.HTMLTextAreaElement.prototype
      : window.HTMLInputElement.prototype;
    const nativeSetter = Object.getOwnPropertyDescriptor(proto, 'value')?.set;

    try {
      if (nativeSetter) {
        nativeSetter.call(el, value);
      } else {
        el.value = value;
      }
    } catch (_) {
      el.value = value;
    }
    el.dispatchEvent(new Event('input',  { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
    filledCount++;
    return true;
  }

  // ── Field map: profile key → allowed input types / keywords ──────────────
  // kw:      keywords (matched word-wise, see tokenMatches)
  // exclude: words that disqualify a field for this key
  // ac:      exact autocomplete values that strongly indicate this key
  const NAME_EXCLUDE = [
    'firma', 'firmenname', 'company', 'unternehmen', 'arbeitgeber', 'employer',
    'organisation', 'organization', 'org', 'user', 'username', 'benutzer',
    'benutzername', 'login', 'account', 'nickname', 'nick', 'datei', 'file',
  ];
  const TEXT = ['text', 'textarea'];

  // "Vor- und Nachname" / "first and last name" is a full-name field, while a
  // field mentioning only one of both belongs to firstName/lastName.
  const FIRST_WORDS = new Set(['vorname', 'vor', 'first', 'firstname', 'given', 'givenname', 'fname']);
  const LAST_WORDS = new Set(['nachname', 'nach', 'last', 'lastname', 'surname', 'family',
    'familyname', 'familienname', 'lname']);
  const hasFirst = tokens => tokens.some(t => FIRST_WORDS.has(t));
  const hasLast = tokens => tokens.some(t => LAST_WORDS.has(t));

  const FIELD_MAP = [
    { key: 'firstName', types: TEXT, ac: ['given-name'],
      kw: ['vorname', 'first', 'firstname', 'given', 'fname', 'prenom'],
      exclude: NAME_EXCLUDE, reject: hasLast },
    { key: 'lastName', types: TEXT, ac: ['family-name'],
      kw: ['nachname', 'familienname', 'last', 'lastname', 'surname', 'lname', 'family', 'nom'],
      exclude: NAME_EXCLUDE, reject: hasFirst },
    { key: 'fullName', types: TEXT, ac: ['name'],
      kw: ['name', 'vollständig', 'full', 'fullname'],
      exclude: NAME_EXCLUDE.concat(['middle']),
      // Only one of first/last name mentioned → not a full-name field.
      reject: tokens => hasFirst(tokens) !== hasLast(tokens),
      bonus: tokens => (hasFirst(tokens) && hasLast(tokens) ? 2 : 0) },
    { key: 'email', types: ['email', 'text'], ac: ['email'],
      kw: ['email', 'e mail', 'mail', 'courriel'] },
    { key: 'phone', types: ['tel', 'text'], ac: ['tel', 'tel-national'],
      kw: ['phone', 'telephone', 'tel', 'telefon', 'mobile', 'mobil', 'handy', 'cell'] },
    { key: 'address', types: TEXT, ac: ['street-address', 'address-line1'],
      kw: ['adresse', 'anschrift', 'address', 'street', 'straße', 'strasse'],
      exclude: ['mail', 'email', 'web', 'webadresse', 'ip'] },
    { key: 'zip', types: TEXT.concat(['number']), ac: ['postal-code'],
      kw: ['plz', 'zip', 'zipcode', 'postal', 'postleitzahl', 'postcode'] },
    { key: 'city', types: TEXT.concat(['select']), ac: ['address-level2'],
      kw: ['city', 'ort', 'wohnort', 'stadt', 'ville', 'location'],
      exclude: ['geburtsort', 'birthplace', 'place', 'birth'] },
    { key: 'birthdate', types: ['date', 'text'], ac: ['bday'],
      kw: ['birth', 'birthday', 'geburt', 'geburtsdatum', 'dob', 'date of birth', 'geboren'],
      exclude: ['ort', 'geburtsort', 'place', 'birthplace', 'country', 'land'] },
    { key: 'linkedin', types: ['url', 'text'],
      kw: ['linkedin', 'xing'] },
    { key: 'website', types: ['url', 'text'], ac: ['url'],
      kw: ['website', 'webseite', 'homepage', 'portfolio', 'url', 'www'],
      exclude: ['linkedin', 'xing', 'github'] },
  ].map(entry => ({
    ...entry,
    kwTokens: entry.kw.map(tokenize),
    excludeSet: new Set(entry.exclude || []),
  }));

  // ── Scoring: how well does a field match a field-map entry? ──────────────
  function score(info, entry) {
    if (info.tokens.some(t => entry.excludeSet.has(t))) return 0;
    if (entry.reject && entry.reject(info.tokens)) return 0;
    let s = entry.kwTokens.reduce(
      (acc, kwTokens) => acc + (containsKeyword(info.tokens, kwTokens) ? 1 : 0), 0);
    if (entry.bonus) s += entry.bonus(info.tokens);
    if (entry.ac && entry.ac.includes(info.autocomplete)) s += 5;
    return s;
  }

  // ── Main fill loop ─────────────────────────────────────────────────────────
  const EXCLUDED_TYPES = new Set([
    'hidden', 'submit', 'button', 'reset', 'image', 'checkbox', 'radio',
    'password', 'file', 'search', 'color', 'range',
  ]);

  const fields = Array.from(document.querySelectorAll('input, textarea, select'))
    .filter(el => !EXCLUDED_TYPES.has(fieldType(el)))
    .filter(el => !el.disabled && !el.readOnly && isVisible(el))
    .map(el => ({
      el,
      type: fieldType(el),
      tokens: fieldTokens(el),
      autocomplete: (el.getAttribute('autocomplete') || '').trim().toLowerCase(),
    }));

  for (const entry of FIELD_MAP) {
    const value = profile[entry.key];
    if (!value) continue;

    // Collect candidates with scores, best first
    const candidates = fields
      .filter(info => entry.types.includes(info.type))
      .map(info => ({ info, s: score(info, entry) }))
      .filter(c => c.s > 0)
      .sort((a, b) => b.s - a.s);

    // Take the best candidate that is still empty; if it is already filled
    // (by the user or an earlier key), try the next one.
    for (const { info } of candidates) {
      if (isFilled(info.el)) continue;
      if (fillField(info.el, value)) {
        info.el._bzFilled = true; // mark to avoid double-filling
        break;
      }
    }
  }

  // ── Result toast ──────────────────────────────────────────────────────────
  const toast = document.createElement('div');
  toast.style.cssText = `
    position:fixed; bottom:24px; right:24px; z-index:2147483647;
    background:#1e1e2e; color:#cdd6f4; padding:12px 20px;
    border-radius:12px; font-family:system-ui,sans-serif; font-size:14px;
    border:1px solid #89b4fa; box-shadow:0 4px 24px rgba(0,0,0,.4);
    display:flex; align-items:center; gap:8px;
    animation:bzSlide .3s ease;
  `;
  const style = document.createElement('style');
  style.textContent = '@keyframes bzSlide{from{transform:translateY(20px);opacity:0}to{transform:translateY(0);opacity:1}}';
  (document.head || document.documentElement).appendChild(style);

  toast.innerHTML = `<span style="font-size:20px">🎯</span>
    <span><strong>Bewerbungszentrale</strong><br>
    ${filledCount} Felder ausgefüllt</span>`;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 4000);

})(window.__bzProfile);
