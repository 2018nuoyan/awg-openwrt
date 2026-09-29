#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="${1:?必须指定输出文件}"
REPOSITORY="${2:?必须指定仓库}"

: "${GH_TOKEN:?必须设置 GH_TOKEN}"

page_download_counts=$(
  gh api --paginate \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${REPOSITORY}/releases?per_page=10" \
    --jq '[.[] | select(.draft == false) | .assets[].download_count] | add // 0'
)

total_downloads=0
while IFS= read -r page_downloads; do
  [ -n "$page_downloads" ] || continue
  case "$page_downloads" in
    *[!0-9]*)
      echo "GitHub API 返回的下载次数无效：$page_downloads" >&2
      exit 1
      ;;
  esac
  total_downloads=$((total_downloads + page_downloads))
done <<< "$page_download_counts"

mkdir -p "$(dirname "$OUTPUT_FILE")"
temporary_file="${OUTPUT_FILE}.tmp"
cat > "$temporary_file" <<EOF
{
  "schemaVersion": 1,
  "label": "发行版下载次数",
  "message": "$total_downloads",
  "color": "blue"
}
EOF
mv "$temporary_file" "$OUTPUT_FILE"

echo "GitHub 发行版资源总下载次数：$total_downloads"
