#!/usr/bin/env python3
"""Минимальная очистка markdown"""
import re
import sys

md_file = sys.argv[1]

with open(md_file, "r") as f:
    content = f.read()

# Убираем дублирующиеся заголовки
content = re.sub(r'^(# .+?)\. # .+$', r'\1', content, flags=re.MULTILINE)

with open(md_file, "w") as f:
    f.write(content)

print("  ✓ Markdown очищен")
