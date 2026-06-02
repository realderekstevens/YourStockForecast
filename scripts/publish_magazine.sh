#!/usr/bin/env bash
# =============================================================================
# publish_magazine.sh
#
# All-in-one pipeline for adding a new magazine issue to YourStockForecast:
#   1. Splits a source PDF into single-page PDFs
#   2. Creates Hugo content folders (2/, 3/, 4/ … skipping 1 = cover/index)
#   3. Writes a weighted _index.md in each page folder
#   4. Writes a section-level _index.md in the publication folder
#
# Usage:
#   bash publish_magazine.sh <SOURCE_PDF> [NUM_PAGES]
#
# Examples:
#   bash publish_magazine.sh /path/to/1929-10-28-time.pdf
#   bash publish_magazine.sh /path/to/1929-10-28-time.pdf 36
#
# Filename must follow the pattern:  YYYY-MM-DD-<publication>.pdf
#   e.g.  1931-03-16-time.pdf
#         1929-10-28-nyt.pdf
#         1929-10-03-los-angeles-times.pdf
# =============================================================================

set -euo pipefail

# ── HARD-CODED SITE PATHS (edit once, never again) ───────────────────────────
HUGO_ROOT="/home/dude/Documents/GitHub/YourStockForecast/"
PDF_STATIC_DIR="${HUGO_ROOT}/static/pdf"
CONTENT_BASE="${HUGO_ROOT}/content.en"
# ─────────────────────────────────────────────────────────────────────────────

# ── PUBLICATION CONFIG TABLE ─────────────────────────────────────────────────
pub_display_name() {
    case "$1" in
        time)               echo "Time" ;;
        nyt)                echo "The New York Times" ;;
        los-angeles-times)  echo "Los Angeles Times" ;;
        *)                  echo "$1" ;;
    esac
}

pub_location() {
    case "$1" in
        time)               echo "New York, NY" ;;
        nyt)                echo "New York, NY" ;;
        los-angeles-times)  echo "Los Angeles, CA" ;;
        *)                  echo "New York, NY" ;;
    esac
}

pub_layout() {
    echo "newspaper"
}

pub_content_dir_name() {
    case "$1" in
        time)               echo "Time" ;;
        nyt)                echo "New-York-Times" ;;
        los-angeles-times)  echo "Los-Angeles-Times" ;;
        *)                  # Title-case the slug, replacing hyphens with spaces then back
            echo "$1" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | sed 's/ /-/g'
            ;;
    esac
}
# ─────────────────────────────────────────────────────────────────────────────

# ── ARGUMENT PARSING ─────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    echo "Usage: bash $0 <SOURCE_PDF> [NUM_PAGES]"
    echo "  SOURCE_PDF  full path to the unsplit magazine PDF"
    echo "  NUM_PAGES   (optional) override auto-detected page count"
    exit 1
fi

SOURCE_PDF="$1"
OVERRIDE_PAGES="${2:-}"

if [[ ! -f "$SOURCE_PDF" ]]; then
    echo "ERROR: File not found: ${SOURCE_PDF}"
    exit 1
fi

# Derive DATE and PUB_SLUG from filename  e.g. 1929-10-28-time.pdf
BASENAME=$(basename "$SOURCE_PDF" .pdf)
DATE=$(echo "$BASENAME" | grep -oP '^\d{4}-\d{2}-\d{2}')
PUB_SLUG=$(echo "$BASENAME" | sed "s/^${DATE}-//")

YEAR=$(echo "$DATE"  | cut -d- -f1)
MONTH=$(echo "$DATE" | cut -d- -f2)
DAY=$(echo "$DATE"   | cut -d- -f3)

PUBLICATION=$(pub_display_name  "$PUB_SLUG")
LOCATION=$(pub_location         "$PUB_SLUG")
LAYOUT=$(pub_layout             "$PUB_SLUG")
CONTENT_DIR_NAME=$(pub_content_dir_name "$PUB_SLUG")

