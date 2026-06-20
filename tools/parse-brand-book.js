const fs = require('fs');
const c = fs.readFileSync('Quby Brand Book (standalone).html', 'utf8');
const colors = [...new Set(c.match(/#[0-9A-Fa-f]{6}/gi) || [])].sort();
console.log('COLORS (' + colors.length + '):');
colors.forEach(x => console.log(x));

const keywords = ['Plus Jakarta', 'Space Grotesk', 'JetBrains', 'Typography', 'Color Palette', 'Honey', 'Accent', 'QubyPay', 'wordmark'];
console.log('\nKEYWORDS:');
keywords.forEach(k => {
  const idx = c.indexOf(k);
  if (idx >= 0) console.log(k + ' @ ' + idx + ': ...' + c.slice(idx, idx + 200).replace(/\n/g, ' ') + '...');
});

// Extract embedded HTML chunk
const start = c.indexOf('<!DOCTYPE html>');
if (start >= 0) {
  const chunk = c.slice(start, start + 200000);
  const colorBlocks = chunk.match(/#[0-9A-Fa-f]{6}[^#]{0,100}/gi) || [];
  console.log('\nCOLOR CONTEXT (first 40):');
  colorBlocks.slice(0, 40).forEach(x => console.log(x.slice(0, 120)));
}
