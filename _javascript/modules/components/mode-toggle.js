/**
 * Add listener for theme mode toggle
 */

const $toggle = document.getElementById('mode-toggle');

export function modeWatcher() {
  console.log('mode-toggle.js loaded');

  if (!$toggle) {
    return;
  }

  $toggle.addEventListener('click', () => {
    var root = document.documentElement 
    var cur = root.getAttribute('data-mode') || 'light';
    var next = cur === 'light' ? 'dark' : 'light';

    console.log('call here');

    root.setAttribute('data-mode', next);

    try {
      localStorage.setItem('theme', next);
    } catch(e) {}
  });
}
