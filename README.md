# Bash Tools

Collection of useful bash scripts for development and system administration.

## Scripts

### Development Tools

- `not-on-base` - What is not on base (commits, topic branches, open PRs). Text on stdout; `--out file.md` for Markdown. Uses `gh` when logged in.
- `convert-jpg-mp4` - Convert JPG images to MP4 video
- `extract-mermaid` - Export Mermaid diagrams from Markdown to SVG/PNG
- `wordpress-update` - Update WordPress installations safely

### Network Tools

- `check-ssl` - Check SSL/TLS certificates
- `check-url` - Check HTTP status codes and redirects
- `check-redirects` - Validate URL redirects from a file
- `netcatchat` - Chat via netcat with shortcuts
- `network-scan` - Scan local subnets and update a MAC/IP inventory TSV (vendor from IEEE OUI, device type from `--identify` port/HTTP/SSDP probes); `-i/--identify` on its own describes only the devices listed in the file, `-n/--network` sweeps and appends, `-m/--mac` refreshes IPs from ARP; repairs malformed MAC addresses, fills in missing MACs from the observed network, corrects typos against live devices, and lists detected services per device, marks devices `online`/`offline`/`new`, appends unknown devices to the output, and writes a Markdown report with Mermaid pie charts and a topology diagram laid out as one column per device category (gateways first, IoT last, offline devices dashed) plus per-section CSVs via `--csv-dir`

### System Tools

- `backup-restore` - Backup and restore files and databases
- `download-map` - Download maps from GeoApify or OpenStreetMap
- `geocode-addresses` - Resolve addresses from a CSV or CLI to latitude/longitude
- `generate-map` - Build a GeoApify map with 2-letter marker labels from CSV coordinates
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
- `geocode-addresses`, `generate-map`: Python 3, `curl`; GeoApify API key (`--api-key` or `GEOAPIFY_API_KEY`)
- `download-map`: `curl`; OSM also needs `bc` and ImageMagick (`magick`)
- `network-scan`: Python 3, `curl`, `ping`, `arp` (`ip` on Linux); `--network` re-execs with `sudo` unless `--no-sudo`; writes the OUI cache to `~/.cache/bash-tools/oui`; never flushes the ARP cache unless `--flush-arp`; report diagrams need a Mermaid renderer (GitHub, VS Code, Obsidian, `mermaid-cli`)
