(function (global) {
  // Fichiers ffmpeg.wasm servis en local (assets/vendor/ffmpeg/) plutot que
  // depuis un CDN : le Worker interne de @ffmpeg/ffmpeg utilise importScripts()
  // avec resolution de chemin relative pour charger ffmpeg-core.js puis son
  // .wasm associe, ce qui echoue de maniere fiable avec des blob: URLs
  // generees a la volee depuis un CDN cross-origin. Des chemins relatifs
  // reels, servis par le meme site, evitent ce probleme.
  const VENDOR_BASE = 'assets/vendor/ffmpeg';
  const FFMPEG_BASE = `${VENDOR_BASE}/ffmpeg.js`;
  const FFMPEG_UTIL = `${VENDOR_BASE}/ffmpeg-util.js`;
  const CORE_BASE = VENDOR_BASE;

  let loadPromise = null;

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = src;
      script.onload = resolve;
      script.onerror = () => reject(new Error(`Échec du chargement de ${src}`));
      document.head.appendChild(script);
    });
  }

  async function ensureFFmpegLoaded(onProgress) {
    if (loadPromise) return loadPromise;

    loadPromise = (async () => {
      if (onProgress) onProgress('Chargement de ffmpeg.wasm...');
      await loadScript(FFMPEG_UTIL);
      await loadScript(FFMPEG_BASE);

      const { FFmpeg } = global.FFmpegWASM;

      const ffmpeg = new FFmpeg();
      if (onProgress) {
        ffmpeg.on('progress', ({ progress }) => {
          onProgress(`Encodage... ${Math.round(progress * 100)}%`);
        });
      }

      const coreURL = new URL(`${CORE_BASE}/ffmpeg-core.js`, location.href).href;
      const wasmURL = new URL(`${CORE_BASE}/ffmpeg-core.wasm`, location.href).href;
      await ffmpeg.load({ coreURL, wasmURL });

      return ffmpeg;
    })();

    return loadPromise;
  }

  function captureFrameBlob(canvas) {
    return new Promise((resolve) => {
      canvas.toBlob((blob) => resolve(blob), 'image/png');
    });
  }

  /**
   * Capture `durationSeconds` de rendu deterministe a `fps` images par seconde
   * pour le shader charge dans `runtime`, puis assemble un fichier .mp4 via
   * ffmpeg.wasm et retourne son URL de telechargement (blob: URL).
   *
   * onProgress(message) est appele pour informer l'UI de l'avancement.
   */
  async function exportVideo(runtime, { durationSeconds, fps }, onProgress) {
    const totalFrames = Math.max(1, Math.round(durationSeconds * fps));
    const frameDuration = 1 / fps;
    const frameFiles = [];

    for (let i = 0; i < totalFrames; i++) {
      const time = i * frameDuration;
      runtime.renderFrameAt(time, i, frameDuration);
      const blob = await captureFrameBlob(runtime.canvas);
      const buf = new Uint8Array(await blob.arrayBuffer());
      frameFiles.push(buf);
      if (onProgress) onProgress(`Capture des images... ${i + 1}/${totalFrames}`);
    }

    const ffmpeg = await ensureFFmpegLoaded(onProgress);

    for (let i = 0; i < frameFiles.length; i++) {
      const name = `frame${String(i).padStart(5, '0')}.png`;
      await ffmpeg.writeFile(name, frameFiles[i]);
    }

    if (onProgress) onProgress('Assemblage de la vidéo...');
    await ffmpeg.exec([
      '-framerate', String(fps),
      '-i', 'frame%05d.png',
      '-c:v', 'libx264',
      '-pix_fmt', 'yuv420p',
      'output.mp4'
    ]);

    const data = await ffmpeg.readFile('output.mp4');
    const videoBlob = new Blob([data.buffer], { type: 'video/mp4' });
    return URL.createObjectURL(videoBlob);
  }

  global.ShaderVideoExport = { exportVideo };
})(window);
