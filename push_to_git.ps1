# push_to_git.ps1
# 将当前工作区更改推送到 Git 仓库
# 用法: .\push_to_git.ps1 [-Message "提交消息"]

param(
    [string]$Message = "Update files"
)

# 检查是否在 Git 仓库中
if (-not (Test-Path ".git")) {
    Write-Error "错误: 当前目录不是 Git 仓库。请确保在 Git 仓库根目录中运行此脚本。"
    exit 1
}

# 询问是否自定义提交消息
$choice = Read-Host "自定义提交消息？(Y=自定义, 回车=默认 '$Message')"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    $userMessage = Read-Host "请输入提交消息"
    if (-not [string]::IsNullOrWhiteSpace($userMessage)) {
        $Message = $userMessage
    }
}

# 添加所有更改
Write-Host "正在添加所有更改..."
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Error "错误: git add 失败。"
    exit 1
}

# 检查是否有更改需要提交
$status = git status --porcelain
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "没有更改需要提交。"
    exit 0
}

# 提交更改
Write-Host "正在提交更改，消息: $Message"
git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    Write-Error "错误: git commit 失败。"
    exit 1
}

# 推送到远程仓库
Write-Host "正在推送到远程仓库..."
git push origin HEAD
if ($LASTEXITCODE -ne 0) {
    Write-Host "推送失败，尝试设置上游分支..."
    git push -u origin HEAD
    if ($LASTEXITCODE -ne 0) {
        Write-Error "错误: git push 失败。请检查网络连接和远程仓库设置。"
        exit 1
    }
}

Write-Host "成功推送到远程仓库！"