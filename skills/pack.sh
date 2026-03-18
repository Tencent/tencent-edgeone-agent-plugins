#!/usr/bin/env bash
# pack.sh — 将 eo-common 注入业务 skill，输出到 dist/ 目录
# 用法: ./pack.sh [skill_name]
#   ./pack.sh                  构建所有业务 skill
#   ./pack.sh eo-acceleration  只构建指定 skill
set -e
cd "$(dirname "$0")"

COMMON_REF="eo-common/references"
# 自动扫描当前目录，排除 eo-common 和 dist
ALL_SKILLS=()
for d in */; do
  d="${d%/}"
  [[ "$d" == "eo-common" || "$d" == "dist" ]] && continue
  [[ -f "$d/SKILL.md" ]] && ALL_SKILLS+=("$d")
done
DIST="dist"

# 如果指定了参数，只构建对应 skill
if [[ -n "$1" ]]; then
  SKILLS=("$1")
else
  SKILLS=("${ALL_SKILLS[@]}")
fi

for skill in "${SKILLS[@]}"; do
  if [[ ! -d "$skill" ]]; then
    echo "❌ 目录不存在: $skill" >&2
    exit 1
  fi

  target="$DIST/$skill"
  echo "📦 构建 $skill -> $target"

  # 清理旧构建
  rm -rf "$target"
  mkdir -p "$target/references"

  # 1. 拷贝业务 skill 自身内容
  cp "$skill/SKILL.md" "$target/SKILL.md"
  if ls "$skill/references"/* &>/dev/null; then
    cp -r "$skill/references"/* "$target/references/"
  fi

  # 2. 注入 eo-common 的 references（不覆盖同名文件）
  for item in "$COMMON_REF"/*; do
    name=$(basename "$item")
    dest="$target/references/$name"
    if [[ -e "$dest" ]]; then
      echo "  ⚠️  跳过 $name（业务 skill 已有同名文件）"
      continue
    fi
    cp -r "$item" "$dest"
    echo "  ✅ 注入 $name"
  done

  echo "  📁 完成: $(find "$target" -type f | wc -l | tr -d ' ') 个文件"
  echo ""
done

echo "🎉 构建完成，输出目录: $DIST/"
echo ""
