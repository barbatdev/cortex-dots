#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%s\n' 'FAIL oss-audit must run inside a git worktree' >&2
    exit 1
fi

forbidden_regex="${OSS_AUDIT_FORBIDDEN_REGEX:-}"
email_regex='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}'
failed=0

if [[ -f .oss-audit-denylist.local ]]; then
    while IFS= read -r pattern; do
        [[ -n "$pattern" && "$pattern" != \#* ]] || continue
        if [[ -n "$forbidden_regex" ]]; then
            forbidden_regex+="|$pattern"
        else
            forbidden_regex="$pattern"
        fi
    done < .oss-audit-denylist.local
fi

if [[ -n "$forbidden_regex" ]]; then
    set +e
    LC_ALL=C grep -Eq "$forbidden_regex" /dev/null 2>/tmp/cortex-dots-oss-audit-regex-error
    regex_status=$?
    set -e
    if [[ "$regex_status" -eq 2 ]]; then
        printf '%s\n' 'FAIL invalid forbidden identifier regex' >&2
        cat /tmp/cortex-dots-oss-audit-regex-error >&2
        rm -f /tmp/cortex-dots-oss-audit-regex-error
        exit 1
    fi
fi

while IFS= read -r -d '' file; do
    if [[ -n "$forbidden_regex" ]] && LC_ALL=C grep -nEI "$forbidden_regex" "$file" >/tmp/cortex-dots-oss-audit-match 2>/dev/null; then
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

rm -f /tmp/cortex-dots-oss-audit-match /tmp/cortex-dots-oss-audit-regex-error

if [[ "$failed" -ne 0 ]]; then
    exit 1
fi

printf '%s\n' 'PASS oss-audit'
