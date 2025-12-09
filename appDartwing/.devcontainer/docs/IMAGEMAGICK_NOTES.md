ImageMagick Cheatsheet
======================

Environment
-----------
- ImageMagick 6.9.12-98 Q16 is preinstalled in the dev container.
- Main binaries: `convert`, `compare`, `identify`, `montage`. These are available on the `PATH`.
- Verify installation at any time with:
  ```
  convert -version
  ```

Core Commands
-------------
- Convert an image type or resize:
  ```
  convert input.png -resize 50% output.jpg
  ```
- Compare two images and generate a diff overlay:
  ```
  compare -metric AE baseline.png candidate.png diff.png
  ```
  - `-metric AE` reports the number of different pixels to stderr.
  - Use `-metric RMSE` for root-mean-square error instead.
- Inspect metadata quickly:
  ```
  identify -verbose image.png
  ```

Tips
----
- The `compare` command exits with a non-zero status when images differ; capture both stderr and exit code if using in scripts.
- When scripting, prefer quoting paths (`"path with spaces.png"`).
- For complex operations, `convert` arguments are processed left-to-right—order matters.
- The legacy `convert` executable is equivalent to `magick convert` on newer releases.

Further Reference
-----------------
- Official docs: https://imagemagick.org/script/command-line-processing.php
- Examples: https://imagemagick.org/Usage/
