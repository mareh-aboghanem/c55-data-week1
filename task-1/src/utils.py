"""Pure helper functions for cleaning individual fields of messy_users.csv.

Each function takes the raw string from the CSV and returns the cleaned
value (or `None` for missing-but-valid). They never read or write files;
keep them pure so they are easy to test.
"""

from __future__ import annotations


def clean_name(raw: str) -> str:
    """Strip leading/trailing whitespace from a name.

    Returns the cleaned string. An empty input returns "".
    """
    name = raw.strip()
    return name



def clean_email(raw: str) -> str:
    """Lowercase the email, strip surrounding whitespace.

    Returns the cleaned string. An empty input returns "".
    """
    email = raw.strip().lower()
    return email


def clean_department(raw: str) -> str:
    """Return the department, or 'Unknown' if missing/empty.

    Strip whitespace; treat empty string as missing.
    """
    department =raw.strip()
    if not department:
        return "Unknown"
    return department


def clean_salary(raw: str) -> int | None:
    """Parse a messy salary cell into an int.

    Handles inputs like "85000", "  95000", '"68,000"', "N/A", "".
    Returns None when the value cannot be parsed (missing or "N/A").
    """
    try:
        salary = raw.strip().replace(",","").replace('"',"")
        return int(salary)
    except ValueError:
        return None
