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
  List<dynamic> _filteredCards = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  TextEditingController _searchController = TextEditingController();

  int halamanUtamaTampil = 1;
  int batasJumlahKartuTampil = 8;

  @override
  void initState() {
    super.initState();
    grabFutureKartu = getApiKartu();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _searchController.addListener(_filterCards);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
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

  void _filterCards() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCards = _cards.where((card) {
        String cardName = '${card['value']} of ${card['suit']}'.toLowerCase();
        return cardName.contains(query);
      }).toList();
    });
  }

  void perbaruiKartuTampil(int page) {
    setState(() {
      halamanUtamaTampil = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255).withOpacity(0.4), // Background header transparan dengan opacity 40%
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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: grabFutureKartu,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: ScaleTransition(
                    scale: _animation,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Tidak Ada Data yang terkirim'));
              } else {
                _cards = snapshot.data!;
                _filteredCards = _filteredCards.isEmpty ? _cards : _filteredCards;
                int startIndex = (halamanUtamaTampil - 1) * batasJumlahKartuTampil;
                int endIndex = startIndex + batasJumlahKartuTampil;
                List<dynamic> currentPageCards = _filteredCards.sublist(
                    startIndex,
                    endIndex > _filteredCards.length ? _filteredCards.length : endIndex);
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Cari Kartu', // Placeholder search bar
                          prefixIcon: Icon(Icons.search),
                          fillColor: Colors.white, // Set warna background search bar jadi putih
                          filled: true, // Biar warna putihnya muncul
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                    _pindahHalaman(() {
                                      perbaruiKartuTampil(halamanUtamaTampil - 1);
                                    });
                                  }
                                : null,
                            child: Text('Previous'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndex < _filteredCards.length
                                ? () {
                                    _pindahHalaman(() {
                                      perbaruiKartuTampil(halamanUtamaTampil + 1);
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
      callback();
      setState(() {});
    });
  }
}
