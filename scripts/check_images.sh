#!/usr/bin/env bash
# Usage: scripts/check_images.sh [README.md]   (CHECK_SNAKE=1 to include snake URLs)
set -u
f="${1:-README.md}"; fail=0
urls=$(grep -oE '(src|srcset)="[^"]+"' "$f" | sed -E 's/^(src|srcset)="//; s/"$//' | sed 's/&amp;/\&/g' | sort -u)
[ -z "$urls" ] && { echo "FAIL: no images found in $f"; exit 1; }
while IFS= read -r u; do
  if [[ "$u" != http* ]]; then
    [ -f "$u" ] && echo "ok    $u" || { echo "FAIL  missing local file $u"; fail=1; }; continue
  fi
  if [[ "$u" == *"/output/"* && "${CHECK_SNAKE:-0}" != 1 ]]; then echo "skip  $u"; continue; fi
  read -r code ctype < <(curl -sL -o /dev/null -w '%{http_code} %{content_type}\n' --max-time 20 "$u")
  if [[ "$code" == 200 && "$ctype" == *svg* ]]; then echo "ok    $u"; else echo "FAIL  $code $ctype $u"; fail=1; fi
done <<< "$urls"
exit $fail
