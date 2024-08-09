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
    grabFutureKartu = getApiKartu(); // Panggil API saat initState
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
        title: Opacity(
          opacity: 0.8, // Opacity title AppBar
          child: Column(
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
                return Center(child: CircularProgressIndicator()); // Loading
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
                          // Menggunakan GridView.builder biar fleksibel
                          physics: BouncingScrollPhysics(), // Buat scrolling smooth
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // Membagi menjadi 4 kolom
                            childAspectRatio: 0.65, // Mengatur rasio agar kartu lebih panjang
                            crossAxisSpacing: 20.0, // Jarak antar kartu
                            mainAxisSpacing: 20.0, // Jarak antara baris kartu
                          ),
                          itemCount: currentPageCards.length,
                          itemBuilder: (context, index) {
                            final card = currentPageCards[index];
                            return Card(
                              elevation: 2.0, // Ketinggian bayangan kartu
                              color: Colors.transparent, // Background kartu transparan
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.3), // Warna semi-transparan
                                  borderRadius: BorderRadius.circular(10), // Sudut membulat
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      card['image'], // Tampilkan gambar kartu
                                      height: 100, // Tinggi gambar
                                      width: 100, // Lebar gambar
                                    ),
                                    SizedBox(height: 8), // Spasi antara gambar dan teks
                                    Text(
                                      '${card['value']} of ${card['suit']}', // Nama kartu
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14, // Ukuran teks
                                        fontWeight: FontWeight.bold, // Teks tebal
                                      ),
                                    ),
                                    SizedBox(height: 8), // Spasi bawah
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan tombol
                        children: [
                          Opacity(
                            opacity: 0.8, // Opacity untuk tombol "Previous"
                            child: ElevatedButton(
                              onPressed: halamanUtamaTampil > 1
                                  ? () {
                                      perbaruiKartuTampil(
                                          halamanUtamaTampil - 1); // Pindah ke halaman sebelumnya
                                    }
                                  : null,
                              child: Text('Previous'), // Teks tombol
                            ),
                          ),
                          SizedBox(width: 10), // Spasi antara tombol
                          Opacity(
                            opacity: 0.8, // Opacity untuk tombol "Next"
                            child: ElevatedButton(
                              onPressed: endIndex < _cards.length
                                  ? () {
                                      perbaruiKartuTampil(
                                          halamanUtamaTampil + 1); // Pindah ke halaman berikutnya
                                    }
                                  : null,
                              child: Text('Next'), // Teks tombol
                            ),
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
        color: Colors.transparent, // BottomAppBar transparan
        child: Container(
          color: Colors.black.withOpacity(0.5), // Warna semi-transparan
          padding: const EdgeInsets.all(8.0), // Padding kontainer
          child: SingleChildScrollView( // Mengatasi overflow dengan scroll
            scrollDirection: Axis.horizontal, // Scroll horizontal
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ukuran kolom minimal
              children: [
                Text(
                  'Add from dev:', // Teks informasi
                  style: TextStyle(fontWeight: FontWeight.bold), // Teks tebal
                ),
                Text('Reference: https://course.lilidwianto.me'), // Teks informasi
                Text('WhatsApp: 384038490'), // Teks informasi
              ],
            ),
          ),
        ),
      ),
    );
  }
}
