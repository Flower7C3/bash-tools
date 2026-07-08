# Bash Tools

Collection of useful bash scripts for development and system administration.

## Scripts

### Development Tools

- `convert-jpg-mp4` - Convert JPG images to MP4 video
- `extract-mermaid` - Export Mermaid diagrams from Markdown to SVG/PNG
- `wordpress-update` - Update WordPress installations safely

### Network Tools

- `check-ssl` - Check SSL/TLS certificates
- `check-url` - Check HTTP status codes and redirects
- `check-redirects` - Validate URL redirects from a file
- `netcatchat` - Chat via netcat with shortcuts

### System Tools

- `backup-restore` - Backup and restore files and databases
- `download-map` - Download maps from GeoApify or OpenStreetMap
- `beeper` - Piano music player using system beep
- `crop-wallpaper` - Create wallpapers for vertical dual-screen layout

## Installation

### Full Installation

```bash
git clone https://github.com/Flower7C3/bash-tools.git
cd bash-tools
chmod +x *
```

### Single Script Download

You can download individual scripts directly:

```bash
# Download a single script
curl -fsSL https://raw.githubusercontent.com/Flower7C3/bash-tools/master/check-ssl -o check-ssl
chmod +x check-ssl

# Download with common-functions (required)
curl -fsSL https://raw.githubusercontent.com/Flower7C3/bash-tools/master/common-functions -o common-functions
```

**Note:** Scripts automatically download `common-functions` if not found locally.

## Usage

All scripts support `-h` or `--help` for usage information. Most scripts also support `-u` or `--update` to download the latest version:

```bash
./script-name --help
./script-name --update
```

## Requirements

- Bash 4.0+
- Common tools: curl, ffmpeg, git, etc. (see individual script requirements)
- `extract-mermaid`: Python 3, Node.js/npx, `@mermaid-js/mermaid-cli` (auto-installed via npx)
- `backup-restore`: `yq`, `rsync`, `ssh`, database client tools (see `backup-restore.yaml`)