HUGO_DATE="${DATE}T00:00:00-06:00"
PDF_PREFIX="${DATE}-${PUB_SLUG}"
CONTENT_DIR="${CONTENT_BASE}/${YEAR}/${MONTH}/${DAY}/${CONTENT_DIR_NAME}"

echo "============================================================"
echo "  Source PDF   : ${SOURCE_PDF}"
echo "  Publication  : ${PUBLICATION}"
echo "  Location     : ${LOCATION}"
echo "  Date         : ${DATE}"
echo "  PDF prefix   : ${PDF_PREFIX}"
echo "  Content dir  : ${CONTENT_DIR}"
echo "============================================================"
echo ""

# ── STEP 1: SPLIT PDF ────────────────────────────────────────────────────────
echo "[ 1/3 ] Splitting PDF into single pages..."

mkdir -p "$PDF_STATIC_DIR"

python3 - <<PYEOF
from pypdf import PdfReader, PdfWriter
import os

src     = "${SOURCE_PDF}"
out_dir = "${PDF_STATIC_DIR}"
prefix  = "${PDF_PREFIX}"

reader = PdfReader(src)
total  = len(reader.pages)
print(f"        {total} pages found in source PDF.")

for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    out_path = os.path.join(out_dir, f"{prefix}-{i+1}.pdf")
    with open(out_path, "wb") as f:
        writer.write(f)
    print(f"        wrote {os.path.basename(out_path)}")

print(f"        Split complete: {total} files written to {out_dir}")
PYEOF

# ── DETECT PAGE COUNT ────────────────────────────────────────────────────────
if [[ -n "$OVERRIDE_PAGES" ]]; then
    NUM_PAGES="$OVERRIDE_PAGES"
    echo ""
    echo "        Using override page count: ${NUM_PAGES}"
else
    NUM_PAGES=$(find "$PDF_STATIC_DIR" -maxdepth 1 -name "${PDF_PREFIX}-*.pdf" | wc -l)
    echo ""
    echo "        Auto-detected ${NUM_PAGES} page PDFs on disk."
fi

# ── STEP 2: SECTION _index.md ────────────────────────────────────────────────
echo ""
echo "[ 2/3 ] Writing section _index.md for ${PUBLICATION}..."

mkdir -p "$CONTENT_DIR"

TITLE_DATE=$(date -d "${DATE}" "+%B %-d, %Y")

cat > "${CONTENT_DIR}/_index.md" <<EOF
+++
title       = "${TITLE_DATE}"
date        = ${HUGO_DATE}
draft       = false
layout      = "${LAYOUT}"
publication = "${PUBLICATION}"
location    = "${LOCATION}"
pdf_cover   = "/pdf/${PDF_PREFIX}-1.pdf"
+++
EOF

echo "        wrote ${CONTENT_DIR}/_index.md"

# ── STEP 3: PER-PAGE _index.md FILES (pages 2+ — page 1 is the cover/index) ─
echo ""
echo "[ 3/3 ] Creating $((NUM_PAGES - 1)) page folders (skipping page 1 = cover)..."

for (( i=2; i<=NUM_PAGES; i++ )); do
    PAGE_DIR="${CONTENT_DIR}/${i}"
    mkdir -p "$PAGE_DIR"

    PDF_PATH="/pdf/${PDF_PREFIX}-${i}.pdf"

    cat > "${PAGE_DIR}/_index.md" <<EOF
+++
title       = "Page ${i}"
date        = ${HUGO_DATE}
draft       = false
layout      = "${LAYOUT}"
publication = "${PUBLICATION}"
location    = "${LOCATION}"
weight      = ${i}

pdf_cover = "${PDF_PATH}"
+++
EOF

    echo "        [${i}/${NUM_PAGES}] ${PAGE_DIR}/_index.md  →  ${PDF_PATH}"
done

# ── DONE ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  All done!"
echo "  Pages 2–${NUM_PAGES} published under:"
echo "  ${CONTENT_DIR}"
echo "============================================================"
