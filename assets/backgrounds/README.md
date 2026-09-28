# Parallax backgrounds

The layer list lives at the top of `res://scripts/parallax_background.gd`.

To add a background layer:

1. Put a PNG, WebP, or SVG in this folder. Existing 960 × 540 assets work; transparent layers are scaled to the 540-pixel screen width and tiled vertically.
2. Open `parallax_background.gd`.
3. Copy one complete layer block inside `LAYER_CONFIGS`.
4. Change `layer`, `texture`, `speed`, and `opacity`.

Layer `1` is the farthest back. Larger numbers render closer to the player. The script sorts them automatically, so their physical order inside the array does not matter.

Use an opaque image for the farthest layer and transparent images for the layers above it. The farthest layer fills the portrait viewport; other layers repeat vertically. Make their top and bottom edges compatible when you want a perfectly seamless loop.
