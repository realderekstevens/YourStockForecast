#!/usr/bin/env bash
# =============================================================================
# publish_lindsay_oct1929.sh
#
# One-off script: generates Hugo content folders for every edition of
# The Lindsay Daily Post published in October 1929.
#
# The source is a single 236-page PDF covering the entire month:
#   /home/dude/Documents/GitHub/YourStockForecast/static/pdf/1929-10-lindsay-daily-post
#
# Publishing schedule (Lindsay Daily Post skipped Fridays and Sundays):
#
#   Oct  1 (Tue): digital pages   1–  8   [8 pages]   ← known anchor
#   Oct  2 (Wed): digital pages   9– 16   [8 pages]   ← known anchor
#   Oct  3 (Thu): digital pages  17– 26  [10 pages]   ← known anchor
#   Oct  5 (Sat): digital pages  27– 36  [10 pages]   ← known anchor
#   Oct  7 (Mon): digital pages  37– 44   [8 pages]   ← known anchor
#   Oct  8 (Tue): digital pages  45– 52   [8 pages]   ← known anchor
#   Oct  9 (Wed): digital pages  53– 60   [8 pages]   ← known anchor
#   Oct 10 (Thu): digital pages  61– 70  [10 pages]   ← known anchor
#   Oct 12 (Sat): digital pages  71– 82  [12 pages]   ← estimated
#   Oct 14 (Mon): digital pages  83– 93  [11 pages]   ← estimated
#   Oct 15 (Tue): digital pages  94–104  [11 pages]   ← estimated
#   Oct 16 (Wed): digital pages 105–115  [11 pages]   ← estimated
#   Oct 17 (Thu): digital pages 116–127  [12 pages]   ← estimated
#   Oct 19 (Sat): digital pages 128–139  [12 pages]   ← estimated
#   Oct 21 (Mon): digital pages 140–150  [11 pages]   ← estimated
#   Oct 22 (Tue): digital pages 151–161  [11 pages]   ← estimated
#   Oct 23 (Wed): digital pages 162–172  [11 pages]   ← estimated
#   Oct 24 (Thu): digital pages 173–184  [12 pages]   ← estimated
#   Oct 26 (Sat): digital pages 185–196  [12 pages]   ← estimated
#   Oct 28 (Mon): digital pages 197–208  [12 pages]   ← estimated (Black Monday)
#   Oct 29 (Tue): digital pages 209–216   [8 pages]   ← known anchor
#   Oct 30 (Wed): digital pages 217–224   [8 pages]   ← known anchor
#   Oct 31 (Thu): digital pages 225–236  [12 pages]   ← known anchor
#                                                         (NOTE: physical pages 3–14;
#                                                          front pages are missing from scan)
#
# Editions in the middle (Oct 12–28) are ESTIMATED. If you verify the real
# page boundaries while browsing the PDF, adjust the EDITION_MAP below and re-run.
# All folders are generated independently so you can shuffle them freely.
# =============================================================================

set -euo pipefail

# ── SITE PATHS ────────────────────────────────────────────────────────────────
HUGO_ROOT="/home/dude/Documents/GitHub/YourStockForecast"
PDF_STATIC_DIR="${HUGO_ROOT}/static/pdf"
CONTENT_BASE="${HUGO_ROOT}/content.en"
# ─────────────────────────────────────────────────────────────────────────────

PUBLICATION="The Lindsay Daily Post"
LOCATION="Lindsay, Ontario"
LAYOUT="newspaper"
CONTENT_DIR_NAME="Lindsay-Daily-Post"
PDF_BASENAME="1929-10-lindsay-daily-post"   # no extension — it's the unsplit source

