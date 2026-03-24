#!/usr/bin/env python3
"""Convert Summing iOS AIFF SFX to little-endian WAV for Flutter.

AIFF stores PCM as **big-endian**; standard WAV uses **little-endian**.
Copying frames without swapping causes noisy / distorted playback.
"""
from __future__ import annotations

import argparse
import audioop
import os
import sys
import wave

try:
    import aifc
except ImportError as e:
    print("Python aifc module required:", e, file=sys.stderr)
    sys.exit(1)


def convert_file(inp: str, outp: str) -> None:
    with aifc.open(inp, "r") as a:
        with wave.open(outp, "w") as w:
            w.setnchannels(a.getnchannels())
            w.setsampwidth(a.getsampwidth())
            w.setframerate(a.getframerate())
            raw = a.readframes(a.getnframes())
            sw = a.getsampwidth()
            if sw == 2:
                raw = audioop.byteswap(raw, 2)
            elif sw == 4:
                raw = audioop.byteswap(raw, 4)
            elif sw != 1:
                raise ValueError(f"Unsupported sample width: {sw}")
            w.writeframes(raw)


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("input_aif", help="Source .aif path")
    p.add_argument("output_wav", help="Destination .wav path")
    args = p.parse_args()
    os.makedirs(os.path.dirname(os.path.abspath(args.output_wav)) or ".", exist_ok=True)
    convert_file(args.input_aif, args.output_wav)
    print("Wrote", args.output_wav)


if __name__ == "__main__":
    main()
