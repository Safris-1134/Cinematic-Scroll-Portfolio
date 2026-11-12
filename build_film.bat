@echo off
setlocal enabledelayedexpansion

where ffmpeg >nul 2>&1 || (echo ffmpeg not found on PATH & exit /b 1)
where ffprobe >nul 2>&1 || (echo ffprobe not found on PATH & exit /b 1)

rem Measured watermark boxes (1920x1080 source):
rem - clips 1,2,5: "Veo" at x=1865, y=1042, w=31, h=14 -> padded delogo 1860,1037,41,24
rem - clip 6: double "Veo" at x=1864, y=1042, w=48, h=26 -> padded delogo 1860,1037,56,35
rem - clips 3,4: Gemini sparkle at x=1704, y=864, w=72, h=72 -> padded delogo 1702,862,76,76
set VEO_X=1860
set VEO_Y=1037
set VEO_W=41
set VEO_H=24
set VEO6_W=56
set VEO6_H=35
set STAR_X=1702
set STAR_Y=862
set STAR_W=76
set STAR_H=76

echo Watermarks -^> Veo(1,2,5): %VEO_X%,%VEO_Y%,%VEO_W%x%VEO_H% ^| Veo(6): %VEO_X%,%VEO_Y%,%VEO6_W%x%VEO6_H% ^| Star(3,4): %STAR_X%,%STAR_Y%,%STAR_W%x%STAR_H%

rem Compute exact 24fps frame-aligned xfade offsets from video stream frame counts (audio tracks are slightly longer)
set /a CUM=0
for /l %%i in (1,1,5) do (
  set "N="
  for /f %%f in ('ffprobe -v error -select_streams v:0 -show_entries stream^=nb_frames -of csv^=p^=0 "clips\clip%%i.mp4"') do set "N=%%f"
  if not defined N (echo Failed to probe clips\clip%%i.mp4 & exit /b 1)
  set /a "CUM+=N-6"
  set /a "SEC=CUM/24, R=CUM%%24, US=(R*1000000+12)/24"
  set "US=000000!US!"
  set "O%%i=!SEC!.!US:~-6!"
)

if not exist site\media mkdir site\media

ffmpeg -y ^
  -i clips\clip1.mp4 ^
  -i clips\clip2.mp4 ^
  -i clips\clip3.mp4 ^
  -i clips\clip4.mp4 ^
  -i clips\clip5.mp4 ^
  -i clips\clip6.mp4 ^
  -filter_complex "[0:v]delogo=x=%VEO_X%:y=%VEO_Y%:w=%VEO_W%:h=%VEO_H%[v0];[1:v]delogo=x=%VEO_X%:y=%VEO_Y%:w=%VEO_W%:h=%VEO_H%[v1];[2:v]delogo=x=%STAR_X%:y=%STAR_Y%:w=%STAR_W%:h=%STAR_H%[v2];[3:v]delogo=x=%STAR_X%:y=%STAR_Y%:w=%STAR_W%:h=%STAR_H%[v3];[4:v]delogo=x=%VEO_X%:y=%VEO_Y%:w=%VEO_W%:h=%VEO_H%[v4];[5:v]delogo=x=%VEO_X%:y=%VEO_Y%:w=%VEO6_W%:h=%VEO6_H%[v5];[v0][v1]xfade=transition=fade:duration=0.25:offset=%O1%[x1];[x1][v2]xfade=transition=fade:duration=0.25:offset=%O2%[x2];[x2][v3]xfade=transition=fade:duration=0.25:offset=%O3%[x3];[x3][v4]xfade=transition=fade:duration=0.25:offset=%O4%[x4];[x4][v5]xfade=transition=fade:duration=0.25:offset=%O5%[x5];[x5]colorlevels=rimin=0.045:gimin=0.045:bimin=0.045,format=yuv420p[vout]" ^
  -map "[vout]" -an -c:v libx264 -crf 17 -pix_fmt yuv420p -movflags +faststart film_master.mp4
if errorlevel 1 exit /b 1

ffmpeg -y -i film_master.mp4 -vf "unsharp=3:3:0.25:3:3:0.0" -an -c:v libx264 -profile:v high -level 4.1 -g 1 -crf 21 -pix_fmt yuv420p -movflags +faststart site\media\film.mp4
if errorlevel 1 exit /b 1

ffmpeg -y -i film_master.mp4 -vf "scale=1280:-2,unsharp=3:3:0.25:3:3:0.0" -an -c:v libx264 -profile:v high -level 4.0 -g 1 -crf 23 -pix_fmt yuv420p -movflags +faststart site\media\film_mobile.mp4
if errorlevel 1 exit /b 1

ffmpeg -y -i film_master.mp4 -frames:v 1 -q:v 2 -update 1 site\media\poster.jpg
if errorlevel 1 exit /b 1
