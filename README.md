# aisis-station-kit

The patch AISIS applies to [krevetkqqq/lite-kit](https://github.com/krevetkqqq/lite-kit) (eQuasar: a local
stand-in for the `quasar.yandex.net` sync endpoint of a rooted Yandex Station Mini). AISIS runs it as
`aisis-station-kit.service` (HTTP `:18080`, HTTPS `:18443`).

This repository does **not** mirror lite-kit. lite-kit tracks key and certificate material in its own tree, so
this repository carries only our change as a patch on a pinned upstream commit, plus the script that applies it.

## Upstream and license

- Upstream: <https://github.com/krevetkqqq/lite-kit>, base commit `8a82ff32d75ea27b2604685671a6647ca625bf10`
  (2026-10-31, merge of PR #11). The patch also applies cleanly to the later upstream `main`
  (`65ae152`, only `start.sh` changed upstream since).
- License: MIT, Copyright (c) 2026 krevetkqqq (`LICENSE`, copied from upstream). The patch is published under the
  same MIT license. See `NOTICE`.

## What the patch changes (`scripts/equasar_server.py`, +65 / −4)

- The sync answer is served from the local template by default (`SYNC_LOCAL` now defaults to on). Requests to Yandex
  servers are disabled outright: `_upstream` raises at its first line, so there is **no** switch that brings the upstream
  behaviour back (`SYNC_LOCAL=0`, `MODE_PASSTHROUGH`, `MODE_OTA_ONLY` no longer reach Yandex). `77.88.8.8` (Yandex DNS) is
  replaced by `9.9.9.9` in `DNS_UPSTREAMS`.
- `_inject_spotters`: enables the speaker's command spotter groups and the always-on microphone for shortcuts
  («включи свет», «тише», «дальше» without the wake word) in every sync answer, because the speaker rewrites
  `user_config.dat` from the sync answer.
- Dashboard settings overlay: `~/.config/aisis-yandex/speaker-sync-overlay.json` (or `AISIS_SYNC_OVERLAY`) is
  merged over the sync answer on every request; any read error serves the answer unchanged.

## Apply

```sh
./apply.sh DEST          # clones upstream at the pinned commit into DEST and applies patches/*.patch
./apply.sh DEST <rev>    # another upstream revision
```

The result is the tree AISIS runs; `BIND_IP` and the ports are set by the service unit.

## Known issues of the patch (it is published exactly as it runs)

Found by an automated review, not yet changed because the file must stay identical to the running service until a fix is
deployed; tracked in alex-mextner/aisis#189:

- `_upstream` raises `ConnectionError` where upstream returned `(None, b"")` on failure; a caller that checks the return value
  instead of catching the exception would drop the connection (not verified against every caller).
- If the settings overlay cannot be read, it is ignored whole, so an owner's «microphone off» setting falls back to the
  injected `alwaysOnMicForShortcuts: true`; a lone surrogate or `NaN` in the overlay can fail the final `json.dumps`/`encode`
  outside the `try`.

## Contributing

Patch changes go in as a new numbered file in `patches/` (`git apply --check` clean on the pinned base).
CI applies the series to the pinned commit and byte-compiles the script.
