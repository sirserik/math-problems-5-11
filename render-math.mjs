// render-math.mjs — Рендерит LaTeX-формулы в HTML через KaTeX
import katex from '/tmp/node_modules/katex/dist/katex.mjs';
import { readFileSync, writeFileSync } from 'fs';

const inputFile = process.argv[2];
const outputFile = process.argv[3];

let html = readFileSync(inputFile, 'utf-8');

// Рендерим display math: $$...$$
html = html.replace(/\$\$([^$]+?)\$\$/g, (match, tex) => {
  try {
    return katex.renderToString(tex.trim(), { displayMode: true, throwOnError: false, output: 'html' });
  } catch (e) {
    return `<span class="math-error" title="${e.message}">${tex}</span>`;
  }
});

// Рендерим inline math: $...$  (но не $$ и не внутри code/pre)
// Сначала защищаем <code> и <pre> блоки
const codeBlocks = [];
html = html.replace(/<(code|pre)[^>]*>[\s\S]*?<\/\1>/gi, (match) => {
  codeBlocks.push(match);
  return `__CODE_BLOCK_${codeBlocks.length - 1}__`;
});

// Теперь рендерим inline math
html = html.replace(/\$([^$\n]+?)\$/g, (match, tex) => {
  // Пропускаем если это цена/валюта (цифра$)
  if (/^\d/.test(tex) && /\d$/.test(tex)) return match;
  try {
    return katex.renderToString(tex.trim(), { displayMode: false, throwOnError: false, output: 'html' });
  } catch (e) {
    return `<span class="math-error" title="${e.message}">${tex}</span>`;
  }
});

// Восстанавливаем code блоки
html = html.replace(/__CODE_BLOCK_(\d+)__/g, (match, idx) => codeBlocks[parseInt(idx)]);

// Добавляем KaTeX CSS (встраиваем inline)
const katexCSS = readFileSync('/tmp/node_modules/katex/dist/katex.min.css', 'utf-8');

// Вставляем CSS перед </head> или в начало
if (html.includes('</head>')) {
  html = html.replace('</head>', `<style>${katexCSS}</style>\n</head>`);
} else {
  html = `<style>${katexCSS}</style>\n` + html;
}

// Копируем шрифты KaTeX — используем base64 встроенные или ссылки
// Заменяем url(fonts/...) на абсолютные пути
html = html.replace(/url\(fonts\//g, 'url(/tmp/node_modules/katex/dist/fonts/');

writeFileSync(outputFile, html, 'utf-8');

// Подсчёт формул
const mathCount = (html.match(/class="katex"/g) || []).length;
console.log(`Отрендерено формул: ${mathCount}`);
