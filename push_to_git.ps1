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

# 等待用户选择是否自定义提交消息
Write-Host "是否自定义提交消息？按 Y 自定义，其他键或等待3秒将使用默认消息: '$Message'" -ForegroundColor Cyan
$customMessage = $false
$timeoutSeconds = 3
$startTime = Get-Date

while (((Get-Date) - $startTime).TotalSeconds -lt $timeoutSeconds) {
    if ([Console]::KeyAvailable) {
        $key = [Console]::ReadKey($true).Key
        if ($key -eq 'Y' -or $key -eq 'y') {
            $customMessage = $true
            break
        } else {
            break
        }
    }
    Start-Sleep -Milliseconds 100
}

if ($customMessage) {
    Write-Host "请输入提交消息 (直接回车使用默认): " -ForegroundColor Yellow -NoNewline
    $userMessage = Read-Host
    if (-not [string]::IsNullOrWhiteSpace($userMessage)) {
        $Message = $userMessage
    }
} else {
    Write-Host "使用默认提交消息: $Message" -ForegroundColor Green
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