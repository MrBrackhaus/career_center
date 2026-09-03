/**
 * Bewerbungszentrale - Form Autofill Content Script
 * Injected into job portal pages by the browser extension.
 * Uses heuristic label/name matching to fill standard application form fields.
 */
(function(profile) {
  'use strict';

  let filledCount = 0;

  // ── Helper: try to fill a single input/textarea/select ────────────────────
  function fillField(el, value) {
    if (!value || !el || el.disabled || el.readOnly) return false;
    const tag = el.tagName.toLowerCase();

    if (tag === 'select') {
      // Try to match one of the options
      for (const opt of el.options) {
        if (opt.text.toLowerCase().includes(value.toLowerCase()) ||
            opt.value.toLowerCase().includes(value.toLowerCase())) {
          el.value = opt.value;
          el.dispatchEvent(new Event('change', { bubbles: true }));
          filledCount++;
          return true;
        }
      }
      return false;
    }

    // For inputs and textareas: use native input value setter so React/Vue detect changes
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(
      window.HTMLInputElement.prototype, 'value'
    )?.set ?? Object.getOwnPropertyDescriptor(
      window.HTMLTextAreaElement.prototype, 'value'
    )?.set;

    if (nativeInputValueSetter) {
      nativeInputValueSetter.call(el, value);
    } else {
      el.value = value;
    }
    el.dispatchEvent(new Event('input',  { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
    filledCount++;
    return true;
  }

  // ── Scoring: how well does a field match a set of keywords? ──────────────
  function score(el, keywords) {
    const targets = [
      el.name, el.id, el.placeholder, el.autocomplete,
      el.getAttribute('aria-label'),
      el.getAttribute('data-testid'),
      // Label text associated via htmlFor
      (el.id ? document.querySelector(`label[for="${el.id}"]`)?.textContent : '') ?? '',
      // Nearest label ancestor / sibling text
      el.closest('label')?.textContent ?? '',
      el.previousElementSibling?.textContent ?? '',
    ].join(' ').toLowerCase();

    return keywords.reduce((acc, kw) => acc + (targets.includes(kw) ? 1 : 0), 0);
  }

  // ── Field map: profile key → possible input types / keywords ─────────────
  const FIELD_MAP = [
    { key: 'firstName', type: 'text',  kw: ['vorname','first','firstname','given','fname','prenom'] },
    { key: 'lastName',  type: 'text',  kw: ['nachname','last','lastname','surname','lname','family','nom'] },
    { key: 'fullName',  type: 'text',  kw: ['name','vollständig','full','fullname','complete'] },
    { key: 'email',     type: 'email', kw: ['email','e-mail','mail','courriel'] },
    { key: 'phone',     type: 'tel',   kw: ['phone','tel','telefon','mobile','mobil','handy','cell'] },
    { key: 'address',   type: 'text',  kw: ['adresse','address','street','straße','strasse'] },
    { key: 'zip',       type: 'text',  kw: ['plz','zip','postal','postleitzahl'] },
    { key: 'city',      type: 'text',  kw: ['city','ort','stadt','ville','location'] },
    { key: 'birthdate', type: 'date',  kw: ['birth','geburt','dob','date of birth','geboren'] },
    { key: 'linkedin',  type: 'url',   kw: ['linkedin','xing'] },
    { key: 'website',   type: 'url',   kw: ['website','homepage','portfolio','url','www'] },
  ];

  // ── Main fill loop ─────────────────────────────────────────────────────────
  const allInputs = Array.from(
    document.querySelectorAll('input:not([type=hidden]):not([type=submit]):not([type=button]):not([type=checkbox]):not([type=radio]), textarea, select')
  );

  for (const { key, type, kw } of FIELD_MAP) {
    const value = profile[key];
    if (!value) continue;

    // Collect candidates with scores
    const candidates = allInputs
      .filter(el => {
        // If specific type, prefer matching inputs
        if (type === 'email' && el.type && el.type !== 'email' && el.type !== 'text') return false;
        if (type === 'tel'   && el.type && el.type !== 'tel'   && el.type !== 'text') return false;
        return true;
      })
      .map(el => ({ el, s: score(el, kw) }))
      .filter(c => c.s > 0)
      .sort((a, b) => b.s - a.s);

    if (candidates.length > 0 && !candidates[0].el._bzFilled) {
      candidates[0].el._bzFilled = true; // mark to avoid double-filling
      fillField(candidates[0].el, value);
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
  document.head.appendChild(style);

  toast.innerHTML = `<span style="font-size:20px">🎯</span>
    <span><strong>Bewerbungszentrale</strong><br>
    ${filledCount} Felder ausgefüllt</span>`;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 4000);

})(window.__bzProfile);
