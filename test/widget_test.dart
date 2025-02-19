import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

import 'ViewerPage.dart';

class AlbumPage extends StatefulWidget {
  final Album album;

  AlbumPage(this.album);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<Medium> mediumList = [];

  @override
  void initState() {
    super.initState();
    loadMedia();
  }

  Future<void> loadMedia() async {
    try {
      MediaPage mediaPage = await widget.album.listMedia();
      setState(() {
        mediumList = mediaPage.items; // Assign items from mediaPage to mediumList
      });
    } catch (e) {
      // Handle potential errors (e.g., permissions)
      debugPrint("Error loading media: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double imageWidth = (MediaQuery.of(context).size.width - 15) / 3;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.album.name.toString(), // Remove const for dynamic data
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey.shade700,centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
            Medium medium = mediumList[index];
            return InkWell(
              onTap: () {
                // Placeholder for onTap action
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return ViewerPage(medium);
                }));
                debugPrint("Tapped on medium: ${medium.id}");
              },
              child: AspectRatio(
                aspectRatio: 1, // Ensures consistent item size
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: ThumbnailProvider(
                      mediumId: medium.id,
                      mediumType: medium.mediumType,
                      highQuality: true,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
          itemCount: mediumList.length,
        ),
      ),
    );
  }
}