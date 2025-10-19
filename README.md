# Bash Tools

Collection of useful bash scripts for development and system administration.

## Scripts

### Development Tools

- `jpg-to-mp4` - Convert JPG images to MP4 video
- `wordpress-update` - Update WordPress installations safely

### Network Tools

- `ssl-check` - Check SSL/TLS certificates
- `url-status-check` - Check HTTP status codes and redirects
- `redirects-check` - Validate URL redirects from file
- `netcatchat` - Chat via netcat with shortcuts

### System Tools

- `map-download` - Download maps from GeoApify or OpenStreetMap
- `beeper` - Piano music player using system beep
- `wallpaper-crop` - Automatic creation of wallpapers for vertical layout with aligned centers

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
curl -fsSL https://raw.githubusercontent.com/Flower7C3/bash-tools/master/ssl-check -o ssl-check
chmod +x ssl-check

# Download with common-functions (required)
curl -fsSL https://raw.githubusercontent.com/Flower7C3/bash-tools/master/common-functions -o common-functions
```

**Note:** Scripts automatically download `common-functions` if not found locally.

## Usage

All scripts support `-h` or `--help` for usage information:

```bash
./script-name --help
```

## Requirements

- Bash 4.0+
- Common tools: curl, ffmpeg, git, etc. (see individual script requirements)