# ── EDITION MAP ───────────────────────────────────────────────────────────────
# Format: "YYYY-MM-DD:START_PAGE:NUM_PAGES"
# START_PAGE = 1-indexed page in the source PDF where this edition begins
# NUM_PAGES  = how many digital pages this edition spans
# To adjust an estimate, change the values here and re-run — only that day's
# folder will be affected (the script wipes and rebuilds per-day).
EDITION_MAP=(
    "1929-10-01:1:8"
    "1929-10-02:9:8"
    "1929-10-03:17:10"
    "1929-10-05:27:10"
    "1929-10-07:37:8"
    "1929-10-08:45:8"
    "1929-10-09:53:8"
    "1929-10-10:61:10"
    "1929-10-12:71:12"    # estimated
    "1929-10-14:83:11"    # estimated
    "1929-10-15:94:11"    # estimated
    "1929-10-16:105:11"   # estimated
    "1929-10-17:116:12"   # estimated
    "1929-10-19:128:12"   # estimated
    "1929-10-21:140:11"   # estimated
    "1929-10-22:151:11"   # estimated
    "1929-10-23:162:11"   # estimated
    "1929-10-24:173:12"   # estimated
    "1929-10-26:185:12"   # estimated
    "1929-10-28:197:12"   # estimated (Black Monday edition)
    "1929-10-29:209:8"
    "1929-10-30:217:8"
    "1929-10-31:225:12"   # NOTE: physical front pages missing from scan; starts on phys. p.3
)
# ─────────────────────────────────────────────────────────────────────────────

echo "============================================================"
echo "  Publishing: ${PUBLICATION}"
echo "  Month:      October 1929"
echo "  Editions:   ${#EDITION_MAP[@]}"
echo "  Source PDF: ${PDF_STATIC_DIR}/${PDF_BASENAME}"
echo "============================================================"
echo ""

for entry in "${EDITION_MAP[@]}"; do
    DATE=$(echo "$entry"       | cut -d: -f1)   # e.g. 1929-10-03
    START_PAGE=$(echo "$entry" | cut -d: -f2)   # e.g. 17
    NUM_PAGES=$(echo "$entry"  | cut -d: -f3)   # e.g. 10

    YEAR=$(echo "$DATE"  | cut -d- -f1)
    MONTH=$(echo "$DATE" | cut -d- -f2)
    DAY=$(echo "$DATE"   | cut -d- -f3)

    HUGO_DATE="${DATE}T00:00:00-06:00"
    TITLE_DATE=$(date -d "${DATE}" "+%B %-d, %Y")
    END_PAGE=$(( START_PAGE + NUM_PAGES - 1 ))
    COVER_PDF="/pdf/${PDF_BASENAME}-${START_PAGE}.pdf"

    CONTENT_DIR="${CONTENT_BASE}/${YEAR}/${MONTH}/${DAY}/${CONTENT_DIR_NAME}"

    echo "──────────────────────────────────────────────────────────"
    echo "  ${TITLE_DATE}  (digital pages ${START_PAGE}–${END_PAGE}, ${NUM_PAGES} pages)"
    echo "  → ${CONTENT_DIR}"

    # Wipe and recreate the day's folder for clean re-runs
    rm -rf "$CONTENT_DIR"
    mkdir -p "$CONTENT_DIR"

    # Section _index.md (the edition cover)
    cat > "${CONTENT_DIR}/_index.md" <<EOF
+++
title       = "${TITLE_DATE}"
date        = ${HUGO_DATE}
draft       = false
layout      = "${LAYOUT}"
publication = "${PUBLICATION}"
location    = "${LOCATION}"
pdf_cover   = "${COVER_PDF}"
+++
EOF

    # Per-page folders — skip page 1 of each edition (it's the cover shown above)
    # Page folders are named by their DIGITAL page number in the source PDF so
    # they stay globally unique and easy to cross-reference.
    for (( i=2; i<=NUM_PAGES; i++ )); do
        DIGITAL_PAGE=$(( START_PAGE + i - 1 ))
        PAGE_DIR="${CONTENT_DIR}/${DIGITAL_PAGE}"
        mkdir -p "$PAGE_DIR"

        PDF_PATH="/pdf/${PDF_BASENAME}-${DIGITAL_PAGE}.pdf"

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
    done

    echo "     wrote _index.md + $((NUM_PAGES - 1)) page folders (pages ${START_PAGE}–${END_PAGE}, skipping cover)"
done

echo ""
echo "============================================================"
echo "  All done! ${#EDITION_MAP[@]} editions written."
echo ""
echo "  ESTIMATED EDITIONS (verify page boundaries in PDF):"
echo "    Oct 12, 14, 15, 16, 17, 19, 21, 22, 23, 24, 26, 28"
echo ""
echo "  To correct an edition's boundaries, edit EDITION_MAP in"
echo "  this script and re-run — each day is rebuilt independently."
echo "============================================================"
