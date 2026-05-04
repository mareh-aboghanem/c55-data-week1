#!/usr/bin/env bash
# Auto-grade Week 1 assignment. Writes score.json next to this script.
# Total = 100, passing = 60.
#
# The auto-grade workflow runs this from the .hyf working directory; we
# resolve the repo root so the script is robust to either invocation
# (cd .hyf && bash test.sh, or bash .hyf/test.sh from the repo root).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

PASSING=60

# --- Task 1: The Cleaner Pipeline (60 points) ---
#
# Scoring ladder (each level depends on the previous):
#   0   nothing committed
#   10  cleaner.py + utils.py both present
#   20  cleaner runs against messy_users.csv without crashing
#   40  output passes structural checks (correct shape, no missing fields,
#       lowercase emails, etc.)
#   60  the *code* also looks engineered: imports `logging`, uses `pathlib`,
#       and `utils.py` defines real helper functions (not empty stubs).
#
# Why the introspection cap at 40: a 5-line script that hardcodes a JSON
# literal of fake users and dumps it to disk satisfies the structural
# checks without doing any cleaning. Capping at 40 unless real engineering
# patterns are present raises the floor against LLM-generated shortcuts.
# Teachers still review code quality during PR review (see chapter
# Evaluation criteria).
task1=0
task1_msg="missing src/cleaner.py or src/utils.py"
if [ -f task-1/src/cleaner.py ] && [ -f task-1/src/utils.py ]; then
    task1=10
    task1_msg="files exist but cleaner failed to run"
    if ( cd task-1 && python3 src/cleaner.py --input data/messy_users.csv --output output/clean_users.json ) >/dev/null 2>&1; then
        task1=20
        task1_msg="cleaner ran but output failed structural checks"
        if python3 - <<'PY' 2>/dev/null
import json
from pathlib import Path

p = Path("task-1/output/clean_users.json")
data = json.loads(p.read_text(encoding="utf-8"))
assert isinstance(data, list), "output must be a JSON array"
assert len(data) >= 10, f"expected at least 10 cleaned rows, got {len(data)}"
seen_emails = set()
for row in data:
    name = row.get("name")
    email = row.get("email")
    assert isinstance(name, str) and name.strip() == name and name, f"bad name: {name!r}"
    assert isinstance(email, str) and email == email.lower() and "@" in email, f"bad email: {email!r}"
    seen_emails.add(email)
    dept = row.get("department")
    assert isinstance(dept, str) and dept, f"missing department on row id={row.get('id')}"
    salary = row.get("salary")
    assert salary is None or isinstance(salary, int), f"salary must be int or null, got {type(salary).__name__}"
assert len(seen_emails) == len(data), "duplicate emails found"
PY
        then
            task1=40
            task1_msg="output passes structural checks but code is missing required engineering patterns (see below)"
            # Introspection caps. The full 60 requires:
            #  - cleaner.py imports `logging` (the chapter mandates `logging`, not `print`)
            #  - cleaner.py imports something from `pathlib`
            #  - utils.py defines at least 2 functions (the chapter mandates field-cleaning helpers)
            # Match `import logging`, `from logging import ...`, and
            # comma-separated forms like `import argparse, csv, json, logging`.
            # Same for pathlib. Anchored at line start so the words inside
            # comments or string literals are not counted.
            cleaner_has_logging=$(grep -cE "^[[:space:]]*import .*\blogging\b|^[[:space:]]*from logging\b" task-1/src/cleaner.py || true)
            cleaner_has_pathlib=$(grep -cE "^[[:space:]]*import .*\bpathlib\b|^[[:space:]]*from pathlib\b" task-1/src/cleaner.py || true)
            utils_helper_count=$(grep -c "^def " task-1/src/utils.py || true)
            if [ "$cleaner_has_logging" -gt 0 ] && \
               [ "$cleaner_has_pathlib" -gt 0 ] && \
               [ "$utils_helper_count" -ge 2 ]; then
                task1=60
                task1_msg="cleaner output and code structure both pass"
            else
                missing=()
                [ "$cleaner_has_logging" -eq 0 ] && missing+=("import logging in cleaner.py")
                [ "$cleaner_has_pathlib" -eq 0 ] && missing+=("from pathlib import ... in cleaner.py")
                [ "$utils_helper_count" -lt 2 ] && missing+=("at least 2 functions in utils.py (found $utils_helper_count)")
                task1_msg="output passes but code missing: $(IFS=, ; echo "${missing[*]}")"
            fi
        fi
    fi
fi

# --- Task 2: AI Debug Report (20 points) ---
task2=0
task2_msg="missing task-2/AI_DEBUG.md"
if [ -s task-2/AI_DEBUG.md ]; then
    task2=5
    task2_msg="AI_DEBUG.md exists but missing required sections"
    if grep -q "^## The Error" task-2/AI_DEBUG.md && \
       grep -q "^## The Prompt" task-2/AI_DEBUG.md && \
       grep -q "^## The Solution" task-2/AI_DEBUG.md && \
       grep -q "^## Reflection" task-2/AI_DEBUG.md; then
        task2=10
        task2_msg="all sections present but file looks too short to be filled in"
        # Empty template ships at ~900 chars. Filled-in report should have
        # meaningfully more content; threshold = template + ~600 chars
        # of student writing (4 sections * ~150 chars each).
        if [ "$(wc -c < task-2/AI_DEBUG.md)" -gt 1500 ]; then
            task2=20
            task2_msg="AI_DEBUG.md is filled in"
        fi
    fi
fi

# --- Task 3: HYF Azure Proof (20 points) ---
task3=0
task3_msg="missing task-3/azure_proof.png|jpg|jpeg"
for ext in png jpg jpeg; do
    if [ -s "task-3/azure_proof.$ext" ]; then
        task3=20
        task3_msg="azure_proof.$ext present"
        break
    fi
done

score=$((task1 + task2 + task3))
if [ "$score" -ge "$PASSING" ]; then pass=true; else pass=false; fi

cat > "$SCRIPT_DIR/score.json" <<EOF
{
  "score": $score,
  "pass": $pass,
  "passingScore": $PASSING
}
EOF

echo "Task 1 (Cleaner Pipeline): $task1/60 — $task1_msg"
echo "Task 2 (AI Debug Report):  $task2/20 — $task2_msg"
echo "Task 3 (Azure Proof):       $task3/20 — $task3_msg"
echo "----------------------------------------"
echo "Total: $score/100 — pass=$pass (passing threshold: $PASSING)"
