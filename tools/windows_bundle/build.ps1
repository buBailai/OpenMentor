<#
.SYNOPSIS
  在 Windows 上构建 OpenMentor 完全免安装包（含嵌入式 Python + 全部依赖）。

.DESCRIPTION
  本脚本生成一个文件夹 OpenMentor_Vx.y.z_Windows免安装包/，里面包含：
    - env\                    嵌入式 Python（python.exe + 所有依赖，约 200-250MB）
    - app.py / templates/ / static/ / *.md / LICENSE  ← OpenMentor 源代码
    - OpenMentor启动器.bat    主入口（双击运行，自动用 env\python.exe）
    - openmentor_installer.py / gui_launcher.py  GUI 启动器

  最终用户只需双击 "OpenMentor启动器.bat"，**电脑无需预装 Python**。

.PARAMETER PythonVersion
  Python 版本（必须是 python.org 提供 Windows embeddable zip 的版本）。
  默认 3.12.7（pandas 2.0.3 wheel 兼容）。

.PARAMETER Arch
  架构。amd64 = 64-bit（默认），win32 = 32-bit。

.PARAMETER SourceDir
  OpenMentor 项目源码目录。默认是上两级（脚本在 tools\windows_bundle\）。

.PARAMETER OutputDir
  输出目录。默认在源码目录的父目录下生成 dist\。

.PARAMETER ZipOutput
  打包成 zip。默认 true。

.PARAMETER UseTsinghua
  pip 用清华镜像（默认 true，国内速度更快）。

.EXAMPLE
  .\build.ps1
  # 用所有默认值构建

.EXAMPLE
  .\build.ps1 -PythonVersion 3.12.7 -ZipOutput $false
  # 不打包成 zip，只生成文件夹

.NOTES
  必须在 Windows 上运行（PowerShell 5.1+ 或 PowerShell 7+）。
  需要联网下载 Python embeddable + get-pip.py + 所有 Python 依赖（首次约 5-10 分钟）。
#>

param(
    [string]$PythonVersion = "3.12.7",
    [ValidateSet("amd64", "win32")]
    [string]$Arch = "amd64",
    [string]$SourceDir = "",
    [string]$OutputDir = "",
    [bool]$ZipOutput = $true,
    [bool]$UseTsinghua = $true
)

$ErrorActionPreference = "Stop"

# ---------------- 路径 ----------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($SourceDir)) {
    # 默认：脚本位于 OpenMentor\tools\windows_bundle\，源码 = ..\..
    $SourceDir = Resolve-Path (Join-Path $scriptDir "..\..")
}
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path (Split-Path -Parent $SourceDir) "dist"
}

# 从 README 或文件夹名推断版本号
$Version = "V1.x"
$readmePath = Join-Path $SourceDir "README.md"
if (Test-Path $readmePath) {
    $readmeContent = Get-Content $readmePath -Raw -Encoding UTF8
    if ($readmeContent -match "version-V([0-9]+\.[0-9]+\.[0-9]+)") {
        $Version = "V" + $matches[1]
    }
}

