# VT-QuickCheck

**Windows URL Security Checker using VirusTotal API v3**

VT-QuickCheck is a lightweight Windows utility that checks website URLs using the VirusTotal API v3.

Built with Batch and PowerShell, it retrieves URLs directly from the Windows clipboard, submits them for analysis, monitors the processing status and displays the security detection statistics.

No Python installation or additional libraries required.

## Features

- Automatic URL extraction from the clipboard.
- Integration with VirusTotal API v3.
- Automatic submission of URLs for analysis.
- Analysis status monitoring.
- Detection statistics (malicious, suspicious, harmless and undetected).
- Automatic verdict classification.
- Error handling and timeout protection.
- Lightweight execution using native Windows tools.

## Requirements

- Windows 10 or Windows 11.
- Internet connection.
- PowerShell.
- A VirusTotal API key.

## Installation

1. Download or clone this repository.
2. Open the project folder.
3. Copy `config.example.bat`.
4. Rename the copied file to `config.bat`.
5. Open `config.bat` with a text editor.
6. Replace `COLOQUE_SUA_CHAVE_AQUI` with your personal VirusTotal API key.
7. Save the file.

**Important:** Never publish your personal API key. The `config.bat` file is excluded from Git through `.gitignore`.

## Usage

1. Copy a website URL to the Windows clipboard using `Ctrl + C`.
2. Run `VT-QuickCheck.bat`.
3. The program automatically retrieves the copied URL.
4. Wait for VirusTotal to process the analysis.
5. Review the detection statistics and final verdict.

## Detection Results

| Result | Meaning |
|---|---|
| Malicious | One or more security engines detected malicious content. |
| Suspicious | One or more engines classified the URL as suspicious. |
| No malicious detections | No malicious or suspicious detections were reported. |
| Pending | VirusTotal has not completed the analysis. |
| Inconclusive | No sufficient classification was available. |

**Security notice:** A result with zero malicious detections does not guarantee that a website is safe. VirusTotal aggregates results from multiple security engines, and detection results may change over time.

## Project Structure

```text
VT-QuickCheck/
│
├── VT-QuickCheck.bat
├── config.example.bat
├── .gitignore
├── README.md
└── LICENSE
```

The local `config.bat` file is intentionally excluded from the repository.

## Technologies

- Windows Batch
- Windows PowerShell
- VirusTotal REST API v3
- JSON
- HTTP/HTTPS

## Disclaimer

This project is intended for educational and informational purposes.

VT-QuickCheck is not a substitute for comprehensive cybersecurity analysis. The developer does not guarantee the safety of any website based on VirusTotal results.

Users are responsible for obtaining and configuring their own API keys and complying with VirusTotal's terms of service.

## License

This project is distributed under the MIT License. See the `LICENSE` file for details.
