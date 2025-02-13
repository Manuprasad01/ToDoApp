import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/authentication/pages/login_page.dart';
import '../../core/authentication/services/auth.dart';
import '../controller/user_provider.dart';
import 'dark_mode_page.dart';

class SettingsPage extends StatelessWidget {
  Future<void> _pickImage(
      BuildContext context, Function(File?) onImagePicked) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  void _editProfileDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    TextEditingController nameController =
        TextEditingController(text: userProvider.name);
    TextEditingController bioController =
        TextEditingController(text: userProvider.bio);
    TextEditingController locationController =
        TextEditingController(text: userProvider.location);
    File? newImage = userProvider.imageFile;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _pickImage(context, (image) {
                newImage = image;
              }),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: newImage != null
                    ? FileImage(newImage!)
                    : AssetImage('assets/default_profile.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: InputDecoration(labelText: 'Bio'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              userProvider.updateUserProfile(
                newImage,
                bioController.text,
                nameController.text,
                locationController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            children: [
              SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: userProvider.imageFile != null
                                ? FileImage(userProvider.imageFile!)
                                : AssetImage('assets/default_profile.jpg')
                                    as ImageProvider,
                          ),
                          SizedBox(width: 20),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    userProvider.name.isNotEmpty
                                        ? userProvider.name
                                        : 'Your Name',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Text(
                                    userProvider.location.isNotEmpty
                                        ? userProvider.location
                                        : 'Your Location',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ]),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editProfileDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(userProvider.bio.isNotEmpty ? userProvider.bio : 'Your Bio',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              // Divider(),

              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Mode'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DarkMode()));
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Account'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.logout_rounded),
                title: Text('Logout'),
                onTap: () {
                  Auth().signOut();
                  Provider.of<UserProvider>(context, listen: false)
                      .clearUserData();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}
