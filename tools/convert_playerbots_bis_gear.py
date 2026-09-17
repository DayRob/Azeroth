#!/usr/bin/env python3
"""Convert mod-playerbots' playerbots_bis_gear rows into playerbots_bis_item rows.

Usage:
    python3 tools/convert_playerbots_bis_gear.py \
        /path/to/mod-playerbots/data/sql/playerbots/updates/2026_04_28_00_playerbots_bis_gear.sql \
        > data/sql/db-world/base/02_playerbots_bis_item.sql

The source table keys gear by auto_gear_score_limit (an item level). This maps
each of those to a tier_id on our ladder. Where two source item levels describe
the same content (a "tier N" list and a "phase N" list), the phase list wins
rank 1 and the tier list becomes rank 2 - a fallback rather than a duplicate.
"""
import collections
import re
import sys

MAP = {
     66: ( 20, 2),  78: ( 20, 1),
     76: ( 30, 2),  83: ( 30, 1),
     88: ( 60, 1),  92: ( 70, 1),
    120: ( 80, 1), 125: ( 90, 1), 141: (100, 1), 156: (110, 1), 164: (120, 1),
    200: (140, 2), 213: (140, 2), 224: (140, 1),
    245: (150, 1), 258: (160, 1), 264: (170, 2), 290: (170, 1),
}

ROW_RE = re.compile(
    r"^\((\d+), *(\d+), *(\d+), *(\d+), *(\d+), *(\d+), *'([^']*)', *'([^']*)', "
    r"*'((?:[^']|'')*)', *'([^']*)', *'([^']*)', *'((?:[^']|'')*)'\)")


def main(path):
    rows = []
    unmapped = set()
    for line in open(path, encoding="utf-8"):
        m = ROW_RE.match(line.strip())
        if not m:
            continue
        cls, tab, slot, faction, ilvl, item = (int(m.group(i)) for i in range(1, 7))
        _phase, clsname, specname = m.group(7), m.group(8), m.group(9)
        itemname = m.group(12)
        if ilvl not in MAP:
            unmapped.add(ilvl)
            continue
        tier, rank = MAP[ilvl]
        comment = f"{clsname} {specname} - {itemname}".replace("''", "'").replace("'", "''")[:160]
        rows.append((cls, tab, slot, faction, tier, item, rank, comment))

    best = {}
    for r in rows:
        key = r[:6]
        if key not in best or r[6] < best[key][6]:
            best[key] = r
    rows = sorted(best.values())

    print("INSERT INTO `playerbots_bis_item` "
          "(`class`, `spec`, `slot`, `faction`, `tier_id`, `item_id`, `rank`, `comment`) VALUES")
    print(",\n".join(
        f"({r[0]}, {r[1]}, {r[2]}, {r[3]}, {r[4]}, {r[5]}, {r[6]}, '{r[7]}')" for r in rows) + ";")

    if unmapped:
        print(f"-- unmapped source item levels: {sorted(unmapped)}", file=sys.stderr)
    print(f"-- {len(rows)} rows, per tier: "
          f"{dict(sorted(collections.Counter(r[4] for r in rows).items()))}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
