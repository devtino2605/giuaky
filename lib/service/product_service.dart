import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductService {
  Future<void> createOrUpdateProduct(
      {required String productName,
      required String productType,
      required double productPrice,
      String? imagePath,
      String? documentId}) async {
    String? imageUrl;

    if (documentId != null) {
      DocumentSnapshot existingProduct = await FirebaseFirestore.instance
          .collection('Products')
          .doc(documentId)
          .get();

      if (existingProduct.exists && imagePath == null) {
        imageUrl = existingProduct['image'];
      }
    }

    if (imagePath != null && !imagePath.startsWith('http')) {
      File imageFile = File(imagePath);
      String fileName = imagePath.split("/").last;
      Reference storageRef =
          FirebaseStorage.instance.ref().child('products/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    } else if (imagePath != null && imagePath.startsWith('http')) {
      imageUrl = imagePath;
    }

    if (documentId != null) {
      await FirebaseFirestore.instance
          .collection("Products")
          .doc(documentId)
          .update({
        'name': productName,
        'type': productType,
        'price': productPrice,
        'image': imageUrl
      });
    } else {
      // Thêm sản phẩm mới
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Products').doc(productName);

      Map<String, dynamic> products = {
        'name': productName,
        'type': productType,
        'price': productPrice,
        'image': imageUrl
      };

      await documentReference.set(products);
    }
  }

  Future<void> deleteProduct(String documentId) async {
    // Lấy thông tin sản phẩm
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("Products")
        .doc(documentId)
        .get();
    if (docSnapshot.exists) {
      var productData = docSnapshot.data() as Map<String, dynamic>;

      // Nếu sản phẩm có hình ảnh, xóa hình ảnh từ Firebase Storage
      if (productData['image'] != null) {
        String imageUrl = productData['image'];

        try {
          Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await imageRef.delete();
          print("Hình ảnh đã được xóa thành công");
        } catch (e) {
          print("Lỗi khi xóa hình ảnh: $e");
        }
      }
    }

    // Xóa sản phẩm từ Firestore
    await FirebaseFirestore.instance
        .collection("Products")
        .doc(documentId)
        .delete();
  }
}
