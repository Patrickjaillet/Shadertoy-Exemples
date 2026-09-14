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

function extractTitle(content, num, category) {
  const nameMatch = content.match(/^\/\/\s*NAME\s*:\s*(.+)$/mi);
  if (nameMatch) {
    return nameMatch[1].trim();
  }
  return `${category.charAt(0).toUpperCase()}${category.slice(1)} ${num}`;
}

function extractImageSource(content) {
  const marker = /\/\/\s*====\s*Image\s*\(image\)\s*====/i;
  const match = marker.exec(content);
  if (!match) return content.trim();
  return content.slice(match.index + match[0].length).trim();
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
    const content = fs.readFileSync(path.join(item.dir, item.file), 'utf-8');
    const title = extractTitle(content, num, item.category);
    const source = extractImageSource(content);

    entries.push({
      num,
      title,
      category: item.category,
      file: item.relPath.replace(/\\/g, '/'),
      source
    });
  }

  entries.sort((a, b) => Number(a.num) - Number(b.num));
  return entries;
}

function writeOutputs(entries) {
  fs.mkdirSync(shadersDataDir, { recursive: true });

  const index = entries.map(({ num, title, category, file }) => ({ num, title, category, file }));
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
