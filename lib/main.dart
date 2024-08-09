import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

class _PanggilApiDeckKartuState extends State<PanggilApiDeckKartu> {
  late Future<List<dynamic>> grabFutureKartu;
  List<dynamic> _cards = [];

  // Urutan halaman yang muncul dan tampilkan pertama
  int halamanUtamaTampil = 1;
  // Jumlah kartu yang ingin ditampilkan per satu halaman
  int batasJumlahKartuTampil = 8;

  @override
  void initState() {
    super.initState();
    grabFutureKartu = getApiKartu();
  }

  // Masukkan fungsi asinkron (operasi yang memerlukan waktu)
  Future<List<dynamic>> getApiKartu() async {
    // Buat variabel untuk menampung hasil data menggunakan API
    final hasilApiKartu = await http.get(
      Uri.parse('https://deckofcardsapi.com/api/deck/new/draw/?count=12'),
    );

    if (hasilApiKartu.statusCode == 200) {
      final data = json.decode(hasilApiKartu.body);
      return data['cards'];
    } else {
      throw Exception('Gagal Mengambil Data!');
    }
  }

  // Buat fungsi untuk melihat halaman kartu yang berbeda
  void perbaruiKartuTampil(int page) {
    setState(() {
      halamanUtamaTampil = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UAS Flutter Materi Rest-API'),
            Text(
              'Mobile Programming - Universitas Nasional Jakarta',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background wallpaper
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'), // Ensure you have this image in your assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: grabFutureKartu,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
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
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
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
                                    perbaruiKartuTampil(
                                        halamanUtamaTampil - 1);
                                  }
                                : null,
                            child: Text('Previous'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndex < _cards.length
                                ? () {
                                    perbaruiKartuTampil(
                                        halamanUtamaTampil + 1);
                                  }
                                : null,
                            child: Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add from dev:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Reference: https://course.lilidwianto.me'),
              Text('WhatsApp: 384038490'),
            ],
          ),
        ),
      ),
    );
  }
}
