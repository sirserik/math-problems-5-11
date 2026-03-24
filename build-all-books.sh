#!/bin/bash
# Универсальный сборщик книг через pandoc → .tex → xelatex → PDF
set -e
cd "$(dirname "$0")"
export PATH="/Library/TeX/texbin:$PATH"

# LaTeX-преамбула
cat > /tmp/math-preamble.tex << 'TEX'
\usepackage{polyglossia}
\setdefaultlanguage{russian}
\setotherlanguage{english}
\setmainfont[Script=Cyrillic,Ligatures=TeX]{Times New Roman}
\setsansfont[Script=Cyrillic]{Helvetica Neue}
\setmonofont{Menlo}
\newfontfamily\cyrillicfont[Script=Cyrillic]{Times New Roman}
\newfontfamily\cyrillicfontsf[Script=Cyrillic]{Helvetica Neue}
\newfontfamily\cyrillicfonttt{Menlo}

\usepackage{amsmath,amssymb,amsthm}
\usepackage{unicode-math}
\setmathfont{STIX Two Math}

\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhead[LE,RO]{\thepage}
\fancyhead[RE]{\small\itshape\leftmark}
\fancyhead[LO]{\small\itshape\rightmark}
\fancyfoot{}
\renewcommand{\headrulewidth}{0.4pt}

\renewcommand{\partname}{Часть}
\renewcommand{\chaptername}{Глава}
\renewcommand{\contentsname}{Оглавление}

\tolerance=2000
\emergencystretch=20pt
\setlength{\parskip}{0.3em}

\usepackage{etoolbox}
TEX

build_book() {
    local MD_FILE="$1"
    local PDF_FILE="$2"
    local TITLE="$3"
    local SUBTITLE="$4"

    echo "📖 Сборка: $TITLE"

    local TEX_FILE="${PDF_FILE%.pdf}.tex"

    # Шаг 1: Очистка markdown
    python3 fix-md.py "$MD_FILE"

    echo "  Шаг 1: Markdown → LaTeX..."
    pandoc "$MD_FILE" \
        -o "$TEX_FILE" \
        --top-level-division=chapter \
        --number-sections \
        --toc \
        --toc-depth=2 \
        -V documentclass=book \
        -V classoption=a4paper \
        -V fontsize=11pt \
        -V geometry="top=2cm, bottom=2.5cm, left=2.5cm, right=2cm" \
        -V title="$TITLE" \
        -V subtitle="$SUBTITLE" \
        -V date="2026" \
        -V lang=ru \
        -H /tmp/math-preamble.tex \
        2>&1 | grep -i "error" | head -5 || true

    # Шаг 2: Фикс LaTeX
    python3 fix-tex.py "$TEX_FILE"

    echo "  Шаг 2: LaTeX → PDF (xelatex, 2 прохода)..."

    # Первый проход
    xelatex -interaction=nonstopmode -output-directory="." "$TEX_FILE" > /tmp/xelatex-pass1.log 2>&1 || true

    # Второй проход (TOC)
    xelatex -interaction=nonstopmode -output-directory="." "$TEX_FILE" > /tmp/xelatex-pass2.log 2>&1 || true

    if [ -f "$PDF_FILE" ]; then
        local size=$(du -h "$PDF_FILE" | cut -f1)
        local pages=$(python3 -c "from PyPDF2 import PdfReader; print(len(PdfReader('$PDF_FILE').pages))" 2>/dev/null || echo "?")
        echo "  ✅ $PDF_FILE ($size, $pages стр.)"

        local errors=$(grep -c "^!" /tmp/xelatex-pass2.log 2>/dev/null || echo "0")
        [ "$errors" -gt 0 ] && echo "  ⚠️  $errors LaTeX-предупреждений"
    else
        echo "  ❌ Ошибка создания PDF"
        tail -20 /tmp/xelatex-pass2.log
    fi

    # Очистка
    rm -f "${PDF_FILE%.pdf}.aux" "${PDF_FILE%.pdf}.log" "${PDF_FILE%.pdf}.out" "${PDF_FILE%.pdf}.toc" 2>/dev/null
    rm -f "$TEX_FILE" 2>/dev/null
}

echo "═══════════════════════════════════════"
echo "  Сборка всех книг (pandoc + xelatex)"
echo "═══════════════════════════════════════"
echo ""

# Собираем markdown из исходников, если нужно
for script in build-5-6.sh build-7-8.sh build-skanavi.sh build-book.sh; do
    [ -f "$script" ] || continue
done

# Сначала регенерируем markdown-файлы (только сборку md, без PDF)
echo "Регенерация markdown-файлов..."

# Проверяем что md-файлы существуют
for f in Книга-Математика-5-6.md Книга-Математика-7-8.md Книга-Сканави-9-11.md Книга-Математика-5-11.md; do
    [ -f "$f" ] && echo "  ✓ $f ($(wc -l < "$f") строк)"
done
echo ""

build_book "Книга-Математика-5-6.md" "Книга-Математика-5-6.pdf" \
    "Полный сборник задач по математике" "5–6 класс · ~2 040 задач"
echo ""

build_book "Книга-Математика-7-8.md" "Книга-Математика-7-8.pdf" \
    "Полный сборник задач по математике" "7–8 класс · Алгебра + Геометрия"
echo ""

build_book "Книга-Сканави-9-11.md" "Книга-Сканави-9-11.pdf" \
    "Сборник задач по математике" "Под ред. М.И. Сканави · 9–11 класс"
echo ""

build_book "Книга-Математика-5-11.md" "Книга-Математика-5-11.pdf" \
    "Полный сборник задач по математике" "5–11 класс · ~6 800 задач · 33 главы"

echo ""
echo "═══════════════════════════════════════"
echo "  Все книги:"
echo "═══════════════════════════════════════"
ls -lh Книга-*.pdf 2>/dev/null
