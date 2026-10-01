#!/usr/bin/env python3
"""Write the fail2ban 1.1.0 setuptools test_suite drop patch.

fail2ban 1.1.0 still passes test_suite= to setup(). setuptools >= 72 removed
dist.check_test_suite, and the host build dies with:
    AttributeError: module 'setuptools.dist' has no attribute 'check_test_suite'
The hunk is fixed text, checked before write, so a broken generator cannot
emit a patch that silently no-ops.
"""
import sys
from pathlib import Path

BODY = """--- a/setup.py
+++ b/setup.py
@@ -172,7 +172,6 @@ commands.'''

 if setuptools:
 \tsetup_extra = {
-\t\t'test_suite': \"fail2ban.tests.utils.gatherTests\",
 \t}
 else:
 \tsetup_extra = {}
"""

def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: fail2ban-drop-test-suite.py <patch-path>")
    if "test_suite" not in BODY or not BODY.startswith("--- a/setup.py\n"):
        raise SystemExit("fail2ban test_suite patch lost its hunk")
    dest = Path(sys.argv[1])
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(BODY)
    written = dest.read_text()
    if written != BODY:
        raise SystemExit("fail2ban patch write mismatch")
    print(f"wrote {dest} ({dest.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
