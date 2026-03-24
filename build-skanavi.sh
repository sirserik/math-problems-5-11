#!/usr/bin/env bash
set -euo pipefail
eval "$(/usr/libexec/path_helper)"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT_PDF="Сканави-улучшенный.pdf"
COMBINED_MD="_combined.md"

CHAPTERS=(
  "Глава-01-Тождественные-преобразования"
  "Глава-02-Алгебраические-уравнения"
  "Глава-03-Текстовые-задачи"
  "Глава-04-Тригонометрические-преобразования"
  "Глава-05-Тригонометрические-уравнения"
  "Глава-06-Прогрессии"
  "Глава-07-Логарифмы-и-показательные-уравнения"
  "Глава-08-Неравенства"
  "Глава-09-Комбинаторика-и-бином-Ньютона"
  "Глава-10-Дополнительные-задачи-по-алгебре"
  "Глава-11-Начала-математического-анализа"
)

echo "Собираю Markdown..."

# YAML header
cat > "$COMBINED_MD" << 'YAML_END'
---
title: "Сборник задач по математике"
subtitle: "под редакцией М.И. Сканави · Улучшенное издание"
author: "На основе оригинального издания"
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
    \fancyhead[L]{\small\itshape Сканави · Сборник задач}
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
  # README first, then 00-*, 01-*, ... sorted naturally
  for md_file in $(ls "$chapter/"*.md 2>/dev/null | sort); do
    basename_file=$(basename "$md_file")
    # README first pass — skip here, handled separately
    [[ "$basename_file" == "README.md" ]] && continue
  done

  # Process README first if exists
  if [[ -f "$chapter/README.md" ]]; then
    cat "$chapter/README.md" >> "$COMBINED_MD"
    echo "" >> "$COMBINED_MD"
    ((file_count++))
    first=false
  fi

  # Then all other .md files sorted
  for md_file in $(ls "$chapter/"*.md 2>/dev/null | sort); do
    basename_file=$(basename "$md_file")
    [[ "$basename_file" == "README.md" ]] && continue
    if [[ "$first" = true ]]; then
      first=false
    else
      echo -e "\n\\\\newpage\n" >> "$COMBINED_MD"
    fi
    cat "$md_file" >> "$COMBINED_MD"
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
