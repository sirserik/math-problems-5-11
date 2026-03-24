#!/bin/bash
# Сборка книги для 7-8 классов (главы 13-22 + AMC 10 + IMO)
set -e
cd "$(dirname "$0")"

BOOK="Книга-Математика-7-8.md"
HTML="Книга-Математика-7-8.html"
PDF="Книга-Математика-7-8.pdf"

echo "📖 Сборка книги 7-8 класс..."
echo "" > "$BOOK"

cat >> "$BOOK" << 'INTRO'
# Полный сборник задач по математике · 7–8 класс

> Алгебра + Геометрия · ~1 255 задач · 10 глав · Олимпиады AMC 10 и IMO

---

## Часть I. Алгебра

INTRO

for ch in $(seq -w 13 19); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    [ -z "$dir" ] && continue
    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^#\+ //')
    [ -z "$name" ] && name=$(basename "$dir" | sed 's/^Глава-[0-9]*-//' | tr '-' ' ')
    echo "    Глава $ch: $name"
    echo "" >> "$BOOK"
    echo "# Глава $((10#$ch - 12)). $name" >> "$BOOK"
    echo "" >> "$BOOK"

    [ -f "$dir/00-Теория.md" ] && { echo "## Теория" >> "$BOOK"; echo "" >> "$BOOK"; tail -n +2 "$dir/00-Теория.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }
    [ -f "$dir/01-Примеры.md" ] && { echo "## Примеры с решениями" >> "$BOOK"; echo "" >> "$BOOK"; tail -n +2 "$dir/01-Примеры.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }

    for tf in "$dir"/0[2-9]-*.md "$dir"/1[0-9]-*.md; do
        [ -f "$tf" ] || continue
        case "$(basename "$tf")" in *Ответы*|README*) continue ;; esac
        sn=$(head -1 "$tf" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$sn" ] && sn=$(basename "$tf")
        echo "## $sn" >> "$BOOK"; echo "" >> "$BOOK"
        tail -n +2 "$tf" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"
    done
done

echo "" >> "$BOOK"
echo "# Часть II. Геометрия" >> "$BOOK"
echo "" >> "$BOOK"

for ch in $(seq -w 20 22); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    [ -z "$dir" ] && continue
    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^#\+ //')
    [ -z "$name" ] && name=$(basename "$dir" | sed 's/^Глава-[0-9]*-//' | tr '-' ' ')
    echo "    Глава $ch: $name"
    echo "" >> "$BOOK"
    echo "# Глава $((10#$ch - 12)). $name" >> "$BOOK"
    echo "" >> "$BOOK"

    [ -f "$dir/00-Теория.md" ] && { echo "## Теория" >> "$BOOK"; echo "" >> "$BOOK"; tail -n +2 "$dir/00-Теория.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }
    [ -f "$dir/01-Примеры.md" ] && { echo "## Примеры с решениями" >> "$BOOK"; echo "" >> "$BOOK"; tail -n +2 "$dir/01-Примеры.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }

    for tf in "$dir"/0[2-9]-*.md "$dir"/1[0-9]-*.md; do
        [ -f "$tf" ] || continue
        case "$(basename "$tf")" in *Ответы*|README*) continue ;; esac
        sn=$(head -1 "$tf" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$sn" ] && sn=$(basename "$tf")
        echo "## $sn" >> "$BOOK"; echo "" >> "$BOOK"
        tail -n +2 "$tf" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"
    done
done

# Олимпиады
echo "    Олимпиады AMC 10 + IMO..."
echo "" >> "$BOOK"
echo "# Олимпиадные задачи" >> "$BOOK"
echo "" >> "$BOOK"

echo "## AMC 10 (7–8 класс)" >> "$BOOK"; echo "" >> "$BOOK"
[ -f "Олимпиады-7-8/AMC-10.md" ] && { tail -n +2 "Олимпиады-7-8/AMC-10.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }
for sf in Олимпиады-7-8/AMC-10*-Решения-*.md; do
    [ -f "$sf" ] || continue
    sn=$(head -1 "$sf" | sed 's/^#\+ //')
    echo "## $sn" >> "$BOOK"; echo "" >> "$BOOK"
    tail -n +2 "$sf" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"
done

echo "## IMO (9–11 класс)" >> "$BOOK"; echo "" >> "$BOOK"
[ -f "Олимпиады-9-11/IMO.md" ] && { tail -n +2 "Олимпиады-9-11/IMO.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }
[ -f "Олимпиады-9-11/IMO-Решения.md" ] && { echo "## Решения IMO" >> "$BOOK"; echo "" >> "$BOOK"; tail -n +2 "Олимпиады-9-11/IMO-Решения.md" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }

# Ответы
echo "" >> "$BOOK"; echo "# Ответы" >> "$BOOK"; echo "" >> "$BOOK"
for ch in $(seq -w 13 22); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    [ -z "$dir" ] && continue
    af=$(find "$dir" -maxdepth 1 -name "*Ответы*" 2>/dev/null | head -1)
    [ -n "$af" ] && [ -f "$af" ] && { nm=$(head -1 "$af" | sed 's/^#\+ //'); [ -z "$nm" ] && nm="Глава $((10#$ch - 12))"; echo "## $nm" >> "$BOOK"; echo "" >> "$BOOK"; tail -n +2 "$af" | sed 's/^# /### /; s/^## /#### /; s/^### /#### /' >> "$BOOK"; echo "" >> "$BOOK"; }
done

lines=$(wc -l < "$BOOK")
echo "✅ Markdown: $BOOK ($lines строк)"

cat > /tmp/book78-style.css << 'CSS'
@page { size: A4; margin: 2cm 2cm 2.5cm 2.5cm;
    @top-center { content: "Математика 7–8 класс"; font-size: 8pt; color: #888; }
    @bottom-center { content: counter(page); font-size: 10pt; }
}
@page :first { @top-center { content: none; } @bottom-center { content: none; } }
body { font-family: "Times New Roman", Georgia, serif; font-size: 11pt; line-height: 1.5; color: #1a1a1a; }
h1 { font-size: 20pt; page-break-before: always; margin-top: 2.5cm; margin-bottom: 1cm; color: #e65100; border-bottom: 2pt solid #e65100; padding-bottom: 0.4cm; }
h1:first-of-type { page-break-before: avoid; }
h2 { font-size: 14pt; margin-top: 1.2cm; color: #ef6c00; }
h3 { font-size: 12pt; margin-top: 0.8cm; color: #f57c00; }
h4 { font-size: 11pt; color: #444; }
p { margin: 0.25em 0; text-align: justify; orphans: 3; widows: 3; }
p > strong:first-child { color: #e65100; }
table { border-collapse: collapse; width: 100%; margin: 0.6em 0; font-size: 10pt; }
th, td { border: 1px solid #ccc; padding: 3pt 6pt; }
th { background: #fff3e0; }
tr:nth-child(even) { background: #fafafa; }
blockquote { border-left: 3pt solid #ef6c00; margin: 0.6em 0; padding: 0.4em 1em; background: #fff3e0; font-style: italic; }
code { font-family: "Menlo", monospace; font-size: 9pt; background: #f5f5f5; padding: 1pt 3pt; }
pre { background: #f5f5f5; padding: 6pt; font-size: 9pt; white-space: pre-wrap; }
nav#TOC { page-break-after: always; }
nav#TOC a { color: #e65100; text-decoration: none; }
CSS

echo "  Markdown → HTML..."
pandoc "$BOOK" -o "$HTML" --standalone --mathml --toc --toc-depth=2 --number-sections --top-level-division=chapter --css=/tmp/book78-style.css --embed-resources --metadata title="Математика 7-8 класс" 2>&1 | tail -3

echo "  HTML → PDF..."
weasyprint "$HTML" "$PDF" --stylesheet /tmp/book78-style.css 2>&1 | grep -v "^WARNING" | tail -3

if [ -f "$PDF" ]; then
    size=$(du -h "$PDF" | cut -f1)
    echo "✅ PDF: $PDF ($size)"
    open "$PDF"
else
    echo "❌ Ошибка"
fi
