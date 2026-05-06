# Task 2 — AI Debugging Report

Document one debugging session you had during Task 1 where you used an LLM
(ChatGPT, Claude, GitHub Copilot, etc.) to help fix a bug.

> ⚠️ **Before pasting code into an LLM:** the `messy_users.csv` data is
> fictional and safe to share. On real-world data at work, never paste names,
> emails, IDs, or other PII into an external LLM. Redact first.

## The Error

<!-- Paste the full traceback or describe the wrong behaviour. Include the
exact error message and the line of your code that triggered it. -->
Traceback (most recent call last):
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\cleaner.py", line 58, in <module>
    main(args.input, args.output)
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\cleaner.py", line 46, in main
    cleaned = [c for row in reader if (c := clean_row(row)) is not None]
                                            ^^^^^^^^^^^^^^
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\cleaner.py", line 38, in clean_row
    "salary": clean_salary(row.get("salary", "")),
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\utils.py", line 49, in clean_salary
    salary = int(raw.strip().replace(",","").replace('"',""))
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ValueError: invalid literal for int() with base 10: 'N/A'

## The Prompt

<!-- The exact text you sent to the LLM. Include the code you pasted with
it. -->
Traceback (most recent call last):
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\cleaner.py", line 58, in <module>
    main(args.input, args.output)
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\cleaner.py", line 46, in main
    cleaned = [c for row in reader if (c := clean_row(row)) is not None]
                                            ^^^^^^^^^^^^^^
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\cleaner.py", line 38, in clean_row
    "salary": clean_salary(row.get("salary", "")),
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\Beheerder\c55-data-week1\task-1\src\utils.py", line 49, in clean_salary
    salary = int(raw.strip().replace(",","").replace('"',""))
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ValueError: invalid literal for int() with base 10: 'N/A'
Why i get this? Explain it to me

## The Solution

<!-- What did the LLM suggest? Did it work on the first try, or did you
need a follow-up? -->
It work from the first try and Gemini response is:
Think of a **Traceback** as a "crime scene report" for your code. It shows you exactly where the program "died" and why.

Here is the breakdown of why you got this error:

### 1. The Root Cause: `ValueError`
At the very bottom of your error message, you see:
`ValueError: invalid literal for int() with base 10: 'N/A'`

* **`int()`**: This is a function that expects a string of digits (like `"100"` or `"5000"`).
* **`'N/A'`**: This is the actual value the program found in your CSV file. 
* **The Problem**: Python does not know how to turn the letters "N", "/", and "A" into a whole number. Since it can't do the math, it panics and shuts down the entire script.

---

### 2. The Chain of Events (Traceback)
The Traceback reads from **bottom to top** to show the sequence of calls:

* **At the bottom (`utils.py`, line 49):** This is the exact line where the crash happened. The code tried to execute `int(raw.strip()...)` on the value `'N/A'`.
* **The middle (`cleaner.py`, line 38):** This shows that `clean_row` called the `clean_salary` function.
* **The top (`cleaner.py`, line 46):** This shows that the error happened while your program was looping through the rows of your CSV. Because one row was "broken," it stopped the entire cleaning process for the remaining rows.



---

### 3. Why did this happen now?
In real-world data (like your `messy_users.csv`), columns aren't always perfect. Even if a column is named "salary," someone might have typed "N/A," "Unknown," or "5000.00" (a float). 

Your current code is **fragile** because it assumes every single row will have a perfect integer.

---

### 4. How to Fix It (Defensive Programming)
To prevent this, you need to use a **try/except** block. This tells Python: *"Try to turn this into an integer. If you see a `ValueError` (like 'N/A'), don't crash! Just return `None` instead."*

**The fix in `utils.py`:**
```python
    try:
        # Clean the string (remove commas, spaces, etc.)
        clean_value = raw.strip().replace(",", "").replace('"', "")
        return int(clean_value)
    except ValueError:
        # If 'N/A' or any non-number is found, return None safely
        return None
```



By adding this, your script will successfully finish the task, and the "bad" salaries will simply appear as `null` in your JSON file instead of breaking the program.

## Reflection

<!-- A few sentences on: did you understand WHY the original code was
broken, or did you just accept the fix? What would you do differently next
time? -->
After the LLm response, I understand it because I was using the try/except but in the wrong way.
I think I will try to fix it first without using LLm by following the trace from bottom to top!


