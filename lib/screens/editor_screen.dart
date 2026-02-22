import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import '../models/wallpaper_model.dart';
import '../widgets/wallpaper_painter.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late WallpaperModel _config;
  ui.Image? _backgroundImage;
  ui.Image? _foregroundImage;
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  final GlobalKey _canvasKey = GlobalKey();
  
  // Image upload state
  String? _backgroundImageName;
  String? _foregroundImageName;

  // Available fonts (same as mobile)
  final List<Map<String, String>> _fonts = [
    {'name': 'Bebas Neue', 'value': 'BebasNeue'},
    {'name': 'Oswald', 'value': 'Oswald'},
    {'name': 'Anton', 'value': 'Anton'},
    {'name': 'Russo One', 'value': 'RussoOne'},
    {'name': 'Righteous', 'value': 'Righteous'},
    {'name': 'Pacifico', 'value': 'Pacifico'},
    {'name': 'Lobster', 'value': 'Lobster'},
    {'name': 'Montserrat', 'value': 'Montserrat'},
    {'name': 'Roboto', 'value': 'Roboto'},
    {'name': 'Poppins', 'value': 'Poppins'},
    {'name': 'Lato', 'value': 'Lato'},
    {'name': 'Open Sans', 'value': 'OpenSans'},
    {'name': 'Raleway', 'value': 'Raleway'},
    {'name': 'Nunito', 'value': 'Nunito'},
    {'name': 'Ubuntu', 'value': 'Ubuntu'},
    {'name': 'Work Sans', 'value': 'WorkSans'},
    {'name': 'Inter', 'value': 'Inter'},
    {'name': 'Condensed', 'value': 'Condensed'},
    {'name': 'Dancing Script', 'value': 'DancingScript'},
    {'name': 'Satisfy', 'value': 'Satisfy'},
    {'name': 'Caveat', 'value': 'Caveat'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeConfig();
    _startTimer();
  }

  void _initializeConfig() {
    _config = WallpaperModel(
      id: 'wall_${DateTime.now().millisecondsSinceEpoch}',
      category: 'Custom',
      assets: WallpaperAssets(background: 'bg.jpg', foreground: 'fg.png'),
      clock: ClockConfig(
        enabled: true,
        format: 'HH:mm',
        font: 'Roboto',
        color: '#FFFFFF',
        opacity: 1.0,
        sizeRatio: 0.23,
        position: ClockPosition(x: 0.08, y: 0.55),
        lineHeight: 0.9,
        letterSpacing: 0.0,
        splitDigits: false,
        verticalLayout: false,
        horizontalLayout: false,
        transform: ClockTransform(
          horizontalStretch: 1.0,
          verticalStretch: 1.0,
          horizontalSkew: 0.0,
          verticalSkew: 0.0,
          perspectiveX: 0.0,
          perspectiveY: 0.0,
          perspectiveZ: 0.0,
        ),
        effects: ClockEffects(
          innerGlow: false,
          outerGlow: false,
        ),
        style: ClockStyle(
          strokeWidth: 0,
          strokeColor: '#000000',
          shadowBlur: 0,
          shadowColor: '#000000',
          shadowOffsetX: 0,
          shadowOffsetY: 0,
          gradient: GradientConfig(
            enabled: false,
            colors: ['#FFFFFF', '#FFFFFF'],
            angle: 0,
          ),
        ),
      ),
      date: DateConfig(
        enabled: false,
        format: 'EEEE, MMMM d',
        size: 0.03,
        position: ClockPosition(x: 0.5, y: 0.15),
      ),
      depth: DepthConfig(
        layerOrder: ['background', 'clock', 'foreground'],
        parallax: ParallaxConfig(background: 6, clock: 4, foreground: 2),
      ),
      version: '1.0',
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pickBackgroundImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      final fileName = result.files.first.name;
      
      // Load image for preview
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      setState(() {
        _backgroundImage = frame.image;
        _backgroundImageName = fileName;
      });
      
      // Show uploading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading to ImgHippo...'),
            backgroundColor: Color(0xFFFF9500),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Upload to ImgHippo API
      try {
        final url = await _uploadToImgHippo(bytes, fileName);
        
        setState(() {
          _config = _config.copyWith(
            assets: WallpaperAssets(
              background: url,
              foreground: _config.assets.foreground,
            ),
          );
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uploaded! URL: $url'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickForegroundImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      final fileName = result.files.first.name;
      
      // Load image for preview
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      setState(() {
        _foregroundImage = frame.image;
        _foregroundImageName = fileName;
      });
      
      // Show uploading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading to ImgHippo...'),
            backgroundColor: Color(0xFFFF9500),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Upload to ImgHippo API
      try {
        final url = await _uploadToImgHippo(bytes, fileName);
        
        setState(() {
          _config = _config.copyWith(
            assets: WallpaperAssets(
              background: _config.assets.background,
              foreground: url,
            ),
          );
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uploaded! URL: $url'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<String> _uploadToImgHippo(List<int> bytes, String fileName) async {
    const apiKey = 'fe3f8101790f60cb28505aafa6237a0c';
    const uploadUrl = 'https://api.imghippo.com/v1/upload';
    
    // Create multipart request using FormData
    final formData = html.FormData();
    formData.append('api_key', apiKey);
    
    // Create Blob and append with filename using appendBlob
    final blob = html.Blob([bytes]);
    // Use appendBlob method which accepts 3 parameters: name, blob, filename
    (formData as dynamic).appendBlob('file', blob, fileName);
    
    // Send request using XMLHttpRequest
    final xhr = html.HttpRequest();
    xhr.open('POST', uploadUrl);
    
    // Create completer for async response
    final completer = Completer<String>();
    
    xhr.onLoad.listen((event) {
      if (xhr.status == 200) {
        try {
          final jsonResponse = jsonDecode(xhr.responseText!);
          
          if (jsonResponse['success'] == true) {
            final imageUrl = jsonResponse['data']['url'] as String;
            completer.complete(imageUrl);
          } else {
            completer.completeError(jsonResponse['message'] ?? 'Upload failed');
          }
        } catch (e) {
          completer.completeError('Failed to parse response: $e');
        }
      } else {
        completer.completeError('Upload failed with status: ${xhr.status}');
      }
    });
    
    xhr.onError.listen((event) {
      completer.completeError('Network error during upload');
    });
    
    // Send the request
    xhr.send(formData);
    
    return completer.future;
  }

  Future<void> _loadImageFromUrl(String url, {required bool isBackground}) async {
    try {
      // Fetch image from URL
      final xhr = html.HttpRequest();
      xhr.open('GET', url);
      xhr.responseType = 'arraybuffer';
      
      final completer = Completer<Uint8List>();
      
      xhr.onLoad.listen((event) {
        if (xhr.status == 200) {
          final buffer = xhr.response;
          final bytes = (buffer as ByteBuffer).asUint8List();
          completer.complete(bytes);
        } else {
          completer.completeError('Failed to load image: ${xhr.status}');
        }
      });
      
      xhr.onError.listen((event) {
        completer.completeError('Network error while loading image');
      });
      
      xhr.send();
      
      final bytes = await completer.future;
      
      // Load image for preview
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      setState(() {
        if (isBackground) {
          _backgroundImage = frame.image;
          _backgroundImageName = url.split('/').last;
        } else {
          _foregroundImage = frame.image;
          _foregroundImageName = url.split('/').last;
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  void _updateClockConfig(ClockConfig newConfig) {
    setState(() {
      _config = _config.copyWith(clock: newConfig);
    });
  }

  Future<void> _exportJSON() async {
    // Canvas uses percentage-based sizing - works on all screen sizes!
    // No adjustment needed - responsive by design
    final json = jsonEncode(_config.toJson());
    
    // Create blob and download
    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '${_config.id}.json')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON exported! Responsive design - works on all screen sizes'),
          backgroundColor: Color(0xFFFF9500),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _exportImage() async {
    try {
      final boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'wallpaper_${_config.id}.png')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image exported successfully!'),
            backgroundColor: Color(0xFFFF9500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper Studio - Depth Effect Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportJSON,
            tooltip: 'Export JSON',
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _exportImage,
            tooltip: 'Export Image',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Canvas Preview - Smaller preview size (not full screen)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use a good preview size for web editor
                    // Large enough to see details, small enough to fit browser
                    const previewWidth = 540.0;   // 1.5x larger
                    const previewHeight = 960.0;  // 9:16 ratio
                    const targetAspect = previewWidth / previewHeight;
                    
                    // Calculate scale to fit screen
                    final maxWidth = constraints.maxWidth;
                    final maxHeight = constraints.maxHeight;
                    
                    double displayWidth, displayHeight;
                    if (maxWidth / maxHeight > targetAspect) {
                      // Height is limiting factor
                      displayHeight = maxHeight;
                      displayWidth = displayHeight * targetAspect;
                    } else {
                      // Width is limiting factor
                      displayWidth = maxWidth;
                      displayHeight = displayWidth / targetAspect;
                    }
                    
                    return SizedBox(
                      width: displayWidth,
                      height: displayHeight,
                      child: RepaintBoundary(
                        key: _canvasKey,
                        child: CustomPaint(
                          painter: WallpaperPainter(
                            config: _config,
                            backgroundImage: _backgroundImage,
                            foregroundImage: _foregroundImage,
                            currentTime: _currentTime,
                            showSelection: false,
                          ),
                          size: Size(displayWidth, displayHeight),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Controls Panel
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildClockSection(),
                  const SizedBox(height: 24),
                  _buildTransformSection(),
                  const SizedBox(height: 24),
                  _buildEffectsSection(),
                  const SizedBox(height: 24),
                  _buildStyleSection(),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Background Image
            const Text('Background Image', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            
            // Show loaded image preview
            if (_backgroundImage != null) ...[
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF9500), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                        color: Colors.grey[300],
                      ),
                      child: const Icon(Icons.image, size: 24, color: Colors.grey),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _backgroundImageName ?? 'Background loaded',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (_config.assets.background.startsWith('http'))
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text('URL set', style: TextStyle(fontSize: 11, color: Colors.green)),
                                ],
                              )
                            else
                              const Text('Paste URL below', style: TextStyle(fontSize: 11, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            ElevatedButton.icon(
              onPressed: _pickBackgroundImage,
              icon: const Icon(Icons.image, size: 18),
              label: Text(_backgroundImage == null ? 'Upload Background' : 'Change Background'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey(_config.assets.background),
              initialValue: _config.assets.background.startsWith('http') ? _config.assets.background : '',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Background Image URL',
                hintText: 'https://i.imghippo.com/files/xxxxx.jpg',
                helperText: 'Paste URL and press Enter to load',
                helperMaxLines: 2,
              ),
              onChanged: (value) {
                // Update config immediately
                setState(() {
                  _config = _config.copyWith(
                    assets: WallpaperAssets(
                      background: value.trim().isEmpty ? 'bg.jpg' : value.trim(),
                      foreground: _config.assets.foreground,
                    ),
                  );
                });
              },
              onFieldSubmitted: (value) async {
                final url = value.trim();
                if (url.isEmpty || !url.startsWith('http')) return;
                
                // Update config
                setState(() {
                  _config = _config.copyWith(
                    assets: WallpaperAssets(
                      background: url,
                      foreground: _config.assets.foreground,
                    ),
                  );
                });
                
                // Load image from URL
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loading image from URL...'),
                      backgroundColor: Color(0xFFFF9500),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  await _loadImageFromUrl(url, isBackground: true);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image loaded successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load image: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Foreground Image
            const Text('Foreground Image (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            
            // Show loaded image preview
            if (_foregroundImage != null) ...[
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF9500), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                        color: Colors.grey[300],
                      ),
                      child: const Icon(Icons.layers, size: 24, color: Colors.grey),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _foregroundImageName ?? 'Foreground loaded',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (_config.assets.foreground != null && _config.assets.foreground!.startsWith('http'))
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text('URL set', style: TextStyle(fontSize: 11, color: Colors.green)),
                                ],
                              )
                            else
                              const Text('Paste URL below', style: TextStyle(fontSize: 11, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            ElevatedButton.icon(
              onPressed: _pickForegroundImage,
              icon: const Icon(Icons.layers, size: 18),
              label: Text(_foregroundImage == null ? 'Upload Foreground' : 'Change Foreground'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey(_config.assets.foreground),
              initialValue: (_config.assets.foreground != null && _config.assets.foreground!.startsWith('http')) ? _config.assets.foreground : '',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Foreground Image URL (Optional)',
                hintText: 'https://i.imghippo.com/files/yyyyy.png',
                helperText: 'Paste URL and press Enter to load',
                helperMaxLines: 2,
              ),
              onChanged: (value) {
                // Update config immediately
                setState(() {
                  _config = _config.copyWith(
                    assets: WallpaperAssets(
                      background: _config.assets.background,
                      foreground: value.trim().isEmpty ? 'fg.png' : value.trim(),
                    ),
                  );
                });
              },
              onFieldSubmitted: (value) async {
                final url = value.trim();
                if (url.isEmpty || !url.startsWith('http')) {
                  // Clear foreground if empty
                  setState(() {
                    _config = _config.copyWith(
                      assets: WallpaperAssets(
                        background: _config.assets.background,
                        foreground: 'fg.png',
                      ),
                    );
                    _foregroundImage = null;
                    _foregroundImageName = null;
                  });
                  return;
                }
                
                // Update config
                setState(() {
                  _config = _config.copyWith(
                    assets: WallpaperAssets(
                      background: _config.assets.background,
                      foreground: url,
                    ),
                  );
                });
                
                // Load image from URL
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loading foreground image...'),
                      backgroundColor: Color(0xFFFF9500),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  await _loadImageFromUrl(url, isBackground: false);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foreground loaded successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load foreground: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload images to imghippo.com, then paste URLs here',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clock',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _config.clock.enabled,
                  onChanged: (value) {
                    _updateClockConfig(_config.clock.copyWith(enabled: value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Font
            const Text('Font', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _config.clock.font,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _fonts.map((font) {
                return DropdownMenuItem(
                  value: font['value'],
                  child: Text(font['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateClockConfig(_config.clock.copyWith(font: value));
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Size
            Text('Size: ${(_config.clock.sizeRatio * 100).round()}%'),
            Slider(
              value: _config.clock.sizeRatio,
              min: 0.1,
              max: 0.8,
              divisions: 70,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(sizeRatio: value));
              },
            ),
            
            // Opacity
            Text('Opacity: ${(_config.clock.opacity * 100).round()}%'),
            Slider(
              value: _config.clock.opacity,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(opacity: value));
              },
            ),
            
            // Letter Spacing
            Text('Letter Spacing: ${_config.clock.letterSpacing.toStringAsFixed(2)}'),
            Slider(
              value: _config.clock.letterSpacing,
              min: -0.1,
              max: 0.3,
              divisions: 40,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(letterSpacing: value));
              },
            ),
            
            // Line Height
            Text('Line Height: ${_config.clock.lineHeight.toStringAsFixed(2)}'),
            Slider(
              value: _config.clock.lineHeight,
              min: 0.5,
              max: 1.5,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(lineHeight: value));
              },
            ),
            
            // Color
            const SizedBox(height: 8),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showColorPicker(),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _parseColor(_config.clock.color),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.colorize, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    key: ValueKey(_config.clock.color),
                    initialValue: _config.clock.color,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Hex Color',
                      hintText: '#FFFFFF',
                    ),
                    onChanged: (value) {
                      if (value.startsWith('#') && value.length == 7) {
                        _updateClockConfig(_config.clock.copyWith(color: value));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick color presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorPreset('#FFFFFF', 'White'),
                _buildColorPreset('#000000', 'Black'),
                _buildColorPreset('#FF0000', 'Red'),
                _buildColorPreset('#00FF00', 'Green'),
                _buildColorPreset('#0000FF', 'Blue'),
                _buildColorPreset('#FFFF00', 'Yellow'),
                _buildColorPreset('#FF00FF', 'Magenta'),
                _buildColorPreset('#00FFFF', 'Cyan'),
                _buildColorPreset('#FF9500', 'Orange'),
                _buildColorPreset('#9C27B0', 'Purple'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Position Controls
            const Text('Position', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.blue[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Position is relative to canvas. Keep between 10-90% to stay fully visible.',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('X Position: ${(_config.clock.position.x * 100).toStringAsFixed(1)}%'),
            Slider(
              value: _config.clock.position.x,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  position: ClockPosition(x: value, y: _config.clock.position.y),
                ));
              },
            ),
            
            Text('Y Position: ${(_config.clock.position.y * 100).toStringAsFixed(1)}%'),
            Slider(
              value: _config.clock.position.y,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  position: ClockPosition(x: _config.clock.position.x, y: value),
                ));
              },
            ),
            
            const SizedBox(height: 12),
            
            // Quick Position Buttons
            const Text('Quick Position', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Top Left
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.08, y: 0.15),
                    ));
                  },
                  icon: const Icon(Icons.north_west, size: 16),
                  label: const Text('Top Left', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // Top Center
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.5, y: 0.15),
                    ));
                  },
                  icon: const Icon(Icons.north, size: 16),
                  label: const Text('Top Center', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // Top Right
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.92, y: 0.15),
                    ));
                  },
                  icon: const Icon(Icons.north_east, size: 16),
                  label: const Text('Top Right', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // Center Left
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.08, y: 0.5),
                    ));
                  },
                  icon: const Icon(Icons.west, size: 16),
                  label: const Text('Left', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // CENTER
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.5, y: 0.5),
                    ));
                  },
                  icon: const Icon(Icons.center_focus_strong, size: 16),
                  label: const Text('CENTER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                    backgroundColor: const Color(0xFFFF9500),
                    foregroundColor: Colors.white,
                  ),
                ),
                
                // Center Right
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.92, y: 0.5),
                    ));
                  },
                  icon: const Icon(Icons.east, size: 16),
                  label: const Text('Right', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // Bottom Left
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.08, y: 0.85),
                    ));
                  },
                  icon: const Icon(Icons.south_west, size: 16),
                  label: const Text('Bottom Left', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // Bottom Center
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.5, y: 0.85),
                    ));
                  },
                  icon: const Icon(Icons.south, size: 16),
                  label: const Text('Bottom Center', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // Bottom Right
                ElevatedButton.icon(
                  onPressed: () {
                    _updateClockConfig(_config.clock.copyWith(
                      position: ClockPosition(x: 0.92, y: 0.85),
                    ));
                  },
                  icon: const Icon(Icons.south_east, size: 16),
                  label: const Text('Bottom Right', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Layout
            const Text('Layout', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Normal'),
                  selected: !_config.clock.verticalLayout && !_config.clock.splitDigits,
                  onSelected: (selected) {
                    if (selected) {
                      _updateClockConfig(_config.clock.copyWith(
                        verticalLayout: false,
                        splitDigits: false,
                        horizontalLayout: false,
                      ));
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Vertical'),
                  selected: _config.clock.verticalLayout,
                  onSelected: (selected) {
                    if (selected) {
                      _updateClockConfig(_config.clock.copyWith(
                        verticalLayout: true,
                        splitDigits: false,
                        horizontalLayout: false,
                      ));
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Split'),
                  selected: _config.clock.splitDigits,
                  onSelected: (selected) {
                    if (selected) {
                      _updateClockConfig(_config.clock.copyWith(
                        verticalLayout: false,
                        splitDigits: true,
                        horizontalLayout: false,
                      ));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformSection() {
    final transform = _config.clock.transform ?? ClockTransform();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transform',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Text('Horizontal Stretch: ${transform.horizontalStretch.toStringAsFixed(2)}'),
            Slider(
              value: transform.horizontalStretch,
              min: 0.5,
              max: 1.5,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  transform: ClockTransform(
                    horizontalStretch: value,
                    verticalStretch: transform.verticalStretch,
                    horizontalSkew: transform.horizontalSkew,
                    verticalSkew: transform.verticalSkew,
                    perspectiveX: transform.perspectiveX,
                    perspectiveY: transform.perspectiveY,
                    perspectiveZ: transform.perspectiveZ,
                  ),
                ));
              },
            ),
            
            Text('Vertical Stretch: ${transform.verticalStretch.toStringAsFixed(2)}'),
            Slider(
              value: transform.verticalStretch,
              min: 0.5,
              max: 1.5,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  transform: ClockTransform(
                    horizontalStretch: transform.horizontalStretch,
                    verticalStretch: value,
                    horizontalSkew: transform.horizontalSkew,
                    verticalSkew: transform.verticalSkew,
                    perspectiveX: transform.perspectiveX,
                    perspectiveY: transform.perspectiveY,
                    perspectiveZ: transform.perspectiveZ,
                  ),
                ));
              },
            ),
            
            Text('Horizontal Skew: ${transform.horizontalSkew.toStringAsFixed(2)}'),
            Slider(
              value: transform.horizontalSkew,
              min: -0.5,
              max: 0.5,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  transform: ClockTransform(
                    horizontalStretch: transform.horizontalStretch,
                    verticalStretch: transform.verticalStretch,
                    horizontalSkew: value,
                    verticalSkew: transform.verticalSkew,
                    perspectiveX: transform.perspectiveX,
                    perspectiveY: transform.perspectiveY,
                    perspectiveZ: transform.perspectiveZ,
                  ),
                ));
              },
            ),
            
            Text('Vertical Skew: ${transform.verticalSkew.toStringAsFixed(2)}'),
            Slider(
              value: transform.verticalSkew,
              min: -0.5,
              max: 0.5,
              divisions: 100,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  transform: ClockTransform(
                    horizontalStretch: transform.horizontalStretch,
                    verticalStretch: transform.verticalStretch,
                    horizontalSkew: transform.horizontalSkew,
                    verticalSkew: value,
                    perspectiveX: transform.perspectiveX,
                    perspectiveY: transform.perspectiveY,
                    perspectiveZ: transform.perspectiveZ,
                  ),
                ));
              },
            ),
            
            Text('Perspective X: ${transform.perspectiveX.toStringAsFixed(0)}°'),
            Slider(
              value: transform.perspectiveX,
              min: -45,
              max: 45,
              divisions: 90,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  transform: ClockTransform(
                    horizontalStretch: transform.horizontalStretch,
                    verticalStretch: transform.verticalStretch,
                    horizontalSkew: transform.horizontalSkew,
                    verticalSkew: transform.verticalSkew,
                    perspectiveX: value,
                    perspectiveY: transform.perspectiveY,
                    perspectiveZ: transform.perspectiveZ,
                  ),
                ));
              },
            ),
            
            Text('Perspective Y: ${transform.perspectiveY.toStringAsFixed(0)}°'),
            Slider(
              value: transform.perspectiveY,
              min: -45,
              max: 45,
              divisions: 90,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  transform: ClockTransform(
                    horizontalStretch: transform.horizontalStretch,
                    verticalStretch: transform.verticalStretch,
                    horizontalSkew: transform.horizontalSkew,
                    verticalSkew: transform.verticalSkew,
                    perspectiveX: transform.perspectiveX,
                    perspectiveY: value,
                    perspectiveZ: transform.perspectiveZ,
                  ),
                ));
              },
            ),
            
            Text('Perspective Z: ${transform.perspectiveZ.toStringAsFixed(0)}°'),
            Slider(
              value: transform.perspectiveZ,
              min: -180,
              max: 180,
              divisions: 360,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  transform: ClockTransform(
                    horizontalStretch: transform.horizontalStretch,
                    verticalStretch: transform.verticalStretch,
                    horizontalSkew: transform.horizontalSkew,
                    verticalSkew: transform.verticalSkew,
                    perspectiveX: transform.perspectiveX,
                    perspectiveY: transform.perspectiveY,
                    perspectiveZ: value,
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectsSection() {
    final effects = _config.clock.effects ?? ClockEffects();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Effects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Inner Glow'),
              value: effects.innerGlow,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  effects: ClockEffects(
                    innerGlow: value,
                    outerGlow: effects.outerGlow,
                  ),
                ));
              },
            ),
            
            SwitchListTile(
              title: const Text('Outer Glow'),
              value: effects.outerGlow,
              onChanged: (value) {
                _updateClockConfig(_config.clock.copyWith(
                  effects: ClockEffects(
                    innerGlow: effects.innerGlow,
                    outerGlow: value,
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Stroke
            Text('Stroke Width: ${_config.clock.style?.strokeWidth?.round() ?? 0}'),
            Slider(
              value: _config.clock.style?.strokeWidth ?? 0,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (value) {
                final newStyle = _config.clock.style ?? ClockStyle();
                _updateClockConfig(_config.clock.copyWith(
                  style: ClockStyle(
                    strokeWidth: value,
                    strokeColor: newStyle.strokeColor ?? '#000000',
                    shadowBlur: newStyle.shadowBlur,
                    shadowColor: newStyle.shadowColor,
                    shadowOffsetX: newStyle.shadowOffsetX,
                    shadowOffsetY: newStyle.shadowOffsetY,
                    gradient: newStyle.gradient,
                  ),
                ));
              },
            ),
            
            // Shadow
            Text('Shadow Blur: ${_config.clock.style?.shadowBlur?.round() ?? 0}'),
            Slider(
              value: _config.clock.style?.shadowBlur ?? 0,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (value) {
                final newStyle = _config.clock.style ?? ClockStyle();
                _updateClockConfig(_config.clock.copyWith(
                  style: ClockStyle(
                    strokeWidth: newStyle.strokeWidth,
                    strokeColor: newStyle.strokeColor,
                    shadowBlur: value,
                    shadowColor: newStyle.shadowColor ?? '#000000',
                    shadowOffsetX: newStyle.shadowOffsetX ?? 0,
                    shadowOffsetY: newStyle.shadowOffsetY ?? 0,
                    gradient: newStyle.gradient,
                  ),
                ));
              },
            ),
            
            // Gradient
            const SizedBox(height: 16),
            const Text('Gradient', style: TextStyle(fontWeight: FontWeight.w500)),
            SwitchListTile(
              title: const Text('Enable Gradient'),
              value: _config.clock.style?.gradient?.enabled ?? false,
              onChanged: (value) {
                final newStyle = _config.clock.style ?? ClockStyle();
                final gradient = newStyle.gradient ?? GradientConfig(
                  enabled: false,
                  colors: ['#FFFFFF', '#FFFFFF'],
                  angle: 0,
                );
                _updateClockConfig(_config.clock.copyWith(
                  style: ClockStyle(
                    strokeWidth: newStyle.strokeWidth,
                    strokeColor: newStyle.strokeColor,
                    shadowBlur: newStyle.shadowBlur,
                    shadowColor: newStyle.shadowColor,
                    shadowOffsetX: newStyle.shadowOffsetX,
                    shadowOffsetY: newStyle.shadowOffsetY,
                    gradient: GradientConfig(
                      enabled: value,
                      colors: gradient.colors,
                      angle: gradient.angle,
                    ),
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _config.date?.enabled ?? false,
                  onChanged: (value) {
                    setState(() {
                      _config = _config.copyWith(
                        date: DateConfig(
                          enabled: value,
                          format: _config.date?.format ?? 'EEEE, MMMM d',
                          size: _config.date?.size ?? 0.03,
                          position: _config.date?.position ?? ClockPosition(x: 0.5, y: 0.15),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
            
            if (_config.date?.enabled ?? false) ...[
              const SizedBox(height: 16),
              
              Text('Date Size: ${(_config.date!.size * 100).toStringAsFixed(1)}%'),
              Slider(
                value: _config.date!.size,
                min: 0.015,
                max: 0.05,
                divisions: 35,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(
                      date: DateConfig(
                        enabled: _config.date!.enabled,
                        format: _config.date!.format,
                        size: value,
                        position: _config.date!.position,
                      ),
                    );
                  });
                },
              ),
              
              const SizedBox(height: 8),
              const Text('Format', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _config.date!.format,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'EEEE, MMMM d', child: Text('Monday, January 15')),
                  DropdownMenuItem(value: 'MMM d, yyyy', child: Text('Jan 15, 2024')),
                  DropdownMenuItem(value: 'MMMM d', child: Text('January 15')),
                  DropdownMenuItem(value: 'EEE, MMM d', child: Text('Mon, Jan 15')),
                  DropdownMenuItem(value: 'd MMMM yyyy', child: Text('15 January 2024')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _config = _config.copyWith(
                        date: DateConfig(
                          enabled: _config.date!.enabled,
                          format: value,
                          size: _config.date!.size,
                          position: _config.date!.position,
                        ),
                      );
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // RGB Sliders
              _buildColorSlider(
                'Red',
                _parseColor(_config.clock.color).red.toDouble(),
                (value) {
                  final color = _parseColor(_config.clock.color);
                  final newColor = Color.fromARGB(255, value.toInt(), color.green, color.blue);
                  _updateClockConfig(_config.clock.copyWith(
                    color: '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  ));
                },
                Colors.red,
              ),
              _buildColorSlider(
                'Green',
                _parseColor(_config.clock.color).green.toDouble(),
                (value) {
                  final color = _parseColor(_config.clock.color);
                  final newColor = Color.fromARGB(255, color.red, value.toInt(), color.blue);
                  _updateClockConfig(_config.clock.copyWith(
                    color: '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  ));
                },
                Colors.green,
              ),
              _buildColorSlider(
                'Blue',
                _parseColor(_config.clock.color).blue.toDouble(),
                (value) {
                  final color = _parseColor(_config.clock.color);
                  final newColor = Color.fromARGB(255, color.red, color.green, value.toInt());
                  _updateClockConfig(_config.clock.copyWith(
                    color: '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  ));
                },
                Colors.blue,
              ),
              const SizedBox(height: 16),
              // Preview
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: _parseColor(_config.clock.color),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _config.clock.color,
                    style: TextStyle(
                      color: _parseColor(_config.clock.color).computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSlider(String label, double value, Function(double) onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}'),
        Slider(
          value: value,
          min: 0,
          max: 255,
          divisions: 255,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildColorPreset(String hexColor, String label) {
    return GestureDetector(
      onTap: () {
        _updateClockConfig(_config.clock.copyWith(color: hexColor));
      },
      child: Tooltip(
        message: label,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _parseColor(hexColor),
            border: Border.all(
              color: _config.clock.color == hexColor ? const Color(0xFFFF9500) : Colors.grey,
              width: _config.clock.color == hexColor ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
