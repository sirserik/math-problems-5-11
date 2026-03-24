#!/bin/bash
# Скрипт сборки книги "Полный сборник задач по математике 5-11 классов"
# Генерирует единый Markdown, затем конвертирует в PDF через pandoc + xelatex

set -e
cd "$(dirname "$0")"

BOOK="Книга-Математика-5-11.md"
PDF="Книга-Математика-5-11.pdf"

echo "📖 Сборка книги..."

# --- Начинаем чистый markdown (без YAML frontmatter) ---
echo "" > "$BOOK"

echo "  Часть I: Математика 5-6 класс..."
echo "" >> "$BOOK"
echo "# Часть I. Математика 5–6 класс" >> "$BOOK"
echo "" >> "$BOOK"

# Стандартные главы (1-22) — файлы 00-Теория, 01-Примеры, 02-А, 03-Б, 04-В
for ch in $(seq -w 1 12); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    if [ -z "$dir" ]; then continue; fi

    # Извлекаем название из README
    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^#\+ //')
    [ -z "$name" ] && name=$(basename "$dir" | sed 's/^Глава-[0-9]*-//' | tr '-' ' ')

    echo "    Глава $ch: $name"
    echo "" >> "$BOOK"
    echo "## Глава $((10#$ch)). $name" >> "$BOOK"
    echo "" >> "$BOOK"

    # Добавляем теорию
    if [ -f "$dir/00-Теория.md" ]; then
        echo "### Теория" >> "$BOOK"
        echo "" >> "$BOOK"
        # Убираем заголовок первого уровня из файла
        tail -n +2 "$dir/00-Теория.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi

    # Добавляем примеры
    if [ -f "$dir/01-Примеры.md" ]; then
        echo "### Примеры с решениями" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/01-Примеры.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi

    # Добавляем задачи всех уровней
    for taskfile in "$dir"/0[2-9]-*.md "$dir"/1[0-9]-*.md; do
        [ -f "$taskfile" ] || continue
        bname=$(basename "$taskfile")
        # Пропускаем ответы и README
        case "$bname" in *Ответы*|README*) continue ;; esac

        sectname=$(head -1 "$taskfile" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$sectname" ] && sectname="$bname"
        echo "### $sectname" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$taskfile" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    done
done

echo "  Часть II: Алгебра 7-8 класс..."
echo "" >> "$BOOK"
echo "# Часть II. Алгебра 7–8 класс" >> "$BOOK"
echo "" >> "$BOOK"

for ch in $(seq -w 13 19); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    if [ -z "$dir" ]; then continue; fi
    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^#\+ //')
    [ -z "$name" ] && name=$(basename "$dir" | sed 's/^Глава-[0-9]*-//' | tr '-' ' ')
    echo "    Глава $ch: $name"
    echo "" >> "$BOOK"
    echo "## Глава $((10#$ch)). $name" >> "$BOOK"
    echo "" >> "$BOOK"

    if [ -f "$dir/00-Теория.md" ]; then
        echo "### Теория" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/00-Теория.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
    if [ -f "$dir/01-Примеры.md" ]; then
        echo "### Примеры с решениями" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/01-Примеры.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
    for taskfile in "$dir"/0[2-9]-*.md "$dir"/1[0-9]-*.md; do
        [ -f "$taskfile" ] || continue
        bname=$(basename "$taskfile")
        case "$bname" in *Ответы*|README*) continue ;; esac
        sectname=$(head -1 "$taskfile" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$sectname" ] && sectname="$bname"
        echo "### $sectname" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$taskfile" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    done
done

echo "  Часть III: Геометрия 7-8 класс..."
echo "" >> "$BOOK"
echo "# Часть III. Геометрия 7–8 класс" >> "$BOOK"
echo "" >> "$BOOK"

for ch in $(seq -w 20 22); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    if [ -z "$dir" ]; then continue; fi
    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^#\+ //')
    [ -z "$name" ] && name=$(basename "$dir" | sed 's/^Глава-[0-9]*-//' | tr '-' ' ')
    echo "    Глава $ch: $name"
    echo "" >> "$BOOK"
    echo "## Глава $((10#$ch)). $name" >> "$BOOK"
    echo "" >> "$BOOK"

    if [ -f "$dir/00-Теория.md" ]; then
        echo "### Теория" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/00-Теория.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
    if [ -f "$dir/01-Примеры.md" ]; then
        echo "### Примеры с решениями" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/01-Примеры.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
    for taskfile in "$dir"/0[2-9]-*.md "$dir"/1[0-9]-*.md; do
        [ -f "$taskfile" ] || continue
        bname=$(basename "$taskfile")
        case "$bname" in *Ответы*|README*) continue ;; esac
        sectname=$(head -1 "$taskfile" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$sectname" ] && sectname="$bname"
        echo "### $sectname" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$taskfile" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    done
done

echo "  Часть IV: Алгебра 9-11 класс (Сканави)..."
echo "" >> "$BOOK"
echo "# Часть IV. Алгебра 9–11 класс (Сканави)" >> "$BOOK"
echo "" >> "$BOOK"

for ch in $(seq -w 23 33); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    if [ -z "$dir" ]; then continue; fi
    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^#\+ //')
    [ -z "$name" ] && name=$(basename "$dir" | sed 's/^Глава-[0-9]*-//' | tr '-' ' ')
    echo "    Глава $ch: $name"
    echo "" >> "$BOOK"
    echo "## Глава $((10#$ch)). $name" >> "$BOOK"
    echo "" >> "$BOOK"

    if [ -f "$dir/00-Теория.md" ]; then
        echo "### Теория" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/00-Теория.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
    if [ -f "$dir/01-Примеры.md" ]; then
        echo "### Примеры с решениями" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$dir/01-Примеры.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
    for taskfile in "$dir"/0[2-9]-*.md "$dir"/1[0-9]-*.md; do
        [ -f "$taskfile" ] || continue
        bname=$(basename "$taskfile")
        case "$bname" in *Ответы*|*Методические*|README*) continue ;; esac
        sectname=$(head -1 "$taskfile" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$sectname" ] && sectname="$bname"
        echo "### $sectname" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$taskfile" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    done
done

echo "  Часть V: Олимпиадные задачи..."
echo "" >> "$BOOK"
echo "# Часть V. Международные олимпиадные задачи" >> "$BOOK"
echo "" >> "$BOOK"

# AMC 8
echo "## AMC 8 (5–6 класс)" >> "$BOOK"
echo "" >> "$BOOK"
if [ -f "Олимпиады-5-6/AMC-8.md" ]; then
    tail -n +2 "Олимпиады-5-6/AMC-8.md" | sed 's/^# /### /; s/^## /#### /; s/^### /##### /' >> "$BOOK"
    echo "" >> "$BOOK"
fi

# AMC 8 Solutions
for year in 2019 2020 2022 2023 2024; do
    solfile="Олимпиады-5-6/AMC-8-Решения-${year}.md"
    if [ -f "$solfile" ]; then
        echo "### Решения AMC 8 $year" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$solfile" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
done

# AMC 10
echo "## AMC 10 (7–8 класс)" >> "$BOOK"
echo "" >> "$BOOK"
if [ -f "Олимпиады-7-8/AMC-10.md" ]; then
    tail -n +2 "Олимпиады-7-8/AMC-10.md" | sed 's/^# /### /; s/^## /#### /; s/^### /##### /' >> "$BOOK"
    echo "" >> "$BOOK"
fi

for solfile in Олимпиады-7-8/AMC-10*-Решения-*.md; do
    [ -f "$solfile" ] || continue
    solname=$(head -1 "$solfile" | sed 's/^#\+ //')
    echo "### $solname" >> "$BOOK"
    echo "" >> "$BOOK"
    tail -n +2 "$solfile" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
    echo "" >> "$BOOK"
done

# IMO
echo "## IMO (9–11 класс)" >> "$BOOK"
echo "" >> "$BOOK"
if [ -f "Олимпиады-9-11/IMO.md" ]; then
    tail -n +2 "Олимпиады-9-11/IMO.md" | sed 's/^# /### /; s/^## /#### /; s/^### /##### /' >> "$BOOK"
    echo "" >> "$BOOK"
fi
if [ -f "Олимпиады-9-11/IMO-Решения.md" ]; then
    echo "### Решения IMO 2020–2024" >> "$BOOK"
    echo "" >> "$BOOK"
    tail -n +2 "Олимпиады-9-11/IMO-Решения.md" | sed 's/^# /#### /; s/^## /##### /; s/^### /##### /' >> "$BOOK"
    echo "" >> "$BOOK"
fi

# Приложение: Ответы
echo "  Приложение: Ответы..."
echo "" >> "$BOOK"
echo "# Приложение. Ответы ко всем задачам" >> "$BOOK"
echo "" >> "$BOOK"

for ch in $(seq -w 1 33); do
    dir=$(ls -d Глава-${ch}-* 2>/dev/null | head -1)
    if [ -z "$dir" ]; then continue; fi

    # Найти файл ответов (может быть 05-Ответы, 06-Ответы, 08-Ответы, 18-Ответы)
    ansfile=$(find "$dir" -maxdepth 1 -name "*Ответы*" 2>/dev/null | head -1)
    if [ -n "$ansfile" ] && [ -f "$ansfile" ]; then
        name=$(head -1 "$ansfile" 2>/dev/null | sed 's/^#\+ //')
        [ -z "$name" ] && name="Глава $((10#$ch)) — Ответы"
        echo "## $name" >> "$BOOK"
        echo "" >> "$BOOK"
        tail -n +2 "$ansfile" | sed 's/^# /### /; s/^## /#### /; s/^### /##### /' >> "$BOOK"
        echo "" >> "$BOOK"
    fi
done

lines=$(wc -l < "$BOOK")
echo ""
echo "✅ Markdown книга собрана: $BOOK ($lines строк)"
echo ""

# --- Конвертация в PDF ---
echo "📄 Конвертация в PDF через pandoc + xelatex..."

export PATH="/Library/TeX/texbin:$PATH"

# Создаём LaTeX-преамбулу
cat > /tmp/math-book-header.tex << 'TEX'
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhead[LE,RO]{\thepage}
\fancyhead[RE]{\leftmark}
\fancyhead[LO]{\rightmark}
\fancyfoot{}
\renewcommand{\partname}{Часть}
\renewcommand{\chaptername}{Глава}
\renewcommand{\contentsname}{Оглавление}
TEX

# Создаём CSS-стили для книги
cat > /tmp/math-book-style.css << 'CSS'
@page {
    size: A4;
    margin: 2cm 2cm 2.5cm 2.5cm;
    @top-center {
        content: string(chapter-title);
        font-size: 9pt;
        color: #666;
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
    line-height: 1.5;
    color: #1a1a1a;
    max-width: none;
}
h1 {
    font-size: 22pt;
    page-break-before: always;
    margin-top: 3cm;
    margin-bottom: 1.5cm;
    color: #1a237e;
    border-bottom: 2pt solid #1a237e;
    padding-bottom: 0.5cm;
    string-set: chapter-title content();
}
h1:first-of-type {
    page-break-before: avoid;
}
h2 {
    font-size: 16pt;
    margin-top: 1.5cm;
    margin-bottom: 0.8cm;
    color: #283593;
    page-break-before: always;
}
h3 {
    font-size: 13pt;
    margin-top: 1cm;
    margin-bottom: 0.5cm;
    color: #3949ab;
}
h4, h5 {
    font-size: 11pt;
    margin-top: 0.8cm;
    margin-bottom: 0.4cm;
    color: #444;
}
p {
    margin: 0.3em 0;
    text-align: justify;
    orphans: 3;
    widows: 3;
}
strong {
    color: #1a1a1a;
}
/* Нумерация задач */
p > strong:first-child {
    color: #1a237e;
}
table {
    border-collapse: collapse;
    width: 100%;
    margin: 0.8em 0;
    font-size: 10pt;
}
th, td {
    border: 1px solid #ccc;
    padding: 4pt 8pt;
    text-align: left;
}
th {
    background: #e8eaf6;
    font-weight: bold;
}
tr:nth-child(even) {
    background: #fafafa;
}
blockquote {
    border-left: 3pt solid #3949ab;
    margin: 0.8em 0;
    padding: 0.5em 1em;
    background: #e8eaf6;
    font-style: italic;
}
code {
    font-family: "Menlo", "Courier New", monospace;
    font-size: 9pt;
    background: #f5f5f5;
    padding: 1pt 3pt;
    border-radius: 2pt;
}
pre {
    background: #f5f5f5;
    padding: 8pt;
    border-radius: 4pt;
    font-size: 9pt;
    overflow-x: visible;
    white-space: pre-wrap;
}
hr {
    border: none;
    border-top: 1pt solid #ccc;
    margin: 1cm 0;
}
/* MathML styling */
math {
    font-size: 1em;
}
/* Списки */
ul, ol {
    margin: 0.3em 0;
    padding-left: 2em;
}
li {
    margin: 0.15em 0;
}
/* Титульная страница */
.title-page {
    text-align: center;
    page-break-after: always;
    padding-top: 5cm;
}
.title-page h1 {
    font-size: 28pt;
    border: none;
    page-break-before: avoid;
    color: #1a237e;
}
.title-page .subtitle {
    font-size: 18pt;
    color: #555;
    margin-top: 1cm;
}
.title-page .stats {
    font-size: 14pt;
    color: #777;
    margin-top: 2cm;
}
.title-page .year {
    font-size: 16pt;
    color: #999;
    margin-top: 3cm;
}
/* Навигация по содержанию */
nav#TOC {
    page-break-after: always;
}
nav#TOC a {
    color: #1a237e;
    text-decoration: none;
}
CSS

HTML="Книга-Математика-5-11.html"

echo "  Шаг 1: Markdown → HTML (pandoc + MathML)..."

pandoc "$BOOK" \
    -o "$HTML" \
    --standalone \
    --mathml \
    --toc \
    --toc-depth=2 \
    --number-sections \
    --top-level-division=chapter \
    --css=/tmp/math-book-style.css \
    --embed-resources \
    --metadata title="Полный сборник задач по математике для 5–11 классов" \
    2>&1 | tail -3

echo "  Шаг 2: HTML → PDF (weasyprint)..."

weasyprint "$HTML" "$PDF" \
    --stylesheet /tmp/math-book-style.css \
    2>&1 | grep -v "^WARNING" | tail -3

echo ""
if [ -f "$PDF" ]; then
    size=$(du -h "$PDF" | cut -f1)
    pages=$(strings "$PDF" | grep -c '/Type /Page' || echo "?")
    echo "✅ PDF создан: $PDF ($size, ~$pages стр.)"
else
    echo "❌ Ошибка создания PDF"
fi
