# ZED FTP Extension

A File Transfer Protocol (FTP) extension for the ZED editor, enabling direct integration with FTP servers for seamless remote file operations.

## Features

- Connect to FTP servers directly from ZED
- Browse remote directories
- Download and upload files
- Edit remote files locally with automatic synchronization
- Secure FTP connections (FTPS) support
- Multiple server profiles support

## Installation

### From ZED Extension Market

1. Open ZED editor
2. Open the Extensions panel (View -> Extensions)
3. Search for "FTP"
4. Click "Install"

### Manual Installation

1. Clone this repository:
   ```
   git clone https://github.com/username/zed_ftp
   ```

2. Build the extension:
   ```
   cd zed_ftp
   cargo build --release
   ```

3. Copy the compiled extension to your ZED extensions directory:
   ```
   cp target/release/libzed_ftp.so ~/.config/zed/extensions/zed_ftp/
   ```
   (Path may vary depending on your operating system)

## Configuration

Configure the extension through the ZED settings:

```json
{
  "extensions": {
    "zed_ftp": {
      "host": "ftp.example.com",
      "port": 21,
      "username": "your_username",
      "password": "your_password", 
      "initialDirectory": "/public_html"
    }
  }
}
```

**Security Note**: Storing passwords in plain text is not recommended. Consider using environment variables or a keychain solution for passwords.

## Usage

### Commands

All commands are available through the Command Palette (Cmd/Ctrl+Shift+P):

- `FTP: Connect to Server` - Connect to the configured FTP server
- `FTP: Disconnect` - Disconnect from the current FTP server
- `FTP: List Directory` - Show files in the current remote directory
- `FTP: Download File` - Download the selected remote file
- `FTP: Upload File` - Upload the current file to the remote server
- `FTP: Change Directory` - Navigate to a different remote directory

### Workflow

1. Configure your FTP connection settings
2. Connect to the server using the `FTP: Connect to Server` command
3. Browse remote files with the `FTP: List Directory` command
4. Download files to edit them locally
5. Upload modified files back to the server

## Development

### Prerequisites

- Rust toolchain (1.65+)
- ZED editor

### Building

```
cargo build
```

### Testing

```
cargo test
```

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [ ] SFTP support
- [ ] Multi-server management
- [ ] File synchronization between local and remote
- [ ] Progress indicators for file transfers
- [ ] Directory comparison tools

## Acknowledgements

- [Rust-FTP](https://github.com/mattnenterprise/rust-ftp) - The FTP library used in this extension
- [ZED Editor](https://zed.dev/) - The amazing editor this extension is built for