import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(TampilKartu()); // Mulai aplikasi kita dengan widget TampilKartu
}

class TampilKartu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menampilkan Deck Kartu', // Judul aplikasi
      home: PanggilApiDeckKartu(), // Halaman utama yang ditampilkan
    );
  }
}

class PanggilApiDeckKartu extends StatefulWidget {
  @override
  _PanggilApiDeckKartuState createState() => _PanggilApiDeckKartuState(); // State untuk manajemen stateful widget
}

class _PanggilApiDeckKartuState extends State<PanggilApiDeckKartu> with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> grabFutureKartu; // Buat nampung hasil future dari API
  List<dynamic> _cards = []; // List kartu yang bakal kita tampilkan
  late AnimationController _controller; // Controller buat animasi
  late Animation<double> _animation; // Animasi yang bakal dipake

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
      duration: const Duration(seconds: 2), // Durasi animasi 2 detik
      vsync: this,
    )..repeat(reverse: true); // Animasi bolak-balik biar smooth

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Curva animasi biar halus masuk dan keluarnya
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Jangan lupa dispose biar ga memory leak
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
      throw Exception('Gagal Mengambil Data!'); // Error handling
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
                Text('UAS Flutter Materi Rest-API'), // Title header
                Text(
                  'Mobile Programming - Universitas Nasional Jakarta', // Subtitle header
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
                fit: BoxFit.cover, // Biar gambarnya nge-full background
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
                _cards = snapshot.data!; // Simpan data kartu dari API
                int startIndex =
                    (halamanUtamaTampil - 1) * batasJumlahKartuTampil; // Hitung start index
                int endIndex = startIndex + batasJumlahKartuTampil; // Hitung end index
                List<dynamic> currentPageCards = _cards.sublist(
                    startIndex,
                    endIndex > _cards.length ? _cards.length : endIndex); // Ambil data kartu buat halaman ini
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(), // Buat scrolling smooth
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // 4 kartu per row
                            childAspectRatio: 0.7, // Ratio kartu
                            crossAxisSpacing: 20.0, // Spasi antar kolom
                            mainAxisSpacing: 20.0, // Spasi antar baris
                          ),
                          itemCount: currentPageCards.length, // Jumlah kartu per halaman
                          itemBuilder: (context, index) {
                            final card = currentPageCards[index];
                            return Card(
                              elevation: 2.0,
                              color: Colors.transparent, // Background kartu transparan
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.3), // Warna semi-transparan
                                  borderRadius: BorderRadius.circular(10), // Radius biar rounded
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      card['image'], // Tampilkan gambar kartu
                                      height: 128,
                                      width: 128,
                                    ),
                                    SizedBox(height: 8), // Spasi biar ga mepet
                                    Text(
                                      '${card['value']} of ${card['suit']}', // Nama kartu
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // Ubah warna teks jadi putih
                                      ),
                                    ),
                                    SizedBox(height: 8), // Spasi lagi biar enak dilihat
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
                                : null, // Disable tombol kalo udah di halaman pertama
                            child: Text('Previous'),
                          ),
                          SizedBox(width: 10), // Spasi antar tombol
                          ElevatedButton(
                            onPressed: endIndex < _cards.length
                                ? () {
                                    _pindahHalaman(() {
                                      perbaruiKartuTampil(
                                          halamanUtamaTampil + 1); // Pindah ke halaman berikutnya
                                    });
                                  }
                                : null, // Disable tombol kalo udah di halaman terakhir
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

  // Fungsi buat handle pindah halaman dengan delay
  void _pindahHalaman(VoidCallback callback) {
    Future.delayed(Duration(milliseconds: 300), () {
      // Setelah delay 300ms, ubah state buat pindah halaman
      callback();
      // Panggil setState lagi biar halaman kebarui
      setState(() {});
    });
  }
}
