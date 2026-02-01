# BOSS_Syllabus

A system for publishing course syllabi and educational materials from Markdown files into multiple formats (PDF, HTML, EPUB).

## Overview

This project allows you to write your syllabus or course materials in simple Markdown format and automatically convert it into professionally formatted books in various formats.

## Features

- ✨ Write content in easy-to-edit Markdown
- 📄 Generate PDF documents
- 🌐 Create HTML websites
- 📱 Build EPUB ebooks
- 🎨 Customizable styling and metadata
- 🚀 Simple build process using Make

## Requirements

To publish books from markdown, you need:

- **pandoc** - Universal document converter
- **LaTeX** (for PDF generation) - XeLaTeX or pdflatex
  - On Ubuntu/Debian: `sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended texlive-latex-recommended`
  - On macOS: `brew install pandoc basictex`
  - On Windows: Install [Pandoc](https://pandoc.org/installing.html) and [MiKTeX](https://miktex.org/)

## Quick Start

### 1. Install Dependencies

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended texlive-latex-recommended

# macOS (using Homebrew)
brew install pandoc
brew install --cask basictex

# Windows
# Download and install Pandoc and MiKTeX from their official websites
```

### 2. Edit Your Content

Edit the `syllabus.md` file with your course content using Markdown syntax.

### 3. Customize Metadata

Edit `metadata.yml` to set your book's title, author, and other metadata:

```yaml
---
title: "Your Book Title"
subtitle: "Your Subtitle"
author: "Your Name"
date: "2026"
---
```

### 4. Generate Your Book

```bash
# Generate PDF and HTML (default)
make

# Generate only PDF
make pdf

# Generate only HTML
make html

# Generate only EPUB
make epub

# Generate all formats
make book

# Clean output files
make clean

# Show help
make help
```

### 5. View Your Book

Generated files will be in the `output/` directory:
- `output/syllabus.pdf` - PDF version
- `output/syllabus.html` - HTML version
- `output/syllabus.epub` - EPUB version

## File Structure

```
BOSS_Syllabus/
├── syllabus.md          # Your main content in Markdown
├── metadata.yml         # Book metadata (title, author, etc.)
├── style.css            # CSS styling for HTML output
├── Makefile             # Build automation
├── README.md            # This file
└── output/              # Generated books (created automatically)
    ├── syllabus.pdf
    ├── syllabus.html
    └── syllabus.epub
```

## Markdown Syntax

Syllabus content uses standard Markdown syntax:

```markdown
# Main Heading
## Subheading
### Sub-subheading

**bold text**
*italic text*

- Bullet point
- Another point

1. Numbered item
2. Another item

[Link text](https://example.com)

| Column 1 | Column 2 |
|----------|----------|
| Data 1   | Data 2   |
```

## Customization

### Styling HTML Output

Edit `style.css` to customize the appearance of HTML output.

### PDF Layout

Modify `metadata.yml` to change PDF formatting:

```yaml
geometry: margin=1.5in
fontsize: 11pt
documentclass: article
```

## Troubleshooting

### PDF Generation Fails

- Ensure LaTeX is installed: `xelatex --version` or `pdflatex --version`
- Install missing LaTeX packages if prompted
- Try using HTML output if PDF fails: `make html`

### Pandoc Not Found

- Verify installation: `pandoc --version`
- Add pandoc to your PATH if necessary

## Contributing

Feel free to submit issues or pull requests to improve this syllabus publishing system.

## License

See LICENSE file for details.