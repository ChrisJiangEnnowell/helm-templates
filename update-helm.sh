#!/bin/bash
# 配置变量
CHART_NAME="helm"                    # Helm Chart 的名称
REPO_URL="https://ChrisJiangEnnowell.github.io/helm-templates/"  # 仓库的 URL
GIT_REPO="git@github.com:ChrisJiangEnnowell/helm-templates.git"  # Git 仓库地址
CHART_DIR="./$CHART_NAME"                # Chart 文件夹路径
OUTPUT_DIR="./"                          # 打包输出目录
BRANCH="main"                            # 使用的 Git 分支

# 检查 Helm 是否安装
if ! command -v helm &> /dev/null; then
    echo "Helm 未安装，请先安装 Helm。"
    exit 1
fi

# 检查 Git 是否安装
if ! command -v git &> /dev/null; then
    echo "Git 未安装，请先安装 Git。"
    exit 1
fi

# 更新 Chart 版本
echo "更新 Chart 版本..."
CURRENT_VERSION=$(grep "^version:" "$CHART_DIR/Chart.yaml" | awk '{print $2}')
NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. -v OFS=. '{$NF++; print}')
sed -i.bak "s/^version: .*/version: $NEW_VERSION/" "$CHART_DIR/Chart.yaml"
echo "版本更新至 $NEW_VERSION"

# 打包 Chart
echo "打包 Helm Chart..."
helm package "$CHART_DIR" --destination "$OUTPUT_DIR"

# 生成或更新 index.yaml
echo "生成或更新 index.yaml..."
helm repo index "$OUTPUT_DIR" --url "$REPO_URL"

# 推送更新到 GitHub
echo "提交并推送到 GitHub 仓库..."
git add .
git commit -m "Update Helm Chart $CHART_NAME to version $NEW_VERSION"
git push origin "$BRANCH"

echo "更新完成，版本已推送至仓库！"
