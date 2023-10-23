import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Crud extends StatefulWidget {
  const Crud({
    Key? key,
  }) : super(key: key);

  @override
  State<Crud> createState() => _HomeState();
}

class _HomeState extends State<Crud> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController categoriaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  late String imageUrl = ''; // Almacenará la URL de la imagen

  _HomeState() {
    // Inicializa los controladores con valores iniciales
    nombreController.text = '';
    categoriaController.text = '';
    descripcionController.text = '';
    precioController.text = '0';
    stockController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker imagePicker = ImagePicker();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu de Productos'),
      ),
      body: FutureBuilder(
        future: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No data available.');
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final document = snapshot.data?[index];
                final nombre = document?['nombre'];
                final precio = document?['precio'];
                final documentId = document?.id;

                return Container(
                  margin:
                      const EdgeInsets.all(10), // Márgenes para cada producto
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100, // Establece el ancho deseado para la imagen
                        height:
                            100, // Establece la altura deseada para la imagen
                        child: Image.network(document?['imageUrl']),
                      ),
                      const SizedBox(
                          width: 10), // Espacio entre la imagen y el texto
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombre),
                          Text('Precio: $precio'),
                          // Agregar botón de edición y eliminación aquí
                          ElevatedButton(
                            onPressed: () {
                              _showEditProductDialog(
                                context,
                                documentId!,
                                nombre,
                                precio,
                                document?['descripcion'],
                                document?['stock'] ?? 0,
                                nombreController,
                                categoriaController,
                                descripcionController,
                                precioController,
                                stockController,
                              );
                            },
                            child: const Text('Editar'),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              showDeleteConfirmationDialog(
                                  context, documentId!);
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Muestra un diálogo o una pantalla para agregar un nuevo producto
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Agregar Producto'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Agrega campos para nombre, categoría, descripción, precio, stock y la imagen
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      TextField(
                        controller: categoriaController,
                        decoration:
                            const InputDecoration(labelText: 'Categoría'),
                      ),
                      TextField(
                        controller: descripcionController,
                        decoration:
                            const InputDecoration(labelText: 'Descripción'),
                      ),
                      TextField(
                        controller: precioController,
                        decoration: const InputDecoration(labelText: 'Precio'),
                      ),
                      TextField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Stock'),
                      ),
                      // Agregar un botón para subir la imagen
                      ElevatedButton(
                        onPressed: () async {
                          final XFile? image = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            // Llama a la función para subir la imagen y guarda la URL en la variable imageUrl
                            String imageUrl = await uploadImage(
                                'nombre_unico_de_la_imagen', File(image.path));
                            setState(() {
                              this.imageUrl = imageUrl;
                            });
                          }
                        },
                        child: const Text('Subir Imagen'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Llama a la función para agregar el producto a Firebase
                      addProduct(
                        nombreController.text,
                        categoriaController.text,
                        descripcionController.text,
                        int.parse(precioController.text),
                        int.parse(stockController.text),
                        imageUrl,
                      );
                      // Cierra el diálogo
                      Navigator.of(context).pop();
                    },
                    child: const Text('Agregar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> addProduct(
  String nombre,
  String categoria,
  String descripcion,
  int precio,
  int stock,
  String imageUrl,
) async {
  final product = {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'nombre': nombre,
    'categoria': categoria,
    'descripcion': descripcion,
    'precio': precio,
    'stock': stock,
    'imageUrl': imageUrl,
  };
  await FirebaseFirestore.instance.collection('productos').add(product);
}

Future<void> editProduct(String productId, String nombre, String categoria,
    String descripcion, int precio, int stock) async {
  final product = {
    'nombre': nombre,
    'categoria': categoria,
    'descripcion': descripcion,
    'precio': precio,
    'stock': stock
  };
  await FirebaseFirestore.instance
      .collection('productos')
      .doc(productId)
      .update(product);
}

Future<void> deleteProduct(String productId) async {
  await FirebaseFirestore.instance
      .collection('productos')
      .doc(productId)
      .delete();
}

Future<String> uploadImage(String imagePath, File imageFile) async {
  Reference storageReference = FirebaseStorage.instance.ref().child(imagePath);
  UploadTask uploadTask = storageReference.putFile(imageFile);
  await uploadTask.whenComplete(() {});
  String imageUrl = await storageReference.getDownloadURL();
  return imageUrl;
}

Future<List<DocumentSnapshot>> getProducts() async {
  final products =
      await FirebaseFirestore.instance.collection('productos').get();
  return products.docs; // Devuelve una lista de DocumentSnapshot
}

Future<void> showDeleteConfirmationDialog(
    BuildContext context, String productId) async {
  return showDialog(
    context: context,
    barrierDismissible:
        false, // Evita que se cierre al tocar fuera del cuadro de diálogo
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar Producto'),
        content:
            const Text('¿Está seguro de que desea eliminar este producto?'),
        actions: [
          TextButton(
            child: const Text('Sí'),
            onPressed: () {
              // Si el usuario hace clic en "Sí", llama a la función para eliminar el producto
              deleteProduct(productId);
              Navigator.of(context).pop(); // Cierra el cuadro de diálogo
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              // Si el usuario hace clic en "No", simplemente cierra el cuadro de diálogo
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showEditProductDialog(
  BuildContext context,
  String productId,
  String initialNombre,
  int initialPrecio,
  String initialDescripcion,
  int initialStock,
  TextEditingController nombreController,
  TextEditingController descripcionController,
  TextEditingController precioController,
  TextEditingController stockController,
  TextEditingController categoriaController,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campos para editar nombre, descripción, precio y stock
              TextField(
                controller: nombreController..text = initialNombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descripcionController..text = initialDescripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: precioController..text = initialPrecio.toString(),
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              TextField(
                controller: stockController..text = initialStock.toString(),
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              int? precio = int.tryParse(precioController.text);
              int? stock = int.tryParse(stockController.text);

              if (precio != null && stock != null) {
                // El texto ingresado es un número válido, ahora puedes usar precio y stock.
                // Llama a la función para editar el producto aquí.
                editProduct(
                    productId,
                    nombreController.text,
                    categoriaController.text,
                    descripcionController.text,
                    precio,
                    stock);

                // Cierra el diálogo
                Navigator.of(context).pop();
              } else {
                // El texto ingresado no es un número válido, muestra un mensaje de error o toma la acción adecuada.
                print('Precio y stock deben ser números válidos.');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}
