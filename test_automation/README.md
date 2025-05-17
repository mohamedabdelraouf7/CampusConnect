# CampusConnect Test Automation

This directory contains automated test scripts for the CampusConnect app. The scripts handle test execution, logging, and reporting.

## Directory Structure

```
test_automation/
├── README.md                 # This file
├── scripts/                  # Test automation scripts
│   ├── run_tests.ps1        # Main PowerShell test script
│   ├── run_tests.bat        # Windows batch file for easy execution
│   └── utils/               # Utility scripts
│       └── test_helpers.ps1 # Helper functions for test automation
├── config/                   # Configuration files
│   └── test_config.json     # Test configuration settings
└── logs/                    # Test logs directory (created automatically)
```

## Prerequisites

- Windows 10 or later
- PowerShell 5.1 or later
- Flutter SDK
- Android SDK with ADB in PATH
- Connected Android device(s) or emulator(s)

## Quick Start

1. Double-click `scripts/run_tests.bat` to run all tests
2. Or run from command prompt:
   ```cmd
   cd test_automation
   .\scripts\run_tests.bat
   ```

## Test Logs

Test logs are stored in the `logs` directory with timestamps:
- `logs/test_run_YYYYMMDD_HHMMSS.log` - Main test execution log
- `logs/device_log_YYYYMMDD_HHMMSS.txt` - Device logs
- `logs/coverage_YYYYMMDD_HHMMSS/` - Test coverage reports

## Configuration

Edit `config/test_config.json` to customize test settings:
- Test categories to run
- Log verbosity
- Device selection
- Coverage settings

## Adding New Tests

1. Place new test files in the appropriate test directory:
   - Unit tests: `test/unit/`
   - Widget tests: `test/widget/`
   - Integration tests: `test/integration/`

2. The test automation script will automatically discover and run all tests.

## Troubleshooting

If you encounter issues:
1. Check that ADB is in your PATH
2. Verify device connection with `adb devices`
3. Check the logs in the `logs` directory
4. Ensure Flutter SDK is properly installed 