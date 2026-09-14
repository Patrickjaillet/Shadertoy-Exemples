(function () {
  const state = {
    index: [],
    byCategory: new Map(),
    current: null,
    filter: ''
  };

  const el = {
    sidebarToggle: document.getElementById('sidebar-toggle'),
    sidebar: document.getElementById('sidebar'),
    searchInput: document.getElementById('search-input'),
    categoryList: document.getElementById('category-list'),
    currentTitle: document.getElementById('current-title'),
    codeEditor: document.getElementById('code-editor'),
    canvas: document.getElementById('shader-canvas'),
    viewportPlaceholder: document.getElementById('viewport-placeholder'),
    viewportError: document.getElementById('viewport-error'),
    btnCopy: document.getElementById('btn-copy'),
    btnPlay: document.getElementById('btn-play'),
    btnPause: document.getElementById('btn-pause'),
    btnReset: document.getElementById('btn-reset'),
    btnAbout: document.getElementById('btn-about'),
    btnAboutClose: document.getElementById('btn-about-close'),
    aboutOverlay: document.getElementById('about-overlay')
  };

  let runtime = null;
  try {
    runtime = new ShaderToyRuntime(el.canvas);
  } catch (err) {
    console.error(err);
  }

  const codeMirror = CodeMirror(el.codeEditor, {
    value: '',
    mode: 'text/x-csrc',
    theme: 'dracula',
    lineNumbers: true,
    readOnly: true,
    viewportMargin: Infinity
  });

  const THUMB_PREFIX = 'shadertoy-thumb-';

  function getThumbnail(num) {
    try {
      return localStorage.getItem(THUMB_PREFIX + num);
    } catch (err) {
      return null;
    }
  }

  function saveThumbnail(num, dataUrl) {
    try {
      localStorage.setItem(THUMB_PREFIX + num, dataUrl);
    } catch (err) {
      // Stockage plein ou indisponible (navigation privée) : on continue sans miniature persistée.
    }
  }

  function captureThumbnail(num) {
    if (getThumbnail(num)) return;
    try {
      const dataUrl = el.canvas.toDataURL('image/jpeg', 0.6);
      saveThumbnail(num, dataUrl);
      renderSidebar();
    } catch (err) {
      // Canvas potentiellement "tainted" ou navigateur restrictif : on ignore silencieusement.
    }
  }

  function groupByCategory(entries) {
    const map = new Map();
    for (const entry of entries) {
      if (!map.has(entry.category)) map.set(entry.category, []);
      map.get(entry.category).push(entry);
    }
    return map;
  }

  function matchesFilter(entry, filter) {
    if (!filter) return true;
    const haystack = `${entry.title} ${entry.num}`.toLowerCase();
    return haystack.includes(filter);
  }

  function renderSidebar() {
    el.categoryList.innerHTML = '';
    const categories = [...state.byCategory.keys()].sort((a, b) => a.localeCompare(b, 'fr'));

    for (const category of categories) {
      const entries = state.byCategory.get(category).filter(e => matchesFilter(e, state.filter));
      if (state.filter && entries.length === 0) continue;

      const group = document.createElement('div');
      group.className = 'category-group';

      const header = document.createElement('button');
      header.className = 'category-header';
      header.innerHTML = `<span>${category}</span><span class="category-count">${entries.length}</span>`;
      header.addEventListener('click', () => group.classList.toggle('collapsed'));

      const list = document.createElement('ul');
      list.className = 'shader-list';

      for (const entry of entries) {
        const item = document.createElement('li');
        item.className = 'shader-item';
        if (state.current && state.current.num === entry.num) item.classList.add('active');

        const btn = document.createElement('button');
        btn.className = 'shader-item-btn';

        const thumb = getThumbnail(entry.num);
        if (thumb) {
          const img = document.createElement('img');
          img.className = 'shader-thumb';
          img.src = thumb;
          img.alt = '';
          btn.appendChild(img);
        }

        const label = document.createElement('span');
        label.textContent = `${entry.num} — ${entry.title}`;
        btn.appendChild(label);

        if (entry.unsupported) {
          const badge = document.createElement('span');
          badge.className = 'unsupported-badge';
          badge.textContent = 'aperçu non disponible';
          btn.appendChild(badge);
        }
        btn.addEventListener('click', () => selectShader(entry.num));

        item.appendChild(btn);
        list.appendChild(item);
      }

      group.appendChild(header);
      group.appendChild(list);
      el.categoryList.appendChild(group);
    }
  }

  async function selectShader(num, options) {
    const opts = options || {};
    const entry = state.index.find(e => e.num === num);
    if (!entry) return;

    try {
      const res = await fetch(`data/shaders/${num}.json`);
      const shader = await res.json();

      state.current = shader;
      el.currentTitle.textContent = `${shader.num} — ${shader.title}`;
      codeMirror.setValue(shader.source);
      codeMirror.refresh();
      el.btnCopy.disabled = false;

      renderShader(shader);
      renderSidebar();

      if (!opts.fromHash) {
        setHash(num);
      }
    } catch (err) {
      el.currentTitle.textContent = `Erreur de chargement du shader ${num}`;
      console.error(err);
    }
  }

  function setHash(num) {
    const target = `#/${num}`;
    if (location.hash !== target) {
      history.pushState(null, '', target);
    }
  }

  function parseHash() {
    const match = location.hash.match(/^#\/(\d+)$/);
    return match ? match[1].padStart(3, '0') : null;
  }

  function handleHashChange() {
    const num = parseHash();
    if (num && state.index.some(e => e.num === num)) {
      selectShader(num, { fromHash: true });
    }
  }

  function showViewportError(message) {
    el.viewportPlaceholder.hidden = true;
    el.viewportError.hidden = false;
    el.viewportError.textContent = message;
    setPlaybackControls(false);
  }

  function clearViewportError() {
    el.viewportPlaceholder.hidden = true;
    el.viewportError.hidden = true;
  }

  function setPlaybackControls(enabled) {
    el.btnPlay.disabled = !enabled;
    el.btnPause.disabled = !enabled;
    el.btnReset.disabled = !enabled;
  }

  function renderShader(shader) {
    if (shader.unsupported) {
      showViewportError(`Aperçu non disponible : ${shader.unsupportedReason}\n\nLe code reste consultable et copiable ci-dessous.`);
      return;
    }
    if (!runtime) {
      showViewportError('WebGL non disponible sur ce navigateur.');
      return;
    }
    try {
      runtime.load(shader.source);
      clearViewportError();
      setPlaybackControls(true);
      setTimeout(() => captureThumbnail(shader.num), 400);
    } catch (err) {
      showViewportError(err.message || String(err));
    }
  }

  function copyCode() {
    if (!state.current) return;
    navigator.clipboard.writeText(state.current.source).then(() => {
      const original = el.btnCopy.textContent;
      el.btnCopy.textContent = 'Copié !';
      setTimeout(() => { el.btnCopy.textContent = original; }, 1500);
    });
  }

  function bindEvents() {
    el.searchInput.addEventListener('input', (e) => {
      state.filter = e.target.value.trim().toLowerCase();
      renderSidebar();
    });

    el.sidebarToggle.addEventListener('click', () => {
      el.sidebar.classList.toggle('open');
    });

    el.btnCopy.addEventListener('click', copyCode);

    el.btnPlay.addEventListener('click', () => runtime && runtime.play());
    el.btnPause.addEventListener('click', () => runtime && runtime.pause());
    el.btnReset.addEventListener('click', () => runtime && runtime.reset());

    window.addEventListener('popstate', handleHashChange);
    window.addEventListener('hashchange', handleHashChange);

    el.btnAbout.addEventListener('click', () => { el.aboutOverlay.hidden = false; });
    el.btnAboutClose.addEventListener('click', () => { el.aboutOverlay.hidden = true; });
    el.aboutOverlay.addEventListener('click', (e) => {
      if (e.target === el.aboutOverlay) el.aboutOverlay.hidden = true;
    });
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && !el.aboutOverlay.hidden) el.aboutOverlay.hidden = true;
    });
  }

  async function init() {
    bindEvents();
    const res = await fetch('data/shaders.json');
    state.index = await res.json();
    state.byCategory = groupByCategory(state.index);
    renderSidebar();

    const num = parseHash();
    if (num && state.index.some(e => e.num === num)) {
      selectShader(num, { fromHash: true });
    }
  }

  init();
})();
