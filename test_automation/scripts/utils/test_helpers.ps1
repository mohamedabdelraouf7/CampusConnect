# Test Helper Functions for CampusConnect Test Automation

# Function to load test configuration
function Get-TestConfig {
    $configPath = Join-Path $PSScriptRoot "..\config\test_config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        return $config
    }
    throw "Test configuration file not found at: $configPath"
}

# Function to clean old logs
function Clear-OldLogs {
    param (
        [int]$RetentionDays = 7
    )
    $logDir = Join-Path $PSScriptRoot "..\logs"
    if (Test-Path $logDir) {
        $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
        Get-ChildItem $logDir | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -Recurse -Force
    }
}

# Function to check test prerequisites
function Test-Prerequisites {
    $prerequisites = @{
        "Flutter" = $false
        "ADB" = $false
        "Device" = $false
    }

    # Check Flutter
    try {
        $flutterVersion = flutter --version
        if ($flutterVersion -match "Flutter") {
            $prerequisites["Flutter"] = $true
        }
    } catch {
        Write-Warning "Flutter not found in PATH"
    }

    # Check ADB
    try {
        $adbVersion = adb version
        if ($adbVersion -match "Android Debug Bridge") {
            $prerequisites["ADB"] = $true
        }
    } catch {
        Write-Warning "ADB not found in PATH"
    }

    # Check connected devices
    $devices = Get-ConnectedDevices
    if ($devices.Count -gt 0) {
        $prerequisites["Device"] = $true
    } else {
        Write-Warning "No devices connected"
    }

    return $prerequisites
}

# Function to get test files based on configuration
function Get-TestFiles {
    param (
        [string]$Category
    )
    
    $config = Get-TestConfig
    $categoryConfig = $config.test_categories.$Category
    
    if (-not $categoryConfig.enabled) {
        return @()
    }

    $testFiles = @()
    foreach ($pattern in $categoryConfig.include_patterns) {
        $files = Get-ChildItem -Path $pattern -Recurse
        $testFiles += $files.FullName
    }

    foreach ($pattern in $categoryConfig.exclude_patterns) {
        $excludedFiles = Get-ChildItem -Path $pattern -Recurse
        $testFiles = $testFiles | Where-Object { $excludedFiles.FullName -notcontains $_ }
    }

    return $testFiles
}

# Function to generate test report
function New-TestReport {
    param (
        [string]$LogFile,
        [bool]$Success,
        [array]$TestResults
    )

    $report = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "success" = $Success
        "total_tests" = $TestResults.Count
        "passed_tests" = ($TestResults | Where-Object { $_.Success }).Count
        "failed_tests" = ($TestResults | Where-Object { -not $_.Success }).Count
        "test_details" = $TestResults
        "log_file" = $LogFile
    }

    $reportPath = Join-Path $PSScriptRoot "..\logs\test_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $report | ConvertTo-Json -Depth 10 | Set-Content $reportPath

    return $reportPath
}

# Function to check test coverage
function Test-Coverage {
    param (
        [string]$CoverageFile,
        [int]$Threshold
    )

    if (-not (Test-Path $CoverageFile)) {
        Write-Warning "Coverage file not found: $CoverageFile"
        return $false
    }

    $coverage = Get-Content $CoverageFile | ConvertFrom-Json
    $totalCoverage = $coverage.coverage.total_percentage

    if ($totalCoverage -ge $Threshold) {
        Write-Host "✅ Coverage threshold met: $totalCoverage% (threshold: $Threshold%)"
        return $true
    } else {
        Write-Warning "❌ Coverage threshold not met: $totalCoverage% (threshold: $Threshold%)"
        return $false
    }
}

# Export functions
Export-ModuleMember -Function @(
    'Get-TestConfig',
    'Clear-OldLogs',
    'Test-Prerequisites',
    'Get-TestFiles',
    'New-TestReport',
    'Test-Coverage'
) 