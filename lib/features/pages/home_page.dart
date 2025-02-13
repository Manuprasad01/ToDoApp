import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../controller/category_provider.dart';
import '../controller/user_provider.dart';
import 'settings_page.dart';
import 'task_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 10,
                  backgroundImage: userProvider.imageFile != null
                      ? FileImage(userProvider.imageFile!)
                      : const AssetImage('assets/default_profile.jpg')
                          as ImageProvider,
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CategorySearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quote Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/default_profile.jpg'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '"The memories is a shield and life helper."',
                        style: TextStyle(
                            fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .where('userId',
                      isEqualTo: user?.uid) // User-specific categories
                  .snapshots(),
              builder: (context, snapshot) {
                final categories = snapshot.data?.docs ?? [];

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.isEmpty ? 1 : categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () => _addCategoryDialog(context),
                        child: const Card(
                          child:
                              Center(child: Icon(Icons.add_circle, size: 40)),
                        ),
                      );
                    }

                    final category = categories[index - 1];
                    final categoryId = category.id;
                    final categoryName = category['name'];
                    final categoryEmoji = category['emoji'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TasksPage(
                                categoryId: categoryId,
                                categoryName: categoryName),
                          ),
                        );
                      },
                      onLongPress: () =>
                          _deleteCategoryDialog(context, categoryId),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(categoryEmoji,
                                  style: const TextStyle(fontSize: 30)),
                              const SizedBox(height: 8),
                              Text(categoryName,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 4),
                              FutureBuilder<int>(
                                future: _getTaskCount(categoryId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("Loading...",
                                        style: TextStyle(fontSize: 14));
                                  }
                                  return Text(
                                    "${snapshot.data ?? 0} tasks",
                                    style: const TextStyle(fontSize: 14),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addCategoryDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    TextEditingController nameController = TextEditingController();
    TextEditingController emojiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(hintText: 'Enter category name')),
            TextField(
                controller: emojiController,
                decoration: const InputDecoration(hintText: 'Enter emoji')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emojiController.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('categories').add({
                  'name': nameController.text,
                  'emoji': emojiController.text,
                  'userId': user?.uid, // Store user ID for filtering
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCategoryDialog(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('categories')
                  .doc(categoryId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<int> _getTaskCount(String categoryId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.size;
  }
}

class CategorySearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => "Search categories...";

  @override
  Widget buildSuggestions(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final filteredCategories = categoryProvider.categories
        .where((category) =>
            category['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildCategoryList(context, filteredCategories);
  }

  @override
  Widget buildResults(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final filteredCategories = categoryProvider.categories
        .where((category) =>
            category['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildCategoryList(context, filteredCategories);
  }

  Widget _buildCategoryList(BuildContext context, List categories) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TasksPage(
                  categoryId: category['id'],
                  categoryName: category['name'],
                ),
              ),
            );
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(category['emoji'], style: TextStyle(fontSize: 30)),
                SizedBox(height: 8),
                Text(category['name'], style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
}
