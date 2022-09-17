# HandBrakeCLI

This educational document describes *hypothetical* use cases of `HandBrakeCLI` and `ffmpeg` and **does not** endorse the actual usage of these tools for copyright infringing activities. Beware of the legal implications that apply to your country.

---

Hate reading through the man pages?
Here's some examples of how these tools *could* be used :)

## Scan for titles

```batch
HandBrakeCLI.exe --scan --title l -i E:\
```

where `E:\` is the DVD / BluRay drive.

## Copy DVD movie and encode to mp4

- Runs `HandBrakeCLI` with _below normal_ priority to run in the background.
- Uses `HandBrake-check-fail.bat` to generate a pop-up error message to ensure you'll notice if anything goes wrong.
- After completion invokes powershell to show a success pop up, so you know when to insert a new DVD.

1. use scan command
2. place correct title in line 2 in below snippet
3. verify that image height matches preset (576p is normal for most DVDs)
	a. if necessary change preset (Super HQ is good quality and not _too_ slow, couple hours at max, remove "Super" if necessary)
4. select/enter audio tracks in line 3 (indices) and ansure the number of `--aencoder` parameters match. `faac` is fine.
5. select subtitles by index
6. specify input DVD drive (in this case `E:\`)
7. specify output file name

```batch
start /BELOWNORMAL /WAIT /b ^
	HandBrakeCLI.exe --title 1 --preset "Super HQ 576p25 Surround" --encoder x264 ^
	--audio 1,2,3,4 --aencoder faac,faac,faac,faac ^
	--subtitle 1,2,3,4,5,6,7,8,9,10,11,12,13,14 --markers --optimize ^
	--input E:\ --output "Some Movie (2048).mp4" & HandBrake-check-fail.bat && ^
start powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Yoooooo all done here :P', 'HandBrakeCLI done', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information);}"
```

## Copy DVD TV show and re-encode to mp4

Sequentially copies multiplie titles from a DVD as a background process and generates a pop up if anything goes wrong.

Parameters are the same as above.

Just add more lines for more titles.

No "Super HQ" here because it takes forever, but feel free to tweak the preset.

```batch
start /BELOWNORMAL /WAIT /b HandBrakeCLI.exe --title 3 --preset "HQ 576p25 Surround" --encoder x264 --audio 1,2 --aencoder faac,faac --subtitle 1,2,3,4,5 --markers --optimize --input E:\ --output "Some Show (2048) S07E21.mp4" & HandBrake-check-fail.bat && ^
start /BELOWNORMAL /WAIT /b HandBrakeCLI.exe --title 4 --preset "HQ 576p25 Surround" --encoder x264 --audio 1,2 --aencoder faac,faac --subtitle 1,2,3,4,5 --markers --optimize --input E:\ --output "Some Show (2048) S07E22.mp4" & HandBrake-check-fail.bat && ^
start /BELOWNORMAL /WAIT /b HandBrakeCLI.exe --title 5 --preset "HQ 576p25 Surround" --encoder x264 --audio 1,2 --aencoder faac,faac --subtitle 1,2,3,4,5 --markers --optimize --input E:\ --output "Some Show (2048) S07E23E24.mp4" & HandBrake-check-fail.bat && ^
start powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Yoooooo all done here :P', 'HandBrakeCLI done', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information);}"
```

## Split a double episode into single parts

This one uses `ffmpeg` :D
Will split all audio tracks and preserve subtitles.
Be sure to use the correct time spans after the `-ss` start time stamp in input.
Set the correct value for `-t` parameter (duration/length to copy).
Obviously tweak file names.

```batch
ffmpeg -i "Some Show (2048) S03E23E24.mp4" ^
	-map 0 -c:s copy -vcodec copy -acodec copy -ss 00:00:00 -t 00:39:59 "Some Show (2048) S03E23.mp4" ^
	-map 0 -c:s copy -vcodec copy -acodec copy -ss 00:39:59 "Some Show (2048) S03E24.mp4"
```

## Change priority of running HandBrakeCLI instance

... because finding it in the task manager can be a pain...

```batch
wmic process where name="HandBrakeCLI.exe" CALL setpriority "below normal"
```

## Re-encode and compress RAW BluRay title

`HQ 720p30 Surround` is fine enough, takes forever to encode to `Super HQ 720p30 Surround` or even `HQ 1080p60 Surround`.

Also BluRay subtitles can't be preserved (tho a single subtitle could be burnt in), cause BD subs are image-based (incompatible with soft subtitles in mp4).

Other parameters are the same.

```batch
start /BELOWNORMAL /WAIT /b HandBrakeCLI.exe --title 1 --preset "HQ 720p30 Surround" --encoder x264 ^
	--audio 1,3,4,5,6 --aencoder faac,faac,faac,faac,faac ^
	--markers --optimize --input "Movie_t00.mkv" ^
	--output "Movie.mp4" & HandBrake-check-fail.bat && ^
start powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Yoooooo all done here :P', 'HandBrakeCLI done', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information);}"
```

## Concatenate multiple mp4s to single mkv

It's `ffmpeg` so more parameters to tweak here.
Specify correct audio (`a`) and video (`v`) streams in `-filter_complex`

```batch
ffmpeg -i 1.mp4 -i 2.mp4 -i 3.mp4 ^
	-filter_complex "[0:v] [0:a] [1:v] [1:a] [2:v] [2:a] concat=n=3:v=1:a=1 [v] [a]" ^
	-map "[v]" -map "[a]" "Another Movie (2048) S01E04.mkv"
```