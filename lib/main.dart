import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(TampilKartu());
}

class TampilKartu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menampilkan Deck Kartu',
      home: PanggilApiDeckKartu(),
    );
  }
}

class PanggilApiDeckKartu extends StatefulWidget {
  @override
  _PanggilApiDeckKartuState createState() => _PanggilApiDeckKartuState();
}

class _PanggilApiDeckKartuState extends State<PanggilApiDeckKartu> with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> grabFutureKartu;
  List<dynamic> _cards = [];
  int halamanUtamaTampil = 1;
  int batasJumlahKartuTampil = 8;

  late VideoPlayerController _controller;
  late AnimationController _animasiController;
  late Animation<double> _animasi;

  @override
  void initState() {
    super.initState();
    grabFutureKartu = getApiKartu();

    // Inisialisasi video background
    _controller = VideoPlayerController.asset('assets/background.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });

    // Inisialisasi animasi transisi halaman
    _animasiController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animasi = CurvedAnimation(parent: _animasiController, curve: Curves.easeInOut);
  }

  Future<List<dynamic>> getApiKartu() async {
    final hasilApiKartu = await http.get(
      Uri.parse('https://deckofcardsapi.com/api/deck/new/draw/?count=30'),
    );

    if (hasilApiKartu.statusCode == 200) {
      final data = json.decode(hasilApiKartu.body);
      return data['cards'];
    } else {
      throw Exception('Gagal Mengambil Data!');
    }
  }

  void perbaruiKartuTampil(int page) {
    setState(() {
      halamanUtamaTampil = page;
    });
    _animasiController.forward(from: 0.0); 
  }

  @override
  void dispose() {
    _controller.dispose();
    _animasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: Opacity(
            opacity: 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('UAS Flutter Materi Rest-API'),
                Text(
                  'Mobile Programming - Universitas Nasional Jakarta',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Video background positioned to the back
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          // Konten Kartu di atas video
          FutureBuilder<List<dynamic>>(
            future: grabFutureKartu,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    strokeWidth: 6.0,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Tidak Ada Data yang terkirim'));
              } else {
                _cards = snapshot.data!;
                int startIndex =
                    (halamanUtamaTampil - 1) * batasJumlahKartuTampil;
                int endIndex = startIndex + batasJumlahKartuTampil;
                List<dynamic> currentPageCards = _cards.sublist(
                    startIndex,
                    endIndex > _cards.length ? _cards.length : endIndex);

                return FadeTransition(
                  opacity: _animasi,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            physics: BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 20.0,
                              mainAxisSpacing: 20.0,
                            ),
                            itemCount: currentPageCards.length,
                            itemBuilder: (context, index) {
                              final card = currentPageCards[index];
                              return Card(
                                elevation: 2.0,
                                color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        card['image'],
                                        height: 128,
                                        width: 128,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '${card['value']} of ${card['suit']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: halamanUtamaTampil > 1
                                  ? () {
                                      perbaruiKartuTampil(halamanUtamaTampil - 1);
                                    }
                                  : null,
                              child: Text('Previous'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: endIndex < _cards.length
                                  ? () {
                                      perbaruiKartuTampil(halamanUtamaTampil + 1);
                                    }
                                  : null,
                              child: Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
