/**
 * Add listener for theme mode toggle
 */

const $toggle = document.getElementById('mode-toggle');

export function modeWatcher() {

  if (!$toggle) {
    return;
  }

  $toggle.addEventListener('click', () => {
    var root = document.documentElement 
    var cur = root.getAttribute('data-mode') || 'light';
    var next = cur === 'light' ? 'dark' : 'light';

    root.setAttribute('data-mode', next);

    try {
      localStorage.setItem('theme', next);
    } catch(e) {}
  });
}