$BundleName = "OpenMentor_${Version}_Windows免安装包"
$BundleDir = Join-Path $OutputDir $BundleName
$EnvDir = Join-Path $BundleDir "env"
$CacheDir = Join-Path $scriptDir ".cache"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  OpenMentor Windows 免安装包 构建脚本" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  源码目录:   $SourceDir"
Write-Host "  Python 版本: $PythonVersion ($Arch)"
Write-Host "  版本号:     $Version"
Write-Host "  输出目录:   $BundleDir"
Write-Host "  打包 zip:   $ZipOutput"
Write-Host "  pip 镜像:   $(if ($UseTsinghua) { '清华' } else { '默认 (PyPI)' })"
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# ---------------- 0. 校验源码 ----------------
$requiredFiles = @("app.py", "requirements.txt", "OpenMentor启动器.bat", "openmentor_installer.py", "gui_launcher.py")
foreach ($f in $requiredFiles) {
    $p = Join-Path $SourceDir $f
    if (-not (Test-Path $p)) {
        Write-Host "[X] 源码缺少必要文件: $f" -ForegroundColor Red
        Write-Host "    路径: $p" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] 源码完整 (app.py, OpenMentor启动器.bat, ...)" -ForegroundColor Green

# ---------------- 1. 准备目录 ----------------
if (Test-Path $BundleDir) {
    Write-Host "[!] 输出目录已存在，将清空: $BundleDir" -ForegroundColor Yellow
    Remove-Item -Path $BundleDir -Recurse -Force
}
New-Item -ItemType Directory -Path $BundleDir | Out-Null
New-Item -ItemType Directory -Path $EnvDir | Out-Null
New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
Write-Host "[OK] 创建输出目录" -ForegroundColor Green

# ---------------- 2. 下载 Python embeddable ----------------
$embedZipName = "python-${PythonVersion}-embed-${Arch}.zip"
$embedZipUrl = "https://www.python.org/ftp/python/${PythonVersion}/${embedZipName}"
$embedZipPath = Join-Path $CacheDir $embedZipName

if (-not (Test-Path $embedZipPath)) {
    Write-Host "[-] 下载 Python ${PythonVersion} embeddable ($Arch)..." -ForegroundColor Yellow
    Write-Host "    $embedZipUrl"
    try {
        Invoke-WebRequest -Uri $embedZipUrl -OutFile $embedZipPath -UseBasicParsing
    } catch {
        Write-Host "[X] 下载失败: $_" -ForegroundColor Red
        Write-Host "    可手动下载到: $embedZipPath" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] Python embeddable: $embedZipPath ($('{0:N1}' -f ((Get-Item $embedZipPath).Length / 1MB)) MB)" -ForegroundColor Green

# ---------------- 3. 解压到 env\ ----------------
Write-Host "[-] 解压 Python embeddable 到 env\..." -ForegroundColor Yellow
Expand-Archive -Path $embedZipPath -DestinationPath $EnvDir -Force
Write-Host "[OK] env\python.exe 已就位" -ForegroundColor Green

# ---------------- 4. 修改 ._pth 启用 site-packages ----------------
# Python embeddable 默认禁用 site，需要解开 import site 注释才能用 pip 装的包
$pthFiles = Get-ChildItem -Path $EnvDir -Filter "python*._pth"
if ($pthFiles.Count -eq 0) {
    Write-Host "[X] 找不到 python*._pth 文件" -ForegroundColor Red
    exit 1
}
foreach ($pthFile in $pthFiles) {
    $content = Get-Content $pthFile.FullName -Raw
    # 取消 "#import site" 注释；并把 Lib\site-packages 加进来
    $content = $content -replace "#\s*import\s+site", "import site"
    if ($content -notmatch "Lib\\site-packages") {
        $content = $content.TrimEnd() + "`r`nLib\site-packages`r`n"
    }
    Set-Content -Path $pthFile.FullName -Value $content -Encoding ASCII
    Write-Host "[OK] 已启用 site-packages: $($pthFile.Name)" -ForegroundColor Green
}

# ---------------- 5. 安装 pip ----------------
$getPipPath = Join-Path $CacheDir "get-pip.py"
if (-not (Test-Path $getPipPath)) {
    Write-Host "[-] 下载 get-pip.py..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPipPath -UseBasicParsing
    } catch {
        Write-Host "[X] 下载失败: $_" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[-] 安装 pip..." -ForegroundColor Yellow
$envPython = Join-Path $EnvDir "python.exe"
& $envPython $getPipPath --no-warn-script-location
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] 安装 pip 失败" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] pip 已安装" -ForegroundColor Green

# ---------------- 6. 安装项目依赖 ----------------
$requirementsPath = Join-Path $SourceDir "requirements.txt"
Write-Host "[-] 安装项目依赖（首次约 3-8 分钟）..." -ForegroundColor Yellow
$pipArgs = @("-m", "pip", "install", "-r", $requirementsPath, "--no-warn-script-location")
if ($UseTsinghua) {
    $pipArgs += @("-i", "https://pypi.tuna.tsinghua.edu.cn/simple")
}
& $envPython @pipArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] 清华镜像失败，回退默认源..." -ForegroundColor Yellow
    & $envPython -m pip install -r $requirementsPath --no-warn-script-location
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[X] 依赖安装失败" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] 项目依赖安装完成" -ForegroundColor Green

# ---------------- 7. 复制源码（排除开发垃圾）----------------
Write-Host "[-] 复制 OpenMentor 源码..." -ForegroundColor Yellow
$excludePatterns = @(
    ".git", ".venv", "__pycache__", ".DS_Store",
    ".env",                          # 含 SECRET_KEY，每个用户应该自己生成
    "openmentor.db",                 # 含测试数据 / API Keys
    "static\uploads\openmentor\*",   # 测试上传
    "static\uploads\quickform\*",
    "static\uploads\*.html", "static\uploads\*.pdf", "static\uploads\*.docx",
    "static\reports\*",
    "tools\windows_bundle"           # 不打包打包工具自身
)

# 用 robocopy 复制（Windows 原生，比 Copy-Item 更稳定）
$robocopyArgs = @(
    $SourceDir, $BundleDir,
    "/E",                # 包含子目录
    "/NFL", "/NDL", "/NJH", "/NJS", "/NC", "/NS", "/NP",  # 安静模式
    "/XD", ".git", ".venv", "__pycache__", "tools",       # 排除目录
    "/XF", ".DS_Store", ".env", "openmentor.db"           # 排除文件
)
$rc = & robocopy @robocopyArgs
# robocopy 退出码 < 8 都算成功
if ($LASTEXITCODE -ge 8) {
    Write-Host "[X] robocopy 失败 (exit $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}

# 清理 dest 里的 uploads/reports 内容（保留 .gitkeep）
Get-ChildItem (Join-Path $BundleDir "static\uploads\openmentor") -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem (Join-Path $BundleDir "static\uploads\quickform") -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem (Join-Path $BundleDir "static\uploads") -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" } | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem (Join-Path $BundleDir "static\reports") -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "[OK] 源码已复制（已排除 .venv / .git / .env / db / uploads / reports）" -ForegroundColor Green

# ---------------- 8. 写入版本说明 ----------------
$versionInfo = @"
OpenMentor $Version Windows 免安装包

构建时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Python 版本：$PythonVersion ($Arch)
构建机器：$($env:COMPUTERNAME)

使用方法：
  双击 "OpenMentor启动器.bat" 即可。**无需预先安装 Python**。

文件夹结构：
  env\           嵌入式 Python（含全部依赖，约 200-250MB）
  app.py         主程序
  templates\     页面模板
  static\        前端静态资源
  start.bat / start.sh  命令行启动（备用）
  README.md / INSTALL.md / USAGE.md / NOTICE.md  文档
"@
Set-Content -Path (Join-Path $BundleDir "免安装包说明.txt") -Value $versionInfo -Encoding UTF8

# ---------------- 9. 验证 ----------------
Write-Host "[-] 验证嵌入式 Python 能 import flask..." -ForegroundColor Yellow
& $envPython -c "import flask; print('flask', flask.__version__)" 2>&1 | Out-Host
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] flask import 失败，依赖可能没装好" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] 验证通过" -ForegroundColor Green

# ---------------- 10. 大小统计 ----------------
$totalSize = (Get-ChildItem -Path $BundleDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
Write-Host ""
Write-Host "[OK] 包大小：$('{0:N1}' -f ($totalSize / 1MB)) MB" -ForegroundColor Green

# ---------------- 11. 打 zip ----------------
if ($ZipOutput) {
    $zipPath = Join-Path $OutputDir "${BundleName}.zip"
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Write-Host "[-] 打包成 zip..." -ForegroundColor Yellow
    Compress-Archive -Path "$BundleDir\*" -DestinationPath $zipPath -CompressionLevel Optimal
    $zipSize = (Get-Item $zipPath).Length
    Write-Host "[OK] zip 已生成: $zipPath ($('{0:N1}' -f ($zipSize / 1MB)) MB)" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  ✓ 构建完成！" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "免安装包目录: $BundleDir"
if ($ZipOutput) {
    Write-Host "压缩包:       $(Join-Path $OutputDir "${BundleName}.zip")"
}
Write-Host ""
Write-Host "下一步：进入免安装包目录，双击 OpenMentor启动器.bat 测试启动" -ForegroundColor Yellow
Write-Host ""
