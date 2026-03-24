#!/usr/bin/env python3
"""Минимальный фикс LaTeX после pandoc"""
import re
import sys

tex_file = sys.argv[1]

with open(tex_file, "r") as f:
    tex = f.read()

# Удаляем babel (конфликтует с polyglossia)
tex = re.sub(r'\\usepackage\[.*?\]\{babel\}', '% babel removed (using polyglossia)', tex)

# Добавляем \tightlist
if r'\tightlist' in tex and r'\providecommand{\tightlist}' not in tex:
    tex = tex.replace(
        r'\begin{document}',
        r'\providecommand{\tightlist}{\setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}' + '\n' + r'\begin{document}')

with open(tex_file, "w") as f:
    f.write(tex)

print("  ✓ LaTeX исправлен")
