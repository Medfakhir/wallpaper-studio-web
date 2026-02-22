# Wallpaper Studio Web - Flutter Edition

Professional web-based wallpaper editor built with Flutter Web. Creates depth effect live wallpapers with **100% rendering compatibility** with the mobile app.

## 🎯 Why Flutter Web?

This app is built with **Flutter Web (Dart)** instead of Next.js/TypeScript to ensure:
- ✅ **Identical rendering** - Uses the EXACT same code as the mobile app
- ✅ **100% compatibility** - Wallpapers look identical on web and mobile
- ✅ **Shared codebase** - 90% of code is shared with mobile app
- ✅ **No conversion issues** - Same Canvas API, same fonts, same effects

## 🚀 Features

### Editor
- ✅ Live wallpaper preview (1080×1920 resolution)
- ✅ Real-time clock updates
- ✅ Drag-and-drop positioning (coming soon)
- ✅ Image upload (background + foreground)
- ✅ 21+ Google Fonts (same as mobile)

### Clock Customization
- ✅ Font selection
- ✅ Size and opacity controls
- ✅ Color picker
- ✅ Layouts: Normal, Vertical, Split
- ✅ Text effects: Stroke, Shadow
- ✅ Gradient support (coming soon)

### Export
- ✅ Export as JSON (mobile-ready format)
- ✅ Export as PNG image (1080×1920)
- ✅ Compatible with mobile app

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Chrome/Edge browser for development

### Setup
```bash
# Install dependencies
flutter pub get

# Run in development mode
flutter run -d chrome

# Build for production
flutter build web --release
```

## 🎨 Usage

### 1. Upload Images
- Click "Upload Background" to add your wallpaper background
- Click "Upload Foreground" to add depth layer (optional)

### 2. Customize Clock
- Choose font from 21+ options
- Adjust size, opacity, and color
- Select layout (Normal, Vertical, Split)
- Add effects (stroke, shadow)

### 3. Export
- Click "Export JSON" to download configuration
- Click "Export Image" to download rendered wallpaper
- Use JSON in mobile app for perfect compatibility

## 🔧 Development

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/
│   └── wallpaper_model.dart     # Shared with mobile app
├── screens/
│   └── editor_screen.dart       # Main editor
└── widgets/
    └── wallpaper_painter.dart   # Rendering logic (shared with mobile)
