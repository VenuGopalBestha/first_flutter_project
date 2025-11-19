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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
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
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search items',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _searchController.clear();
                      _query = '';
                    }),
                  )
                : null,
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
          child: Builder(builder: (context) {
            final filtered = _query.isEmpty
                ? _items
                : _items.where((s) => s.toLowerCase().contains(_query.toLowerCase())).toList();
            if (filtered.isEmpty) {
              return const Center(child: Text('No items match your search'));
            }
            return ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final origIndex = _items.indexOf(item);
                final fav = _favorites.contains(origIndex);
                return ListTile(
                  leading: CircleAvatar(child: Text('${origIndex + 1}')),
                  title: Text(item),
                  subtitle: const Text('Short description goes here'),
                  trailing: IconButton(
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : null),
                    onPressed: () => setState(() {
                      if (fav) {
                        _favorites.remove(origIndex);
                      } else {
                        _favorites.add(origIndex);
                      }
                    }),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(title: item, index: origIndex, isFavorite: fav, onFavoriteToggle: () {
                      setState(() {
                        if (fav) {
                          _favorites.remove(origIndex);
                        } else {
                          _favorites.add(origIndex);
                        }
                      });
                    })));
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add item'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Item name'),
            onSubmitted: (_) => _addItemFromController(controller),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _addItemFromController(controller),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addItemFromController(TextEditingController controller) {
    final text = controller.text.trim();
    final name = text.isEmpty ? 'Item ${_items.length + 1}' : text;
    setState(() {
      _items.add(name);
      // clear any search so the new item is visible
      _query = '';
      _searchController.clear();
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added "$name"')));
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

class ItemDetailPage extends StatelessWidget {
  final String title;
  final int index;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ItemDetailPage({required this.title, required this.index, required this.isFavorite, required this.onFavoriteToggle, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 40, child: Text('${index + 1}')),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null),
                  onPressed: () {
                    onFavoriteToggle();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isFavorite ? 'Removed from favorites' : 'Added to favorites')));
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text('Detailed description for this item goes here. You can expand this with more content, images, or actions.'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            )
          ],
        ),
      ),
    );
  }
}
