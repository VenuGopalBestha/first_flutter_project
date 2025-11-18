import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<String> _items = List.generate(10, (i) => 'Item ${i + 1}');
  final Set<int> _favorites = {};

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_selectedIndex)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildBodyForIndex(context, _selectedIndex),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.message), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.create),
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Messages';
      case 2:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildBodyForIndex(BuildContext context, int index) {
    switch (index) {
      case 1:
        return _messagesView();
      case 2:
        return _profileView();
      default:
        return _dashboardView(context);
    }
  }

  Widget _dashboardView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Here are some recommendations for you.'),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              SizedBox(width: 4),
              _CategoryCard(icon: Icons.star, label: 'Featured'),
              SizedBox(width: 8),
              _CategoryCard(icon: Icons.trending_up, label: 'Trending'),
              SizedBox(width: 8),
              _CategoryCard(icon: Icons.new_releases, label: 'New'),
              SizedBox(width: 8),
              _CategoryCard(icon: Icons.favorite, label: 'Favorites'),
              SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Recommended', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = _items[index];
              final fav = _favorites.contains(index);
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item),
                subtitle: const Text('Short description goes here'),
                trailing: IconButton(
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : null),
                  onPressed: () => setState(() {
                    if (fav) {
                      _favorites.remove(index);
                    } else {
                      _favorites.add(index);
                    }
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _messagesView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.message, size: 56),
          SizedBox(height: 8),
          Text('No messages yet', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _profileView() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: const [
            CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            SizedBox(width: 12),
            Text('Jane Developer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
          const Spacer(),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
