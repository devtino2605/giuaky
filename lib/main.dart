import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'service/product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Sử dụng cấu hình tạo ra từ 'flutterfire configure'
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("DỮ LIỆU SẢN PHẨM"),
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
                                fallbackHeight: 100,
                                fallbackWidth: 100,
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
