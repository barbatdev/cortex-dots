#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%s\n' 'FAIL oss-audit must run inside a git worktree' >&2
    exit 1
fi

forbidden_regex='InnIT|innit|barbatdev|barbat[.]dev|RefactorIA|jbarbat|/home/jbarbat|agent-dev|innit[.]com[.]uy'
email_regex='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}'
failed=0

while IFS= read -r -d '' file; do
    case "$file" in
        scripts/oss-audit.sh)
            continue
            ;;
    esac

    if LC_ALL=C grep -nEI "$forbidden_regex" "$file" >/tmp/cortex-dots-oss-audit-match 2>/dev/null; then
        printf 'FAIL forbidden identifier in %s\n' "$file" >&2
        cat /tmp/cortex-dots-oss-audit-match >&2
        failed=1
    fi

    if LC_ALL=C grep -nEI "$email_regex" "$file" >/tmp/cortex-dots-oss-audit-match 2>/dev/null; then
        printf 'FAIL email-shaped string in %s\n' "$file" >&2
        cat /tmp/cortex-dots-oss-audit-match >&2
        failed=1
    fi
done < <(git ls-files -z)

rm -f /tmp/cortex-dots-oss-audit-match

if [[ "$failed" -ne 0 ]]; then
    exit 1
fi

printf '%s\n' 'PASS oss-audit'
