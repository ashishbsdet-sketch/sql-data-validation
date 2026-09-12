#!/usr/bin/env bash
set -euo pipefail

passed=$(psql "${DATABASE_URL}" -Atc "SELECT count(*) FROM qa_demo.qa_test_results WHERE passed")
failed=$(psql "${DATABASE_URL}" -Atc "SELECT count(*) FROM qa_demo.qa_test_results WHERE NOT passed")
total=$((passed + failed))

if [[ "${failed}" -eq 0 && "${total}" -gt 0 ]]; then
  headline="✅ ${passed} passed, 0 failed"
else
  headline="❌ ${passed} passed, ${failed} failed"
fi

{
  echo "## SQL validation results"
  echo
  echo "### ${headline}"
  echo
  echo "| Category | Passed | Failed |"
  echo "| --- | ---: | ---: |"
  psql "${DATABASE_URL}" -AtF '|' -c "SELECT category, count(*) FILTER (WHERE passed), count(*) FILTER (WHERE NOT passed) FROM qa_demo.qa_test_results GROUP BY category ORDER BY category" |
    while IFS='|' read -r category category_passed category_failed; do
      echo "| ${category} | ${category_passed} | ${category_failed} |"
    done
} | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"

if [[ "${failed}" -gt 0 || "${total}" -eq 0 ]]; then
  exit 1
fi
