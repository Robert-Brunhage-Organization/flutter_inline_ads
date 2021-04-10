import 'package:flutter/material.dart';
import 'package:flutter_inline_ads_tutorial/ad_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'country.dart';

final adStateProvider = ScopedProvider<AdState>(null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final adsInitialization = MobileAds.instance.initialize();
  final adState = AdState(initialization: adsInitialization);
  runApp(
    ProviderScope(
      overrides: [
        adStateProvider.overrideWithValue(adState),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter inline ads',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListPage(
        countries: List.generate(50, (index) => Country('Sweden', '+46')),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  ListPage({
    Key? key,
    required this.countries,
  }) : super(key: key);

  final List<Country> countries;
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late List<Object> countriesWithAds;

  @override
  void initState() {
    super.initState();
    countriesWithAds = List.from(widget.countries);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = context.read(adStateProvider);
    adState.initialization.then((value) {
      insertAdsToCountriesList(adState);
    });
  }

  void insertAdsToCountriesList(AdState adState) {
    setState(() {
      for (var i = countriesWithAds.length - 5; i >= 1; i -= 10) {
        countriesWithAds.insert(
          i,
          BannerAd(
            size: AdSize.banner,
            adUnitId: adState.bannerAdUnitId,
            listener: adState.adListener,
            request: AdRequest(),
          )..load(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inline Ads'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final item = countriesWithAds[index];
          if (item is Country) {
            return Card(
              child: ListTile(
                title: Text(item.name),
                trailing: Text(item.dialingCode),
              ),
            );
          } else {
            return Container(
              height: 50,
              child: AdWidget(ad: item as BannerAd),
            );
          }
        },
        itemCount: countriesWithAds.length,
      ),
    );
  }
}
