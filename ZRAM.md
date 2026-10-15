# ZRAM setup

zram creates a compressed block device in RAM and uses it as swap. Pages that
would otherwise be paged out to a disk swapfile are compressed (zstd) and kept
in RAM, which is much faster and saves disk wear. On a desktop with lots of RAM
it is usually all you need — no swapfile or swap partition required.

This is the setup running on the desktop (`archlinux`) and is meant to be
reproducible on the laptop too. Both are CachyOS / Arch with systemd.

> **Two ways to apply this**
> - **Script:** `zram-setup` (in `~/.files/bin`, symlinked into `~/.local/bin`).
>   Idempotent, supports `--dry-run` / `--yes` / `--tune`.
> - **Manual:** follow the steps below.

---

## What is running now

| Item | Value |
|---|---|
| Package | `zram-generator` (official repo) |
| Config | `/etc/systemd/zram-generator.conf` |
| Device | `/dev/zram0`, size `ram / 2`, compression `zstd` |
| Swap priority | `100` (preferred over any disk swap) |
| Disk swap | none (`/etc/fstab` has no swap entry) |
| Sysctl | `vm.swappiness=100`, `vm.page-cluster=0` (CachyOS kernel defaults) |

Example output:

```console
$ zramctl
NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 zstd         15.5G   4K   64B   20K         [SWAP]

$ swapon --show
NAME       TYPE       SIZE USED PRIO
/dev/zram0 partition 15.5G   0B  100
```

---

## Quick way — the script

```bash
# preview everything it would do
zram-setup --dry-run

# apply (asks before installing / writing)
zram-setup

# unattended, and also drop an explicit sysctl tuning file
sudo zram-setup --yes --tune
```

The script:

1. installs `zram-generator` if missing,
2. writes `/etc/systemd/zram-generator.conf` (keeping a `.bak` if one exists),
3. applies the change **without a reboot** (swapoff → reset device →
   `systemctl daemon-reload` → restart `systemd-zram-setup@zram0.service`),
4. prints `zramctl` / `swapon --show` to verify.

It is safe to re-run; it only rewrites the config when it actually differs.

---

## Manual way (step by step)

### 1. Install the package

```bash
sudo pacman -S --needed zram-generator
```

### 2. Write the config

`/etc/systemd/zram-generator.conf`:

```ini
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
```

- `zram-size = ram / 2` scales automatically with the machine (≈16 GiB on the
  32 GiB desktop, less on the laptop) — same file works on both.
- `zstd` is a good default: fast and better ratio than `lzo-rle`. A swap device
  is written often, so `lzo-rle` is marginally faster at lower compression; use
  `zstd` unless you have a reason not to.

Other useful keys (optional):

```ini
swap-priority = 100          ; default; higher than any disk swap
zram-size = min(ram / 2, 8192)  ; cap at 8 GiB on very large machines
```

### 3. Enable / apply

`zram-generator` is a systemd **generator**: it reads the config at
`daemon-reload`/boot and creates `systemd-zram-setup@zram0.service` and
`dev-zram0.swap`. There is no service to enable.

To apply without rebooting:

```bash
# tear down the currently active zram (if any)
sudo swapoff /dev/zram0
sudo /usr/lib/systemd/system-generators/zram-generator --reset-device zram0

# re-read config and bring it up
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service
```

Or just **reboot** — that is the simplest path on a fresh install.

### 4. Verify

```bash
zramctl
swapon --show
systemctl status systemd-zram-setup@zram0.service --no-pager
```

You should see `/dev/zram0` formatted as swap with priority `100`.

---

## Optional tuning (`vm.swappiness`, `vm.page-cluster`)

With zram, the kernel is encouraged to *use* swap, so a **high** swappiness is
desirable. The CachyOS kernel already defaults to `vm.swappiness=100` and
`vm.page-cluster=0`; on a stock kernel these are `60` and `3`.

To make it explicit / portable, `zram-setup --tune` writes
`/etc/sysctl.d/99-zram.conf`:

```
vm.swappiness = 100
vm.page-cluster = 0
```

Apply it with:

```bash
sudo sysctl --system
```

> **Heads-up:** `INSTALL.md` §15 suggests `vm.swappiness=10` in
> `/etc/sysctl.d/99-sysctl.conf`. On this machine that file does **not** exist,
> and `swappiness=10` is the wrong direction for zram — it tells the kernel to
> avoid swap. If you ever add that file, drop the `vm.swappiness` line (or set it
> to `100`) when using zram.

### Advanced: reclaim tuning (only if you see thrashing)

When zram is nearly full and the system is under heavy memory pressure, the
kernel can enter *direct reclaim* and stall. Two knobs reduce that:

```
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
```

- `watermark_boost_factor = 0` disables the reclaim "boost" that otherwise
  makes kswapd reclaim earlier and more aggressively.
- `watermark_scale_factor = 125` (up from the default `10`) widens the gap
  between the watermark thresholds so kswapd keeps up before allocations have
  to stall.

`zram-setup --tune` deliberately writes **only** the safe baseline
(`swappiness`, `page-cluster`); apply these by hand if you need them:

```bash
sudo sysctl -w vm.watermark_boost_factor=0 vm.watermark_scale_factor=125
# to persist, add both lines to /etc/sysctl.d/99-zram.conf, then: sudo sysctl --system
```

> Only reach for these if you actually observe swap thrashing / reclaim stalls
> under load — at idle they change nothing, and with 32 GiB RAM and zram at
> `ram / 2` you likely never hit the condition. Measure first: watch
> `/proc/pressure/memory` and `vmstat`, or check for rising `pgmajfault` /
> `pgscan_direct`; optimize second.

---

## Caveats

- **Hibernation does not work with zram.** zram is volatile RAM, so there is
  nothing on disk to restore from. If you want hibernation (common on the
  laptop), keep a real swap partition/file at least as large as RAM **and** set
  `HibernateMode`/resume accordingly. zram can coexist with it:
  zram gets priority 100 and is used first, disk swap is the fallback. To keep
  zram as the only swap, leave `/etc/fstab` with no swap entry (as now).
- **RAM is the swap.** Don't size zram too large; `ram / 2` is a safe default.
  Sizing it near or above RAM risks the OOM killer when it fills up.
- **Reboot clears it.** That is expected, not data loss — swap holds no
  persistent data.

---

## Revert / uninstall

```bash
sudo swapoff /dev/zram0
sudo rm -f /etc/systemd/zram-generator.conf /etc/sysctl.d/99-zram.conf
sudo pacman -Rns zram-generator
sudo systemctl daemon-reload
```

---

## Laptop notes

The same config is used unchanged (`zram-size = ram / 2` adapts to whatever RAM
the laptop has). Two things to check on the laptop:

1. **Hibernation:** if you rely on it, add a disk swapfile and keep it lower
   priority than zram (default behaviour — zram uses priority 100). See
   `INSTALL-LAPTOP.md`.
2. **Verify after install:** run `zramctl` and `swapon --show` once, then again
   after a reboot, to confirm the generator picks up the config.
