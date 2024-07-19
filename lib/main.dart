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

class PanggilApiDeckKartu extends StatelessWidget {
  Future<List<dynamic>> GetApiKartu() async {
    final hasilApiKartu = await http.get(Uri.parse('https://jawanich.my.id/kartu.php'));
    if (hasilApiKartu.statusCode == 200) {
      final data = json.decode(hasilApiKartu.body);
      return data['kartu'];
    } else {
      throw Exception('Gagal Mengambil Data !');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kumpulan Deck Kartu'),
      ),
      // memungkinkan untuk merespon data berdasarkan status dari sebuah Future
      body: FutureBuilder<List<dynamic>>(
        // panggil Future yang sudah kita buat
        future: GetApiKartu(),
        builder: (context, snapshot) {
          // untuk menampilkan JSON ke dalam emulator

          // jika proses waiting. Menampilkan animasi loading (lingkaran progress)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // jika data error, maka akan memunculkan AsyncSnapshot Error
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Jika data yang dikirim null / kosong maka akan memunculkan keterangan di bawah
          else if (!snapshot.hasData) {
            return Center(child: Text('Tidak Ada Data yang terkirim'));
          }

          // Jika semua syarat memenuhi, akan menampilkan data
          else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.6,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final card = snapshot.data![index];
                return Card(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.blue[100],
                        child: Image.network(
                          card['image'],
                        ),
                      ),
                      Text(
                        '${card['value']} of ${card['suit']}',
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
