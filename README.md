# Cinematic Scroll Portfolio

An interactive, scroll-driven studio film portfolio for **Mohamed Safris S** (Full Stack Engineer & Web Specialist), combining frame-accurate HTML5 video scrubbing with synchronized chapters, glassmorphic UI panels, and responsive desktop/mobile video streams.

**Live Site:** https://mohamed-safris.vercel.app

## Highlights

- **Scroll-Driven Studio Film:** All-keyframe (`-g 1`) MP4 encoding (`site/media/film.mp4` for desktop, `site/media/film_mobile.mp4` for mobile) for smooth bidirectional scrubbing synced to scroll progress.
- **Interactive Chapter Sections:** Intro, About, Work, Skills, Resume (with PDF download), Contact, and Finale, navigable via scroll, top navigation bar, or side chapter rail.
- **Zero-Build Static Architecture:** Built with vanilla HTML, CSS, and JavaScript (`site/index.html`, `site/style.css`, `site/app.js`, `site/config.js`) for instant loading and direct deployment on Vercel.
- **Reproducible Video Pipeline:** `build_film.sh` and `build_film.bat` stitch and process the 6-clip source sequence in `clips/` into `film_master.mp4` and the web-optimized all-keyframe outputs.

## Project Structure

```text
.
├── site/                  # Production static web application (deployed to Vercel)
│   ├── index.html
│   ├── style.css
│   ├── app.js
│   ├── config.js          # Portfolio content, projects, skills, experience & links
│   ├── favicon.svg
│   └── media/
│       ├── film.mp4       # Desktop all-keyframe film
│       ├── film_mobile.mp4# Mobile (1280px) all-keyframe film
│       ├── poster.jpg
│       └── resume.pdf
├── clips/                 # Source video clips (clip1.mp4 - clip6.mp4)
├── film_master.mp4        # Master stitched 24fps film
├── build_film.sh          # Linux/macOS FFmpeg build pipeline
└── build_film.bat         # Windows FFmpeg build pipeline
```

## Local Preview

Serve the `site/` directory with any static file server (e.g., VS Code Live Server, `npx serve site`, or `python -m http.server 8000 --directory site`).

