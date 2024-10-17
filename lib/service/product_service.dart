import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      if (existingProduct.exists) {
        String? existImageUrl = existingProduct['image'];

        if (imagePath == null) {
          imageUrl = existImageUrl!;
        } else {
          if (existImageUrl != null) {
            try {
              Reference imageRef =
                  FirebaseStorage.instance.refFromURL(existImageUrl);
              await imageRef.delete();
            } catch (e) {
              print("Lỗi khi xóa hình ảnh: $e");
            }
          }
        }
      }
    }

    if (imagePath != null && !imagePath.startsWith('http')) {
      File imageFile = File(imagePath);
      String fileName = imagePath.split("/").last + DateTime.now().toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('products/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    } else if (imagePath != null && imagePath.startsWith('http')) {
      imageUrl = imagePath;
    }

    User? user = FirebaseAuth.instance.currentUser;
    String? email;
    if (user != null) {
      email = user.email!;
    }

    if (documentId != null) {
      await FirebaseFirestore.instance
          .collection("Products")
          .doc(documentId)
          .update({
        'name': productName,
        'type': productType,
        'price': productPrice,
        'image': imageUrl,
      });
    } else {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Products').doc(productName);

      Map<String, dynamic> products = {
        'name': productName,
        'type': productType,
        'price': productPrice,
        'image': imageUrl,
        'email': email,
      };

      await documentReference.set(products);
    }
  }

  Future<void> deleteProduct(String documentId) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("Products")
        .doc(documentId)
        .get();
    if (docSnapshot.exists) {
      var productData = docSnapshot.data() as Map<String, dynamic>;

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

    await FirebaseFirestore.instance
        .collection("Products")
        .doc(documentId)
        .delete();
  }
}
