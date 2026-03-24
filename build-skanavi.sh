#!/bin/bash
# Сборка отдельной книги Сканави (главы 23-33)
set -e
cd "$(dirname "$0")"

BOOK="Книга-Сканави-9-11.md"
HTML="Книга-Сканави-9-11.html"
PDF="Книга-Сканави-9-11.pdf"

echo "📖 Сборка книги Сканави..."

echo "" > "$BOOK"

cat >> "$BOOK" << 'INTRO'
# Сборник задач по математике для поступающих во ВТУЗы

> Под редакцией М.И. Сканави · Улучшенное издание · ~3 550 задач · Классы 9–11

---

INTRO

for ch in $(seq -w 23 33); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    if [ -z "$dir" ]; then continue; fi

    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^#\+ //')
    [ -z "$name" ] && name=$(basename "$dir" | sed 's/^Глава-[0-9]*-//' | tr '-' ' ')

    echo "    Глава $((10#$ch - 22)): $name"
    echo "" >> "$BOOK"
    echo "# Глава $((10#$ch - 22)). $name" >> "$BOOK"
    echo "" >> "$BOOK"

    # Теория
    if [ -f "$dir/00-Теория.md" ]; then
        echo "## Теория" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/00-Теория.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi

    # Примеры
    if [ -f "$dir/01-Примеры.md" ]; then
        echo "## Примеры с решениями" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/01-Примеры.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi

    # Задачи (все файлы кроме теории, примеров, ответов, README)
    for taskfile in "$dir"/0[2-9]-*.md "$dir"/1[0-9]-*.md; do
        [ -f "$taskfile" ] || continue
        bname=$(basename "$taskfile")
        case "$bname" in *Ответы*|*Методические*|README*) continue ;; esac

        sectname=$(head -1 "$taskfile" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$sectname" ] && sectname="$bname"
        echo "## $sectname" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$taskfile" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"
        echo "" >> "$BOOK"
    done
done

# Ответы
echo "" >> "$BOOK"
echo "# Ответы" >> "$BOOK"
echo "" >> "$BOOK"

for ch in $(seq -w 23 33); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    if [ -z "$dir" ]; then continue; fi
    ansfile=$(find "$dir" -maxdepth 1 -name "*Ответы*" 2>/dev/null | head -1)
    if [ -n "$ansfile" ] && [ -f "$ansfile" ]; then
        name=$(head -1 "$ansfile" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$name" ] && name="Глава $((10#$ch - 22)) — Ответы"
        echo "## $name" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$ansfile" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
done

lines=$(wc -l < "$BOOK")
echo ""
echo "✅ Markdown: $BOOK ($lines строк)"

# CSS стили для книги Сканави
cat > /tmp/skanavi-style.css << 'CSS'
@page {
    size: A4;
    margin: 2cm 2cm 2.5cm 2.5cm;
    @top-center {
        content: "Сканави — Сборник задач по математике";
        font-size: 8pt;
        color: #888;
    }
    @bottom-center {
        content: counter(page);
        font-size: 10pt;
    }
}
@page :first {
    @top-center { content: none; }
    @bottom-center { content: none; }
}
body {
    font-family: "Times New Roman", "Noto Serif", Georgia, serif;
    font-size: 11pt;
    line-height: 1.45;
    color: #1a1a1a;
}
h1 {
    font-size: 20pt;
    page-break-before: always;
    margin-top: 2.5cm;
    margin-bottom: 1cm;
    color: #0d47a1;
    border-bottom: 2pt solid #0d47a1;
    padding-bottom: 0.4cm;
}
h1:first-of-type { page-break-before: avoid; }
h2 {
    font-size: 14pt;
    margin-top: 1.2cm;
    margin-bottom: 0.6cm;
    color: #1565c0;
}
h3 {
    font-size: 12pt;
    margin-top: 0.8cm;
    color: #1976d2;
}
h4 { font-size: 11pt; color: #444; }
p {
    margin: 0.25em 0;
    text-align: justify;
    orphans: 3;
    widows: 3;
}
p > strong:first-child { color: #0d47a1; }
table {
    border-collapse: collapse;
    width: 100%;
    margin: 0.6em 0;
    font-size: 10pt;
}
th, td {
    border: 1px solid #ccc;
    padding: 3pt 6pt;
}
th { background: #e3f2fd; }
tr:nth-child(even) { background: #fafafa; }
blockquote {
    border-left: 3pt solid #1565c0;
    margin: 0.6em 0;
    padding: 0.4em 1em;
    background: #e3f2fd;
    font-style: italic;
}
code {
    font-family: "Menlo", monospace;
    font-size: 9pt;
    background: #f5f5f5;
    padding: 1pt 3pt;
}
pre {
    background: #f5f5f5;
    padding: 6pt;
    font-size: 9pt;
    white-space: pre-wrap;
}
nav#TOC { page-break-after: always; }
nav#TOC a { color: #0d47a1; text-decoration: none; }
CSS

echo "  Markdown → HTML..."
pandoc "$BOOK" \
    -o "$HTML" \
    --standalone \
    --mathml \
    --toc \
    --toc-depth=2 \
    --number-sections \
    --top-level-division=chapter \
    --css=/tmp/skanavi-style.css \
    --embed-resources \
    --metadata title="Сборник задач по математике (Сканави)" \
    2>&1 | grep -v "^$" | tail -3

echo "  HTML → PDF (weasyprint)..."
weasyprint "$HTML" "$PDF" \
    --stylesheet /tmp/skanavi-style.css \
    2>&1 | grep -v "^WARNING" | tail -3

echo ""
if [ -f "$PDF" ]; then
    size=$(du -h "$PDF" | cut -f1)
    echo "✅ PDF: $PDF ($size)"
    open "$PDF"
else
    echo "❌ Ошибка"
fi
