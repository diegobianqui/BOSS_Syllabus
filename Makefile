# Makefile for publishing BOSS Syllabus from Markdown

# Variables
SOURCE = syllabus.md
METADATA = metadata.yml
OUTPUT_DIR = output
PDF_OUTPUT = $(OUTPUT_DIR)/syllabus.pdf
HTML_OUTPUT = $(OUTPUT_DIR)/syllabus.html
EPUB_OUTPUT = $(OUTPUT_DIR)/syllabus.epub

# Default target
.PHONY: all
all: pdf html

# Create output directory
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Generate PDF
.PHONY: pdf
pdf: $(OUTPUT_DIR)
	@echo "Generating PDF..."
	@if command -v pandoc >/dev/null 2>&1; then \
		pandoc $(METADATA) $(SOURCE) -o $(PDF_OUTPUT) \
			--pdf-engine=xelatex \
			--toc \
			--number-sections \
			--highlight-style=tango \
			2>/dev/null || \
		pandoc $(METADATA) $(SOURCE) -o $(PDF_OUTPUT) \
			--toc \
			--number-sections \
			--highlight-style=tango \
			2>/dev/null || \
		echo "Warning: PDF generation failed. XeLaTeX or pdflatex may not be installed."; \
	else \
		echo "Error: pandoc is not installed. Please install pandoc to generate PDF."; \
		exit 1; \
	fi
	@if [ -f $(PDF_OUTPUT) ]; then \
		echo "PDF generated: $(PDF_OUTPUT)"; \
	fi

# Generate HTML
.PHONY: html
html: $(OUTPUT_DIR)
	@echo "Generating HTML..."
	@if command -v pandoc >/dev/null 2>&1; then \
		pandoc $(METADATA) $(SOURCE) -o $(HTML_OUTPUT) \
			--standalone \
			--toc \
			--number-sections \
			--highlight-style=tango \
			--css=style.css; \
		echo "HTML generated: $(HTML_OUTPUT)"; \
	else \
		echo "Error: pandoc is not installed. Please install pandoc to generate HTML."; \
		exit 1; \
	fi

# Generate EPUB
.PHONY: epub
epub: $(OUTPUT_DIR)
	@echo "Generating EPUB..."
	@if command -v pandoc >/dev/null 2>&1; then \
		pandoc $(METADATA) $(SOURCE) -o $(EPUB_OUTPUT) \
			--toc \
			--number-sections; \
		echo "EPUB generated: $(EPUB_OUTPUT)"; \
	else \
		echo "Error: pandoc is not installed. Please install pandoc to generate EPUB."; \
		exit 1; \
	fi

# Generate all formats
.PHONY: book
book: pdf html epub

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning output directory..."
	rm -rf $(OUTPUT_DIR)
	@echo "Output directory cleaned."

# Help target
.PHONY: help
help:
	@echo "BOSS Syllabus Book Publishing"
	@echo ""
	@echo "Available targets:"
	@echo "  make all     - Generate PDF and HTML (default)"
	@echo "  make pdf     - Generate PDF version"
	@echo "  make html    - Generate HTML version"
	@echo "  make epub    - Generate EPUB version"
	@echo "  make book    - Generate all formats (PDF, HTML, EPUB)"
	@echo "  make clean   - Remove all generated files"
	@echo "  make help    - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - pandoc (required)"
	@echo "  - xelatex or pdflatex (for PDF generation)"
