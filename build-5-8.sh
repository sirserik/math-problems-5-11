#!/usr/bin/env bash
set -euo pipefail
eval "$(/usr/libexec/path_helper)"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT_PDF="Сборник-задач-5-8-класс.pdf"
COMBINED_MD="_combined.md"

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
  "Глава-13-Алгебраические-выражения-и-многочлены"
  "Глава-14-Формулы-сокращённого-умножения"
  "Глава-15-Линейные-уравнения-и-функции"
  "Глава-16-Рациональные-дроби"
  "Глава-17-Квадратные-корни"
  "Глава-18-Квадратные-уравнения"
  "Глава-19-Неравенства"
  "Глава-20-Начальная-геометрия-и-треугольники"
  "Глава-21-Четырёхугольники-и-площади"
  "Глава-22-Подобие-и-окружность"
)

CHAPTER_FILES=(
  "README.md"
  "00-Теория.md"
  "01-Примеры.md"
  "02-А-Задачи.md"
  "03-Б-Задачи.md"
  "04-В-Задачи.md"
)

echo "Собираю Markdown..."

# YAML header
cat > "$COMBINED_MD" << 'YAML_END'
---
title: "Сборник задач по математике"
subtitle: "для 5–8 классов · Улучшенное издание"
author: "На основе лучших задачников"
date: "2026"
lang: ru
documentclass: report
classoption:
  - a4paper
  - 12pt
geometry:
  - top=2cm
  - bottom=2.5cm
  - left=2cm
  - right=2cm
mainfont: "Times New Roman"
sansfont: "Arial"
monofont: "Menlo"
linestretch: 1.3
toc: true
toc-depth: 2
numbersections: false
colorlinks: true
linkcolor: "NavyBlue"
urlcolor: "NavyBlue"
header-includes:
  - |
    \usepackage{polyglossia}
    \setdefaultlanguage{russian}
    \setmainfont[Script=Cyrillic]{Times New Roman}
    \setsansfont[Script=Cyrillic]{Arial}
    \setmonofont{Menlo}
    \newfontfamily\cyrillicfont[Script=Cyrillic]{Times New Roman}
    \newfontfamily\cyrillicfontsf[Script=Cyrillic]{Arial}
    \newfontfamily\cyrillicfonttt{Menlo}
    \usepackage{fancyhdr}
    \pagestyle{fancy}
    \fancyhead[L]{\small\itshape Сборник задач · 5–8 класс}
    \fancyhead[R]{\small\thepage}
    \fancyhead[C]{}
    \fancyfoot{}
    \renewcommand{\headrulewidth}{0.4pt}
---
YAML_END

echo "" >> "$COMBINED_MD"

# Main README
if [[ -f "README.md" ]]; then
  cat "README.md" >> "$COMBINED_MD"
  echo -e "\n\n\\\\newpage\n" >> "$COMBINED_MD"
fi

file_count=0

for chapter in "${CHAPTERS[@]}"; do
  [[ ! -d "$chapter" ]] && continue
  echo "  $chapter"
  echo -e "\n\\\\newpage\n" >> "$COMBINED_MD"

  first=true
  for md_file in "${CHAPTER_FILES[@]}"; do
    filepath="$chapter/$md_file"
    [[ ! -f "$filepath" ]] && continue
    if [[ "$first" = true ]]; then
      first=false
    else
      echo -e "\n\\\\newpage\n" >> "$COMBINED_MD"
    fi
    cat "$filepath" >> "$COMBINED_MD"
    echo "" >> "$COMBINED_MD"
    ((file_count++))
  done
done

echo "Собрано: $file_count файлов"
echo "Генерирую PDF (xelatex)... Это займёт несколько минут."

pandoc "$COMBINED_MD" \
  --pdf-engine=xelatex \
  --from=markdown+tex_math_dollars+pipe_tables+yaml_metadata_block+fenced_code_blocks+strikeout \
  --top-level-division=chapter \
  --highlight-style=tango \
  -V colorlinks=true \
  -o "$OUTPUT_PDF" 2>&1

rm -f "$COMBINED_MD"

if [[ -f "$OUTPUT_PDF" ]]; then
  size=$(du -h "$OUTPUT_PDF" | cut -f1)
  echo ""
  echo "═══════════════════════════════════════════════════"
  echo "PDF создан: $SCRIPT_DIR/$OUTPUT_PDF ($size)"
  echo "═══════════════════════════════════════════════════"
else
  echo "Ошибка: PDF не создан"
  exit 1
fi
