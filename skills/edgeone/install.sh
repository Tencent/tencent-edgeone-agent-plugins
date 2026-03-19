#!/usr/bin/env bash
# EdgeOne 技能安装脚本
# 通过软链将本技能安装给 Codex、Claude、Cursor、CodeBuddy 使用。
# 用法: ./install.sh  或  bash install.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

find_skill_names() {
  local skill_names=()
  local skill_dir
  shopt -s nullglob
  for skill_dir in "$REPO_ROOT"/*; do
    [[ -d "$skill_dir" ]] || continue
    # 只检查当前目录的直接子目录，不包含子目录中的子目录
    [[ "$skill_dir" != "$REPO_ROOT/references" ]] || continue
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_names+=("$(basename "$skill_dir")")
  done
  shopt -u nullglob

  # 如果当前目录本身包含SKILL.md，则将其作为主技能
  if [[ -f "$REPO_ROOT/SKILL.md" ]]; then
    skill_names+=("$(basename "$REPO_ROOT")")
  fi

  if [[ ${#skill_names[@]} -eq 0 ]]; then
    echo "未找到可安装的 skill：$REPO_ROOT 下没有包含 SKILL.md 的顶层目录" >&2
    exit 1
  fi

  printf '%s\n' "${skill_names[@]}"
}

install_to() {
  local dir="$1"
  local skill_name="$2"
  local source
  local target

  # 如果技能名称与当前目录名称相同，说明是当前目录本身作为技能
  if [[ "$skill_name" == "$(basename "$REPO_ROOT")" ]]; then
    source="$REPO_ROOT"
    target="${dir}/${skill_name}"
  else
    source="${REPO_ROOT}/${skill_name}"
    target="${dir}/${skill_name}"
  fi

  if [[ ! -d "$source" || ! -f "$source/SKILL.md" ]]; then
    echo "[失败] $skill_name：源目录不存在或缺少 SKILL.md：$source" >&2
    return 1
  fi

  mkdir -p "$dir"

  if [[ -L "$target" ]]; then
    local current_target
    current_target="$(readlink "$target")"
    if [[ "$current_target" == "$source" ]]; then
      echo "[已安装] $target -> $source"
      return 0
    fi
    rm -f "$target"
    ln -s "$source" "$target"
    echo "[已更新] $target -> $source"
    return 0
  fi

  if [[ -e "$target" ]]; then
    echo "[跳过] $target：已存在且不是软链，请手动处理后重试" >&2
    return 1
  fi

  ln -s "$source" "$target"
  echo "[已安装] $target -> $source"
}

install_group() {
  local client_name="$1"
  local skills_dir="$2"
  local skill_name
  local failed=0

  echo "### ${client_name}"
  for skill_name in "${SKILL_NAMES[@]}"; do
    if ! install_to "$skills_dir" "$skill_name"; then
      failed=1
    fi
  done
  echo ""

  return "$failed"
}

mapfile -t SKILL_NAMES < <(find_skill_names)

FAILED_CLIENTS=()

echo "技能根目录: $REPO_ROOT"
echo "发现技能: ${SKILL_NAMES[*]}"
echo ""

CODEX_SKILLS="${CODEX_HOME:-$HOME/.codex}/skills"
if ! install_group "Codex" "$CODEX_SKILLS"; then
  FAILED_CLIENTS+=("Codex")
fi

if ! install_group "Claude" "$HOME/.claude/skills"; then
  FAILED_CLIENTS+=("Claude")
fi

if ! install_group "Cursor" "$HOME/.cursor/skills"; then
  FAILED_CLIENTS+=("Cursor")
fi

if ! install_group "CodeBuddy" "$HOME/.codebuddy/skills"; then
  FAILED_CLIENTS+=("CodeBuddy")
fi

if [[ ${#FAILED_CLIENTS[@]} -gt 0 ]]; then
  echo "安装结束，但以下客户端存在跳过或失败：${FAILED_CLIENTS[*]}" >&2
  exit 1
fi

echo "安装完成，所有客户端的 skill 已同步到最新链接。若客户端已运行，请重启后加载。"