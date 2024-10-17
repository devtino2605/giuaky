import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/services.dart';

import '.././../service/product_service.dart';
import '../../service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService authService = AuthService();
  late String productName, productType;
  late double productPrice;

  String? updateDocumentId;
  bool isUpdate = false;

  String? imagePath;

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productTypeController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();

  final ProductService _productService = ProductService();

  getProductName(productName) {
    this.productName = productName;
  }

  getProductType(productType) {
    this.productType = productType;
  }

  getProductPrice(productPrice) {
    this.productPrice = productPrice;
  }

  createProduct() async {
    await _productService.createOrUpdateProduct(
      productName: productName,
      productType: productType,
      productPrice: productPrice,
      imagePath: imagePath,
      documentId: isUpdate ? updateDocumentId : null,
    );
    resetForm();
  }

  deleteProduct(documentId) async {
    await _productService.deleteProduct(documentId);
  }

  preparaUpdate(Map<String, dynamic> product, String documentId) {
    setState(() {
      productName = product['name'];
      productType = product['type'];
      productPrice = product['price'];
      imagePath = product['image'];

      updateDocumentId = documentId;
      isUpdate = true;

      productNameController.text = productName;
      productTypeController.text = productType;
      productPriceController.text = productPrice.toString();
    });
  }

  resetForm() {
    setState(() {
      productName = '';
      productType = '';
      productPrice = 0.0;
      updateDocumentId = null;
      isUpdate = false;

      productNameController.clear();
      productTypeController.clear();
      productPriceController.clear();

      imagePath = null;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickerFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickerFile != null) {
      setState(() {
        imagePath = pickerFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = authService.getCurrentUser();
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the Home object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("DỮ LIỆU SẢN PHẨM"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.logout(context);
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: TextFormField(
              controller: productNameController,
              decoration: InputDecoration(
                  labelText: "Tên sản phẩm",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  )),
              onChanged: (String name) {
                getProductName(name);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextFormField(
              controller: productTypeController,
              decoration: InputDecoration(
                  labelText: "Loại sản phẩm",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  )),
              onChanged: (String type) {
                getProductType(type);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextFormField(
                controller: productPriceController,
                decoration: InputDecoration(
                    labelText: "Giá",
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    )),
                onChanged: (String price) {
                  double priceChange = double.parse(price);
                  getProductPrice(priceChange);
                }),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _pickImage,
              child: Text('Chọn Hình Ảnh'),
            ),
          ),
          if (imagePath != null)
            if (imagePath!.startsWith("http"))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(
                  imagePath!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Placeholder(
                      fallbackHeight: 100,
                      fallbackWidth: 100,
                    );
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.file(
                  File(imagePath!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
          ElevatedButton(
              onPressed: () {
                createProduct();
              },
              child: Text(
                isUpdate ? "CẬP NHẬT SẢN PHẨM" : "THÊM SẢN PHẨM",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.blue,
              )),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("Products").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Something went wrong"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No data found"),
                  );
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;

                    final documentId = products[index].id;
                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (product['image'] != null)
                              Image.network(product['image']!,
                                  height: 60.0, width: 60.0, fit: BoxFit.cover)
                            else
                              Placeholder(
                                fallbackHeight: 60,
                                fallbackWidth: 60,
                              ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tên sp: ${product['name']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text('Loại sp: ${product['type']}'),
                                Text('Giá sp: ${product['price'].toString()}'),
                              ],
                            )),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.yellow, width: 1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.yellow,
                                    onPressed: () {
                                      preparaUpdate(product, documentId);
                                    },
                                  ),
                                ),
                                // SizedBox(width: 8.0),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.red, width: 1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () async {
                                      final shouldDelete = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Xác nhận"),
                                              content: Text(
                                                  "Bạn có chắc muốn xóa sản phẩm này không"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () => {
                                                          Navigator.of(context)
                                                              .pop(false),
                                                        },
                                                    child: Text('Hủy')),
                                                TextButton(
                                                    onPressed: () => {
                                                          Navigator.of(context)
                                                              .pop(true),
                                                        },
                                                    child: Text('Đồng ý'))
                                              ],
                                            );
                                          });

                                      if (shouldDelete) {
                                        deleteProduct(documentId);
                                      }
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Expanded(
          //   child: ListView.builder(
          //     itemCount: products.length,
          //     itemBuilder: (context, index) {
          //       final product = products[index];
          //       return Card(
          //         margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //         child: Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Row(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               // Image.network(product['image']!,
          //               //     height: 60.0, width: 60.0, fit: BoxFit.cover),
          //               SizedBox(
          //                 width: 8.0,
          //               ),
          //               Expanded(
          //                   child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     'Tên sp: ${product['name']}',
          //                     style: TextStyle(
          //                         fontWeight: FontWeight.bold, fontSize: 16),
          //                   ),
          //                   Text('Loại sp: ${product['type']}'),
          //                   Text('Giá sp: ${product['price']}'),
          //                 ],
          //               )),
          //               Column(
          //                 children: [
          //                   Container(
          //                     decoration: BoxDecoration(
          //                       border:
          //                           Border.all(color: Colors.yellow, width: 1),
          //                       borderRadius: BorderRadius.circular(8.0),
          //                     ),
          //                     child: IconButton(
          //                       icon: Icon(Icons.edit),
          //                       color: Colors.yellow,
          //                       onPressed: () {
          //                         print("object");
          //                         showData();
          //                       },
          //                     ),
          //                   ),
          //                   // SizedBox(width: 8.0),
          //                   Container(
          //                     decoration: BoxDecoration(
          //                       border: Border.all(color: Colors.red, width: 1),
          //                       borderRadius: BorderRadius.circular(8.0),
          //                     ),
          //                     child: IconButton(
          //                       icon: Icon(Icons.delete),
          //                       color: Colors.red,
          //                       onPressed: () {},
          //                     ),
          //                   )
          //                 ],
          //               )
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}
