/**
 * Add listener for theme mode toggle
 */

import Theme from "../../theme";

const $toggle = document.getElementById('mode-toggle');

export function modeWatcher() {

  if (!$toggle) {
    return;
  }

  $toggle.addEventListener('click', () => {
    Theme.flip();
  });
}
