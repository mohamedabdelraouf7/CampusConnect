# Test Automation Script for CampusConnect
# This script automates the test execution process and generates logs

# Import helper functions
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptPath "utils\test_helpers.ps1")

# Load configuration
try {
    $config = Get-TestConfig
} catch {
    Write-Error "Failed to load test configuration: $_"
    exit 1
}

# Setup logging
$LOG_DIR = Join-Path $scriptPath "..\logs"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$LOG_FILE = Join-Path $LOG_DIR "test_run_$TIMESTAMP.log"
$DEVICE_LOG_FILE = Join-Path $LOG_DIR "device_log_$TIMESTAMP.txt"
$COVERAGE_DIR = Join-Path $LOG_DIR "coverage_$TIMESTAMP"

# Create log directory if it doesn't exist
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
    Write-Host "Created log directory: $LOG_DIR"
}

# Function to write to both console and log file
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Only log if level is appropriate
    $logLevels = @{ "DEBUG" = 0; "INFO" = 1; "WARNING" = 2; "ERROR" = 3 }
    if ($logLevels[$Level] -ge $logLevels[$config.test_settings.log_level]) {
        Write-Host $logMessage
        Add-Content -Path $LOG_FILE -Value $logMessage
    }
}

# Main execution
Write-Log "Starting test automation script" "INFO"
Write-Log "Log file: $LOG_FILE" "INFO"
Write-Log "Device log file: $DEVICE_LOG_FILE" "INFO"

# Check prerequisites
$prerequisites = Test-Prerequisites
if (-not ($prerequisites.Values -contains $false)) {
    Write-Log "All prerequisites met" "INFO"
} else {
    Write-Log "Some prerequisites are not met. Please check the warnings above." "ERROR"
    exit 1
}

# Clean old logs
Clear-OldLogs -RetentionDays $config.logging.log_retention_days

# Get connected devices
$devices = Get-ConnectedDevices
if ($devices.Count -eq 0) {
    Write-Log "No devices connected. Please connect a device and try again." "ERROR"
    exit 1
}

Write-Log "Found $($devices.Count) connected device(s)" "INFO"

# Initialize test results
$testResults = @()
$allTestsPassed = $true

# Run tests for each category
$categories = @("unit", "widget", "integration")
foreach ($category in $categories) {
    if ($config.test_settings."run_${category}_tests") {
        Write-Log "Running $category tests..." "INFO"
        
        $testFiles = Get-TestFiles -Category $category
        if ($testFiles.Count -eq 0) {
            Write-Log "No $category test files found" "WARNING"
            continue
        }

        foreach ($device in $devices) {
            $deviceId = ($device -split "\s+")[0]
            Write-Log "Running tests on device: $deviceId" "INFO"
            
            # Clear device logs
            adb -s $deviceId logcat -c
            Write-Log "Cleared device logs" "DEBUG"
            
            # Start logging device output in background
            $logcatProcess = Start-Process -FilePath "adb" -ArgumentList "-s $deviceId logcat" -RedirectStandardOutput $DEVICE_LOG_FILE -NoNewWindow -PassThru
            
            try {
                # Run Flutter tests for this category
                $testOutput = flutter test --device-id=$deviceId --coverage $testFiles 2>&1
                
                # Write test output to log
                Write-Log "Test Output for $category tests:" "INFO"
                Write-Log $testOutput "INFO"
                
                # Check if tests passed
                if ($testOutput -match "All tests passed!") {
                    Write-Log "✅ All $category tests passed successfully!" "INFO"
                    $testResults += @{
                        "category" = $category
                        "device" = $deviceId
                        "success" = $true
                        "output" = $testOutput
                    }
                } else {
                    Write-Log "❌ Some $category tests failed. Check the log for details." "ERROR"
                    $testResults += @{
                        "category" = $category
                        "device" = $deviceId
                        "success" = $false
                        "output" = $testOutput
                    }
                    $allTestsPassed = $false
                }
                
                # Generate coverage report if enabled
                if ($config.test_settings.generate_coverage -and (Test-Path "coverage/lcov.info")) {
                    Write-Log "Generating coverage report..." "INFO"
                    $coverageOutput = flutter pub run coverage:format_coverage --lcov --in=coverage/lcov.info --out="$COVERAGE_DIR/lcov.info" --report-on=lib
                    Write-Log $coverageOutput "DEBUG"
                    
                    # Check coverage threshold
                    Test-Coverage -CoverageFile "$COVERAGE_DIR/lcov.info" -Threshold $config.test_settings.coverage_threshold
                }
            }
            catch {
                Write-Log "ERROR: Test execution failed: $_" "ERROR"
                $testResults += @{
                    "category" = $category
                    "device" = $deviceId
                    "success" = $false
                    "error" = $_.Exception.Message
                }
                $allTestsPassed = $false
            }
            finally {
                # Stop logging
                Stop-Process -Id $logcatProcess.Id -Force
                Write-Log "Stopped device logging" "DEBUG"
            }
        }
    }
}

# Generate test report
$reportPath = New-TestReport -LogFile $LOG_FILE -Success $allTestsPassed -TestResults $testResults

# Generate summary
Write-Log "`n=== Test Run Summary ===" "INFO"
Write-Log "Timestamp: $TIMESTAMP" "INFO"
Write-Log "Devices tested: $($devices.Count)" "INFO"
Write-Log "Overall status: $(if ($allTestsPassed) { '✅ PASSED' } else { '❌ FAILED' })" "INFO"
Write-Log "Log files:" "INFO"
Write-Log "- Test log: $LOG_FILE" "INFO"
Write-Log "- Device log: $DEVICE_LOG_FILE" "INFO"
Write-Log "- Test report: $reportPath" "INFO"
if ($config.test_settings.generate_coverage) {
    Write-Log "- Coverage report: $COVERAGE_DIR" "INFO"
}
Write-Log "=======================`n" "INFO"

# Exit with appropriate status code
exit $(if ($allTestsPassed) { 0 } else { 1 }) 