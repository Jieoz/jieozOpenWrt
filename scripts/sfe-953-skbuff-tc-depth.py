#!/usr/bin/env python3
"""Rebase lede's shortcut-fe kernel patch onto linux >= 6.18.57.

Linux 6.18.57 added `__u8 tc_depth:2;` to struct sk_buff right after
`__u8 unreadable:1;`. lede's hack-6.18/953 (shortcut-fe) inserts
`fast_forwarded:1` at that exact spot with the old context, so it stops
applying and toolchain/kernel-headers dies at prepare:
    Hunk #1 FAILED at 1030. ... include/linux/skbuff.h.rej
    Patch failed! ... 953-net-patch-linux-kernel-to-support-shortcut-fe.patch

Only the skbuff.h hunk is rewritten (adds tc_depth as leading context; the
field is inserted after it). Self-disables when:
  - the tree's 6.18 is older than .57 (old hunk is still correct), or
  - upstream already rebased the patch (old hunk no longer present).
Any other mismatch fails loudly instead of silently no-oping.
"""
import re
import sys
from pathlib import Path

PATCH = Path("target/linux/generic/hack-6.18/953-net-patch-linux-kernel-to-support-shortcut-fe.patch")
KVER = Path("include/kernel-6.18")

OLD = """--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1030,6 +1030,9 @@ struct sk_buff {
 \t__u8\t\t\tcsum_not_inet:1;
 #endif
 \t__u8\t\t\tunreadable:1;
+#ifdef CONFIG_SHORTCUT_FE
+\t__u8\t\t\tfast_forwarded:1;
+#endif
 #if defined(CONFIG_NET_SCHED) || defined(CONFIG_NET_XGRESS)
"""

NEW = """--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1032,6 +1032,9 @@ struct sk_buff {
 #endif
 \t__u8\t\t\tunreadable:1;
 \t__u8\t\t\ttc_depth:2;
+#ifdef CONFIG_SHORTCUT_FE
+\t__u8\t\t\tfast_forwarded:1;
+#endif
 #if defined(CONFIG_NET_SCHED) || defined(CONFIG_NET_XGRESS)
"""


def main() -> None:
    m = re.search(r"^LINUX_VERSION-6\.18 = \.(\d+)", KVER.read_text(), re.M)
    if not m:
        raise SystemExit(f"cannot parse 6.18 sublevel from {KVER}")
    sub = int(m.group(1))
    text = PATCH.read_text()
    if sub < 57:
        print(f"linux 6.18.{sub} < 6.18.57: 953 skbuff hunk unchanged")
        return
    if NEW in text:
        print("953 skbuff hunk already rebased for tc_depth")
        return
    if "tc_depth" in text:
        print("953 already mentions tc_depth (upstream rebased); leaving as-is")
        return
    if text.count(OLD) != 1:
        raise SystemExit("953 skbuff hunk not in expected form; refusing to guess")
    PATCH.write_text(text.replace(OLD, NEW))
    if NEW not in PATCH.read_text():
        raise SystemExit("953 rewrite did not land")
    print(f"rebased 953 skbuff hunk onto linux 6.18.{sub} (tc_depth context)")


if __name__ == "__main__":
    main()
