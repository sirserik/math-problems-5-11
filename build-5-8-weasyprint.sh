#!/usr/bin/env bash
#
# build-pdf.sh — Собирает все Markdown-файлы сборника в один PDF
# Использует pandoc → HTML (с KaTeX) → weasyprint → PDF
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT_PDF="Сборник-задач-5-6-класс.pdf"
COMBINED_MD="_combined.md"
OUTPUT_HTML="_combined.html"

# Главы в правильном порядке
CHAPTERS=(
  "Глава-01-Натуральные-числа"
  "Глава-02-Делители-и-кратные"
  "Глава-03-Обыкновенные-дроби"
  "Глава-04-Десятичные-дроби"
  "Глава-05-Выражения-и-уравнения"
  "Глава-06-Проценты-и-пропорции"
  "Глава-07-Рациональные-числа"
  "Глава-08-Текстовые-задачи"
  "Глава-09-Координаты-и-графики"
  "Глава-10-Элементы-геометрии"
  "Глава-11-Множества-и-логика"
  "Глава-12-Комбинаторика-и-олимпиадные-задачи"
)

CHAPTER_FILES=(
  "README.md"
  "00-Теория.md"
  "01-Примеры.md"
  "02-А-Задачи.md"
  "03-Б-Задачи.md"
  "04-В-Задачи.md"
)

# ─── Сборка единого Markdown-файла ───────────────────────────────────
echo "Собираю Markdown-файлы..."

> "$COMBINED_MD"

# Титульная страница
cat >> "$COMBINED_MD" << 'TITLE_END'
<div class="title-page">
<h1>Сборник задач по математике</h1>
<h2>для 5–6 классов</h2>
<h3>Улучшенное издание</h3>
<p class="subtitle">~2 040 задач · 12 глав · Теория + Примеры + Задачи трёх уровней</p>
<p class="sources">Составлено на основе лучших задачников:<br>
Пирютко (5 кл., 6 кл.) · Задачник 57-й школы · Шарыгин · Пономарёв, Сырнев</p>
<p class="year">2026</p>
</div>

<div style="page-break-after: always;"></div>

TITLE_END

# Оглавление из README
if [[ -f "README.md" ]]; then
  cat "README.md" >> "$COMBINED_MD"
  echo -e "\n\n<div style=\"page-break-after: always;\"></div>\n" >> "$COMBINED_MD"
fi

file_count=0

for chapter in "${CHAPTERS[@]}"; do
  if [[ ! -d "$chapter" ]]; then
    echo "  Папка не найдена: $chapter (пропускаю)"
    continue
  fi
  echo "  $chapter"

  first_file_in_chapter=true
  for md_file in "${CHAPTER_FILES[@]}"; do
    filepath="$chapter/$md_file"
    if [[ ! -f "$filepath" ]]; then
      continue
    fi
    if [[ "$first_file_in_chapter" = true ]]; then
      first_file_in_chapter=false
    else
      echo -e "\n---\n" >> "$COMBINED_MD"
    fi
    cat "$filepath" >> "$COMBINED_MD"
    echo "" >> "$COMBINED_MD"
    ((file_count++))
  done
  echo -e "\n<div style=\"page-break-after: always;\"></div>\n" >> "$COMBINED_MD"
done

echo "Собрано файлов: $file_count"

# ─── Markdown → HTML с pandoc ──────────────────────────────────────
echo "Конвертирую Markdown → HTML..."

pandoc "$COMBINED_MD" \
  --from=markdown+tex_math_dollars+pipe_tables+strikeout+fenced_code_blocks \
  --to=html5 \
  --standalone \
  --metadata title="Сборник задач по математике для 5–6 классов" \
  -o "$OUTPUT_HTML"

# ─── Рендерим LaTeX-формулы через KaTeX ──────────────────────────
echo "Рендерю LaTeX-формулы через KaTeX..."

node "$SCRIPT_DIR/render-math.mjs" "$OUTPUT_HTML" "$OUTPUT_HTML"

# ─── Добавляем стили для PDF ──────────────────────────────────────
echo "Добавляю стили..."

python3 << 'PYEOF'
with open("_combined.html", "r", encoding="utf-8") as f:
    html = f.read()

custom_css = """
<style>
@page {
  size: A4;
  margin: 2cm 2cm 2.5cm 2cm;
  @bottom-center {
    content: counter(page);
    font-size: 10pt;
    color: #555;
  }
}
body {
  font-family: "PT Serif", "Times New Roman", Georgia, serif;
  font-size: 11pt;
  line-height: 1.5;
  color: #1a1a1a;
  max-width: none;
}
h1 { font-size: 20pt; color: #1a5276; border-bottom: 2px solid #1a5276; padding-bottom: 6px; margin-top: 30px; }
h2 { font-size: 16pt; color: #2c3e50; margin-top: 24px; }
h3 { font-size: 13pt; color: #34495e; margin-top: 18px; }
h4 { font-size: 11pt; color: #555; }
table { border-collapse: collapse; width: 100%; margin: 12px 0; font-size: 10pt; }
th, td { border: 1px solid #bbb; padding: 6px 10px; text-align: left; }
th { background-color: #ecf0f1; font-weight: bold; }
tr:nth-child(even) { background-color: #f9f9f9; }
code { background-color: #f4f4f4; padding: 2px 5px; border-radius: 3px; font-size: 10pt; }
pre { background-color: #f4f4f4; padding: 12px; border-radius: 5px; font-size: 9pt; }
blockquote { border-left: 4px solid #1a5276; margin: 12px 0; padding: 8px 16px; background-color: #f0f6fb; color: #2c3e50; }
hr { border: none; border-top: 1px solid #ddd; margin: 20px 0; }
.title-page { text-align: center; padding-top: 120px; page-break-after: always; }
.title-page h1 { font-size: 32pt; border: none; color: #1a5276; margin-bottom: 10px; }
.title-page h2 { font-size: 22pt; color: #2c3e50; font-weight: normal; }
.title-page h3 { font-size: 16pt; color: #7f8c8d; font-weight: normal; }
.title-page .subtitle { font-size: 12pt; color: #555; margin-top: 40px; }
.title-page .sources { font-size: 10pt; color: #888; margin-top: 60px; }
.title-page .year { font-size: 14pt; color: #555; margin-top: 80px; }
p { orphans: 3; widows: 3; }
.katex { font-size: 1em; }
.katex-display { margin: 8px 0; overflow-x: auto; }
</style>
"""

html = html.replace("</head>", custom_css + "\n</head>")

with open("_combined.html", "w", encoding="utf-8") as f:
    f.write(html)

print("Стили добавлены")
PYEOF

# ─── HTML → PDF с weasyprint ────────────────────────────────────────
echo "Генерирую PDF (weasyprint)..."

weasyprint "$OUTPUT_HTML" "$OUTPUT_PDF" 2>&1 | tail -5

# ─── Очистка ─────────────────────────────────────────────────────────
rm -f "$COMBINED_MD" "$OUTPUT_HTML"

# ─── Результат ───────────────────────────────────────────────────────
if [[ -f "$OUTPUT_PDF" ]]; then
  size=$(du -h "$OUTPUT_PDF" | cut -f1)
  echo ""
  echo "═══════════════════════════════════════════════════"
  echo "PDF успешно создан!"
  echo "  Файл: $SCRIPT_DIR/$OUTPUT_PDF"
  echo "  Размер: $size"
  echo "═══════════════════════════════════════════════════"
else
  echo "Ошибка: PDF не был создан"
  exit 1
fi