```

### Shared Code
These files are **identical** to the mobile app:
- `models/wallpaper_model.dart` - Data models
- `widgets/wallpaper_painter.dart` - Rendering logic

This ensures 100% compatibility!

## 🌐 Deployment

### Build for Production
```bash
flutter build web --release
```

### Deploy to Hosting
The `build/web` folder can be deployed to:
- **Firebase Hosting**
  ```bash
  firebase deploy
  ```
- **Vercel**
  ```bash
  vercel --prod
  ```
- **Netlify**
  - Drag and drop `build/web` folder
- **GitHub Pages**
  ```bash
  # Copy build/web contents to gh-pages branch
  ```

## 📱 Mobile App Integration

### Export Format
The web app exports JSON in this format:
```json
{
  "id": "wall_001",
  "category": "Custom",
  "assets": {
    "background": "https://your-image-url.jpg",
    "foreground": "https://your-image-url.png"
  },
  "clock": {
    "enabled": true,
    "font": "BebasNeue",
    "sizeRatio": 0.23,
    "position": { "x": 0.08, "y": 0.55 },
    ...
  },
  ...
}
```

### Load in Mobile App
1. Upload JSON to JSONKeeper.com or GitHub Gist
2. Update `WallpaperService._remoteJsonUrl` in mobile app
3. App loads wallpapers automatically
4. Wallpapers render **identically** to web preview!

## 🎯 Rendering Compatibility

### Web App (Flutter Web)
```dart
// Uses Flutter Canvas API
CustomPaint(
  painter: WallpaperPainter(
    config: config,
    backgroundImage: image,
    currentTime: DateTime.now(),
  ),
)
```

### Mobile App (Flutter)
```dart
// Uses SAME Flutter Canvas API
CustomPaint(
  painter: WallpaperPainter(  // SAME CODE!
    config: config,
    backgroundImage: image,
    currentTime: DateTime.now(),
  ),
)
```

**Result:** 100% identical rendering! ✅

## 🔥 Advantages Over Next.js Version

| Feature | Next.js (Old) | Flutter Web (New) |
|---------|---------------|-------------------|
| **Rendering** | HTML Canvas | Flutter Canvas (same as mobile) |
| **Compatibility** | ~85% match | 100% match ✅ |
| **Code Sharing** | 0% | 90% ✅ |
| **Maintenance** | Separate codebase | Shared codebase ✅ |
| **Font Rendering** | Web fonts | Google Fonts (same as mobile) ✅ |
| **Effects** | CSS/Canvas | Flutter Paint (same as mobile) ✅ |

## 📝 TODO

- [ ] Add drag-and-drop clock positioning
- [ ] Add resize handle
- [ ] Add gradient editor
- [ ] Add project save/load (localStorage)
- [ ] Add dashboard with thumbnails
- [ ] Add ImgHippo upload integration
- [ ] Add more text effects
- [ ] Add transform controls

## 🐛 Known Issues

- Drag-and-drop positioning not yet implemented
- Gradient editor not yet implemented
- Project management not yet implemented

## 📄 License

MIT License - Same as mobile app

## 🤝 Contributing

This is a companion app to the mobile wallpaper app. Changes to shared code (models, painter) should be synced with the mobile app.

---

**Built with Flutter Web for 100% mobile compatibility** 🎨
# wallpaper-studio-web

A Flutter web application for creating and editing depth wallpapers with customizable clocks, effects, and transforms.

## Features

- 🎨 Visual wallpaper editor with real-time preview
- ⏰ Customizable clock with multiple fonts and styles
- ✨ Effects: Shadow, Stroke, Inner/Outer Glow
- 🔄 Transforms: Stretch, Skew, Perspective rotations
- 📅 Optional date display
- 💾 Export wallpaper configurations as JSON
- 🖼️ Support for background and foreground layers

## Live Demo

Visit: [Your Netlify URL will be here]

## Deployment

### Netlify (Recommended)

1. **Connect GitHub Repository**
   - Go to [Netlify](https://app.netlify.com/)
   - Click "Add new site" → "Import an existing project"
   - Choose GitHub and select this repository

2. **Configure Build Settings**
   - Build command: `flutter build web --release`
   - Publish directory: `build/web`
   - (These are already configured in `netlify.toml`)

3. **Deploy**
   - Click "Deploy site"
   - Netlify will automatically build and deploy

### Manual Deployment

```bash
# Build the web app
flutter build web --release

# The built files are in build/web/
# Upload these files to any static hosting service
```

## Local Development

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Web browser

### Setup

```bash
# Clone the repository
git clone https://github.com/Medfakhir/wallpaper-studio-web.git
cd wallpaper-studio-web

# Get dependencies
flutter pub get

# Run in development mode
flutter run -d chrome
```

### Build for Production

```bash
flutter build web --release
```

## Usage

1. **Upload Images**
   - Click "Upload Background" to add a background image
   - Click "Upload Foreground" (optional) for depth effect

2. **Customize Clock**
   - Adjust position, size, font, and color
   - Apply effects like shadow, stroke, and glows
   - Add transforms for unique styles

3. **Export**
   - Click "Export JSON" to download the configuration
   - Use this JSON in your mobile app

## Project Structure

```
wallpaper_studio_web/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── wallpaper_model.dart  # Data models
│   ├── screens/
│   │   └── editor_screen.dart    # Main editor UI
│   └── widgets/
│       └── wallpaper_painter.dart # Canvas rendering
├── web/
│   ├── index.html                # HTML template
│   └── icons/                    # App icons
├── netlify.toml                  # Netlify configuration
└── pubspec.yaml                  # Dependencies

```

## Technologies

- **Flutter Web** - UI framework
- **Google Fonts** - Typography
- **File Picker** - Image uploads
- **Custom Painter** - Canvas rendering

## Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please open an issue on GitHub.

---

Built with ❤️ using Flutter

