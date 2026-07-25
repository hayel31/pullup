const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');

const root = __dirname;
const output = path.join(root, 'public');
const bundleArchive = path.join(root, 'main.dart.js.gz');
const skippedEntries = new Set([
  '.gitignore',
  '.vercel',
  'build.cjs',
  'main.dart.js',
  'main.dart.js.gz',
  'public',
  'vercel.json',
]);

if (!fs.existsSync(bundleArchive)) {
  throw new Error('Missing compressed Flutter bundle: main.dart.js.gz');
}

fs.rmSync(output, {force: true, recursive: true});
fs.mkdirSync(output, {recursive: true});

for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
  if (skippedEntries.has(entry.name)) {
    continue;
  }
  fs.cpSync(path.join(root, entry.name), path.join(output, entry.name), {
    recursive: true,
  });
}

const bundle = zlib.gunzipSync(fs.readFileSync(bundleArchive));
fs.writeFileSync(path.join(output, 'main.dart.js'), bundle);

console.log(`Prepared PULLUP web output (${bundle.length} bundle bytes).`);
