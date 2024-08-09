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

class _PanggilApiDeckKartuState extends State<PanggilApiDeckKartu> with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> grabFutureKartu;
  List<dynamic> _cards = [];
  late AnimationController _controller;
  late Animation<double> _animation;

  // Urutan halaman yang muncul dan tampilkan pertama
  int halamanUtamaTampil = 1;
  // Jumlah kartu yang ingin ditampilkan per satu halaman
  int batasJumlahKartuTampil = 8;

  @override
  void initState() {
    super.initState();
    grabFutureKartu = getApiKartu(); // Panggil API saat initState

    // Setup animasi loading
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi asinkron buat ambil data dari API
  Future<List<dynamic>> getApiKartu() async {
    // Panggil API pakai http.get
    final hasilApiKartu = await http.get(
      Uri.parse('https://deckofcardsapi.com/api/deck/new/draw/?count=30'),
    );

    if (hasilApiKartu.statusCode == 200) {
      final data = json.decode(hasilApiKartu.body);
      return data['cards']; // Balikin list kartu dari API
    } else {
      throw Exception('Gagal Mengambil Data!');
    }
  }

  // Fungsi buat update halaman yang ditampilkan
  void perbaruiKartuTampil(int page) {
    setState(() {
      halamanUtamaTampil = page; // Ubah state halaman
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0, // Hilangin bayangan AppBar
        title: Center(
          child: Opacity(
            opacity: 0.8, // Opacity title AppBar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Teks header ditengah
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
          // Background wallpaper
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'), // Pastikan ada gambar ini di assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: grabFutureKartu, // Data yang ditunggu dari API
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: ScaleTransition(
                    scale: _animation,
                    child: CircularProgressIndicator(), // Loading dengan animasi scale
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}')); // Kalau error
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Tidak Ada Data yang terkirim')); // Kalau datanya kosong
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
                          physics: BouncingScrollPhysics(), // Buat scrolling smooth
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
                              color: Colors.transparent, // Background kartu transparan
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.3), // Warna semi-transparan
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      card['image'], // Tampilkan gambar kartu
                                      height: 128,
                                      width: 128,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${card['value']} of ${card['suit']}', // Nama kartu
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // Ubah warna teks menjadi putih
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
                                    _pindahHalaman(() {
                                      perbaruiKartuTampil(
                                          halamanUtamaTampil - 1); // Pindah ke halaman sebelumnya
                                    });
                                  }
                                : null,
                            child: Text('Previous'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndex < _cards.length
                                ? () {
                                    _pindahHalaman(() {
                                      perbaruiKartuTampil(
                                          halamanUtamaTampil + 1); // Pindah ke halaman berikutnya
                                    });
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
    );
  }

  void _pindahHalaman(VoidCallback callback) {
    Future.delayed(Duration(milliseconds: 300), () {
      // Setelah delay, ubah state untuk pindah halaman
      callback();
      // Panggil setState untuk memperbarui halaman setelah callback dijalankan
      setState(() {});
    });
  }
}
