```bash
swift run -c release && ffmpeg -i ./ppm/%d.ppm ./out/%04d.png -y
```