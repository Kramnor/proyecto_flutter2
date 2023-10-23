import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getProducts() async {
  List products = [];
  CollectionReference collectionReferenceProducts = db.collection('productos');
  QuerySnapshot queryProducts = await collectionReferenceProducts.get();
  queryProducts.docs.forEach((documento) {
    products.add(documento.data());
  });

  return products;
}

Future<int> getStockValue(String nombre) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('productos')
      .where('nombre', isEqualTo: nombre)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    final currentStock = querySnapshot.docs.first['stock'];
    return currentStock;
  }
  return 0; // Valor predeterminado si no se encuentra el producto
}
