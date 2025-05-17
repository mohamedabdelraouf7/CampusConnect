# Test Automation Script for CampusConnect
# This script automates the test execution process and generates logs

# Configuration
$LOG_DIR = "test_logs"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$LOG_FILE = "$LOG_DIR\test_run_$TIMESTAMP.log"
$TEST_OUTPUT_FILE = "$LOG_DIR\test_output_$TIMESTAMP.log"
$DEVICE_LOG_FILE = "$LOG_DIR\device_log_$TIMESTAMP.txt"
$FLUTTER_PATH = "C:\src\flutter\bin\flutter.bat"

# Create log directory if it doesn't exist
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null
    Write-Host "Created log directory: $LOG_DIR"
}

# Function to write to console and log file safely
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    
    try {
        # Use a mutex to prevent concurrent writes
        $mutex = New-Object System.Threading.Mutex($false, "Global\CampusConnectLogMutex")
        $mutex.WaitOne() | Out-Null
        try {
            Add-Content -Path $LOG_FILE -Value $logMessage -ErrorAction Stop
        }
        finally {
            $mutex.ReleaseMutex()
            $mutex.Dispose()
        }
    }
    catch {
        Write-Host "Warning: Could not write to log file: $_"
    }
}

# Function to write test output to a separate file
function Write-TestOutput {
    param($Output)
    try {
        Add-Content -Path $TEST_OUTPUT_FILE -Value $Output -ErrorAction Stop
    }
    catch {
        Write-Host "Warning: Could not write test output: $_"
    }
}

# Function to check if ADB is available
function Test-ADB {
    $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    if (Test-Path $adbPath) {
        try {
            $adbVersion = & $adbPath version
            Write-Log "ADB is available: $adbVersion"
            return $true
        }
        catch {
            Write-Log "ERROR: ADB is available but failed to run: $_"
            return $false
        }
    }
    else {
        Write-Log "ERROR: ADB not found at expected location: $adbPath"
        return $false
    }
}

# Function to get connected devices
function Get-ConnectedDevices {
    $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    $devices = & $adbPath devices | Select-Object -Skip 1 | Where-Object { $_ -match "device$" }
    return $devices
}

# Function to run tests on a specific device
function Run-TestsOnDevice {
    param($DeviceId)
    
    $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    Write-Log "Running tests on device: $DeviceId"
    
    # Clear device logs
    & $adbPath -s $DeviceId logcat -c
    Write-Log "Cleared device logs"
    
    # Start logging device output in background with a unique file
    $deviceLogFile = "$LOG_DIR\device_${DeviceId}_$TIMESTAMP.txt"
    $logcatProcess = Start-Process -FilePath $adbPath -ArgumentList "-s $DeviceId logcat" -RedirectStandardOutput $deviceLogFile -NoNewWindow -PassThru
    
    try {
        # Run Flutter tests
        Write-Log "Starting Flutter tests..."
        $testOutput = & $FLUTTER_PATH test --device-id=$DeviceId --coverage 2>&1
        
        # Write test output to separate file
        Write-TestOutput $testOutput
        Write-Log "Test Output:"
        Write-Log $testOutput
        
        # Generate coverage report
        if (Test-Path "coverage/lcov.info") {
            Write-Log "Generating coverage report..."
            & $FLUTTER_PATH pub run coverage:format_coverage --lcov --in=coverage/lcov.info --out=coverage/lcov.info --report-on=lib
        }
        
        # Check if tests passed
        if ($testOutput -match "All tests passed!") {
            Write-Log "✅ All tests passed successfully!"
            return $true
        }
        else {
            Write-Log "❌ Some tests failed. Check the log for details."
            return $false
        }
    }
    catch {
        Write-Log "ERROR: Test execution failed: $_"
        return $false
    }
    finally {
        # Stop logging and ensure process is terminated
        if ($logcatProcess -and -not $logcatProcess.HasExited) {
            Stop-Process -Id $logcatProcess.Id -Force -ErrorAction SilentlyContinue
            Write-Log "Stopped device logging"
        }
    }
}

# Main execution
Write-Log "Starting test automation script"
Write-Log "Log file: $LOG_FILE"
Write-Log "Device log file: $DEVICE_LOG_FILE"

# Check if ADB is available
if (-not (Test-ADB)) {
    Write-Log "Exiting due to ADB not being available"
    exit 1
}

# Get connected devices
$devices = Get-ConnectedDevices
if ($devices.Count -eq 0) {
    Write-Log "No devices connected. Please connect a device and try again."
    exit 1
}

Write-Log "Found $($devices.Count) connected device(s)"

# Run tests on each device
$allTestsPassed = $true
foreach ($device in $devices) {
    $deviceId = ($device -split "\s+")[0]
    Write-Log "Processing device: $deviceId"
    
    if (-not (Run-TestsOnDevice -DeviceId $deviceId)) {
        $allTestsPassed = $false
    }
}

# Generate summary
Write-Log "`n=== Test Run Summary ==="
Write-Log "Timestamp: $TIMESTAMP"
Write-Log "Devices tested: $($devices.Count)"
Write-Log "Overall status: $(if ($allTestsPassed) { '✅ PASSED' } else { '❌ FAILED' })"
Write-Log "Log files:"
Write-Log "- Test log: $LOG_FILE"
Write-Log "- Device log: $DEVICE_LOG_FILE"
Write-Log "=======================`n"

# Exit with appropriate status code
exit $(if ($allTestsPassed) { 0 } else { 1 }) 