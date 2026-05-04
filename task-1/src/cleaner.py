"""Read messy_users.csv, clean each row using helpers from utils.py, and
write the cleaned rows as JSON.

Run from the task-1/ directory:

    python3 src/cleaner.py --input data/messy_users.csv --output output/clean_users.json
"""

from __future__ import annotations

import argparse
import csv
import json
import logging
from pathlib import Path

from utils import clean_department, clean_email, clean_name, clean_salary

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger(__name__)


def clean_row(row: dict[str, str]) -> dict | None:
    """Clean a single CSV row. Return None to skip the row (validation failed)."""
    name = clean_name(row.get("name", ""))
    email = clean_email(row.get("email", ""))
    if not name:
        log.warning("skipping row id=%s: missing name", row.get("id"))
        return None
    if not email:
        log.warning("skipping row id=%s: missing email", row.get("id"))
        return None
    return {
        "id": int(row["id"]) if row.get("id", "").isdigit() else row.get("id"),
        "name": name,
        "email": email,
        "department": clean_department(row.get("department", "")),
        "salary": clean_salary(row.get("salary", "")),
    }


def main(input_path: Path, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with input_path.open(encoding="utf-8") as f:
        reader = csv.DictReader(f)
        cleaned = [c for row in reader if (c := clean_row(row)) is not None]
    with output_path.open("w", encoding="utf-8") as f:
        json.dump(cleaned, f, indent=2)
    log.info("wrote %d cleaned rows to %s", len(cleaned), output_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Clean messy_users.csv into JSON.")
    parser.add_argument("--input", type=Path, required=True, help="Path to the input CSV.")
    parser.add_argument("--output", type=Path, required=True, help="Path to write the output JSON.")
    args = parser.parse_args()
    try:
        main(args.input, args.output)
    except FileNotFoundError as e:
        log.error("input file not found: %s", e.filename)
        raise SystemExit(1)
