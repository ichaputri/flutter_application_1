import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

// tambahkan metode getNext()
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // buat array untuk simpan kalimat favortit
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            // Membuat tata letak horizontal dengan Row
            children: [
              SafeArea(
                child: NavigationRail(
                  // Menyediakan navigasi di samping
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    // Daftar tujuan navigasi
                    NavigationRailDestination(
                      icon: Icon(Icons.home), // Ikon untuk Home
                      label: Text('Home'), // Label untuk Home
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), // Ikon untuk Favorites
                      label: Text('Favorites'), // Label untuk Favorites
                    ),
                  ],
                  selectedIndex:
                      selectedIndex, // Indeks tujuan yang dipilih saat ini
                  onDestinationSelected: (value) {
                    // Callback saat tujuan dipilih
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer, // Warna latar belakang dari tema
                  child: page, // Menampilkan halaman GeneratorPage
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Mengakses state aplikasi
    var pair = appState.current; // Mendapatkan pasangan saat ini dari state

    IconData icon;
    if (appState.favorites.contains(pair)) {
      // Memeriksa apakah pasangan saat ini ada di favorit
      icon = Icons.favorite; // Ikon favorit
    } else {
      icon = Icons.favorite_border; // Ikon tidak favorit
    }

    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Menyusun konten di tengah
        children: [
          BigCard(pair: pair), // Menampilkan kartu besar dengan pasangan
          SizedBox(height: 10), // Jarak vertikal antara elemen
          Row(
            mainAxisSize: MainAxisSize.min, // Menyusutkan ukuran Row ke minimum
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // Mengubah status favorit
                },
                icon: Icon(icon), // Menggunakan ikon favorit
                label: Text('Like'), // Label tombol
              ),
              SizedBox(width: 10), // Jarak horizontal antara tombol
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // Mendapatkan pasangan berikutnya
                },
                child: Text('Next'), // Label tombol
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Mengakses state aplikasi

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'), // Menampilkan pesan jika tidak ada favorit
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'), // Menampilkan jumlah favorit
        ),
        for (var pair in appState.favorites) // Menampilkan daftar favorit
          ListTile(
            leading: Icon(Icons.favorite), // Ikon untuk favorit
            title: Text(pair.asLowerCase), // Nama favorit
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
