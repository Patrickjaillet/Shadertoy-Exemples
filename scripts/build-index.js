const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const dataDir = path.join(rootDir, 'data');
const shadersDataDir = path.join(dataDir, 'shaders');

const IGNORED_DIRS = new Set(['.git', 'node_modules', 'scripts', 'data', 'assets']);
const DEFAULT_CATEGORY = 'divers';

function listCategoryDirs() {
  return fs.readdirSync(rootDir, { withFileTypes: true })
    .filter(e => e.isDirectory() && !IGNORED_DIRS.has(e.name))
    .map(e => e.name)
    .sort((a, b) => a.localeCompare(b, 'fr'));
}

function listGlslFiles(dir) {
  return fs.readdirSync(dir)
    .filter(f => /\.glsl$/i.test(f))
    .sort((a, b) => a.localeCompare(b, 'fr'));
}

function buildTitle(num, category) {
  return `${category.charAt(0).toUpperCase()}${category.slice(1)} ${num}`;
}

function detectUnsupported(source) {
  const channels = new Set();
  const channelRe = /\biChannel([0-3])\b/g;
  let m;
  while ((m = channelRe.exec(source)) !== null) {
    channels.add(Number(m[1]));
  }
  if (channels.size > 0) {
    const list = [...channels].sort().map(n => `iChannel${n}`).join(', ');
    return `Texture(s) externe(s) non fournie(s) dans le dépôt (${list}).`;
  }
  if (/\bsamplerCube\b|\btextureCube\b/.test(source)) {
    return 'Cubemap externe non fournie dans le dépôt.';
  }
  return null;
}

function buildEntries() {
  const entries = [];

  const rootFiles = listGlslFiles(rootDir).map(f => ({
    file: f,
    dir: rootDir,
    category: DEFAULT_CATEGORY,
    relPath: f
  }));

  const categoryFiles = [];
  for (const category of listCategoryDirs()) {
    const dir = path.join(rootDir, category);
    for (const f of listGlslFiles(dir)) {
      categoryFiles.push({
        file: f,
        dir,
        category,
        relPath: path.posix.join(category, f)
      });
    }
  }

  const all = [...rootFiles, ...categoryFiles];

  for (const item of all) {
    const numMatch = item.file.match(/^(\d+)-simple\.glsl$/i);
    if (!numMatch) continue;
    const num = numMatch[1];
    const source = fs.readFileSync(path.join(item.dir, item.file), 'utf-8').trim();
    const title = buildTitle(num, item.category);
    const unsupportedReason = detectUnsupported(source);

    entries.push({
      num,
      title,
      category: item.category,
      file: item.relPath.replace(/\\/g, '/'),
      unsupported: unsupportedReason !== null,
      unsupportedReason,
      source
    });
  }

  entries.sort((a, b) => Number(a.num) - Number(b.num));
  return entries;
}

function writeOutputs(entries) {
  fs.mkdirSync(shadersDataDir, { recursive: true });

  const index = entries.map(({ num, title, category, file, unsupported }) => ({ num, title, category, file, unsupported }));
  fs.writeFileSync(
    path.join(dataDir, 'shaders.json'),
    JSON.stringify(index, null, 2),
    'utf-8'
  );

  for (const entry of entries) {
    fs.writeFileSync(
      path.join(shadersDataDir, `${entry.num}.json`),
      JSON.stringify(entry, null, 2),
      'utf-8'
    );
  }
}

const entries = buildEntries();
writeOutputs(entries);
console.log(`Index genere : ${entries.length} shaders -> data/shaders.json + data/shaders/<NNN>.json`);
