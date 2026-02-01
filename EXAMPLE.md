# Publishing Example

This is a quick example showing how the book publishing system works.

## Steps to Publish

1. **Edit your content** in `syllabus.md`
2. **Customize metadata** in `metadata.yml`
3. **Run the build**: `make html`
4. **View output** in `output/syllabus.html`

## Example Output

When you run `make`, the system will:

```bash
$ make
mkdir -p output
Generating PDF...
Warning: PDF generation failed. XeLaTeX or pdflatex may not be installed.
Generating HTML...
HTML generated: output/syllabus.html
```

The HTML output includes:
- ✅ Table of contents with navigation
- ✅ Professional styling
- ✅ Numbered sections
- ✅ Responsive design
- ✅ Print-friendly layout

## Supported Formats

| Format | Command | Output File |
|--------|---------|-------------|
| HTML | `make html` | `output/syllabus.html` |
| PDF | `make pdf` | `output/syllabus.pdf` |
| EPUB | `make epub` | `output/syllabus.epub` |
| All | `make book` | All formats |

## Next Steps

- Customize `style.css` for different colors/fonts
- Add more content to `syllabus.md`
- Adjust page size/margins in `metadata.yml`
- Install LaTeX for PDF generation

Enjoy publishing your books! 📚
