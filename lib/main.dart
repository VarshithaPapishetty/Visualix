import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'AlbumPage.dart';
import 'dart:io';  // Import Platform from dart:io
import 'SelectOption.dart';  // Import SelectOption
import 'VisualixHome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VisualixHome(),
    );
  }
}

class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key});

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  List<Album> albums = [];

  @override
  void initState() {
    super.initState();
    requestPermissions().whenComplete(() => loadAllAlbums());
  }

  // Request necessary permissions
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await Permission.photos.request();
    } else if (Platform.isAndroid) {
      await Permission.photos.request();
      await Permission.storage.request();
      await Permission.videos.request();
    }
  }

  // Check if permissions are granted before loading albums
  Future<void> checkPermissions() async {
    if (await Permission.storage.isGranted &&
        await Permission.photos.isGranted) {
      loadAllAlbums();
    } else {
      openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enable all permissions in Settings")),
      );
    }
  }

  loadAllAlbums() async {
    await checkPermissions();
    albums = await PhotoGallery.listAlbums();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    double imageWidth = (MediaQuery.of(context).size.width - 15) / 3;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualix', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey.shade700,centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SelectOption()),
            );
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(3),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (BuildContext ctx, int index) {
            Album album = albums[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return AlbumPage(album); // Pass the tapped album to AlbumPage
                }));
              },
              child: AspectRatio(
                aspectRatio: 1, // Ensures consistent item size
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          child: FadeInImage(
                            placeholder: MemoryImage(kTransparentImage),
                            image: AlbumThumbnailProvider(
                                album: album, highQuality: true),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        album.name.toString(),
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis, // Prevent text overflow
                        maxLines: 1, // Limit text to one line
                      ),
                    ),
                    Align(
                      child: Text(
                        album.count.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      alignment: Alignment.centerLeft,
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: albums.length,
        ),
      ),
    );
  }
}