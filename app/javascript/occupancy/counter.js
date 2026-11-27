const POLL_INTERVAL_MS = 15000;

let timer = null;

function findCounter() {
  return document.getElementById('occupancy-counter');
}

function render(data) {
  // Look up on every render: Vue replaces this element when it mounts on the order screen
  const counter = findCounter();
  if (counter === null) return;

  const count = counter.querySelector('[data-occupancy-count]');
  const status = counter.querySelector('[data-occupancy-status]');

  if (data.status === 'open') {
    count.textContent = data.count;
    status.textContent = '';
  } else if (data.status === 'closed') {
    count.textContent = '';
    status.textContent = 'Bar gesloten';
  } else {
    count.textContent = '-';
    status.textContent = 'niet beschikbaar';
  }
}

function refresh() {
  const counter = findCounter();
  if (counter === null || document.hidden) return;

  fetch(counter.dataset.url, { headers: { Accept: 'application/json' } })
    .then((response) => (response.ok ? response.json() : { status: 'unavailable' }))
    .then(render)
    .catch(() => render({ status: 'unavailable' }));
}

document.addEventListener('turbo:load', () => {
  clearInterval(timer);
  timer = null;

  if (findCounter() !== null) {
    refresh();
    timer = setInterval(refresh, POLL_INTERVAL_MS);
  }
});
