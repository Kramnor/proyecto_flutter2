import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crud_firebase/services/firebase_service.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  List<dynamic>? _allProducts;
  List<dynamic>? _filteredProducts;
  Timer? _debounce;
  String _selectedCategory = '';

  void _searchProducts() {
    if (_debounce != null) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _mostrarDetallesProducto(String nombre, int precio, String imageUrl,
      String descripcion, int stock) {
    getStockValue(nombre).then((stock) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(nombre),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(imageUrl, height: 100, width: 100),
                Text('Precio: $precio'),
                Text('Descripción: $descripcion'),
                Text('Stock: $stock'), // Mostrar el stock aquí
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (stock >= 1) {
                    final cartItem = CartItem(
                      nombre: nombre,
                      precio: precio,
                      imageUrl: imageUrl,
                    );
                    cartItems.add(cartItem);
                    Navigator.pop(context); // Cierra el diálogo actual

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Producto agregado al carro'),
                          content: const Text(
                              'El producto se ha agregado al carro de compras.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Cierra el segundo diálogo
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Stock no disponible'),
                          content: const Text(
                              'El producto no tiene stock disponible.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Agregar al carro de compras'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        leadingWidth: double.infinity,
        leading: Stack(
          children: [
            Positioned(
                height: 190,
                width: 190,
                top: -45,
                left: 1,
                child: Image.network(
                  'https://th.bing.com/th/id/OIP.Ll-WOq-RLuJSicBFEcgGjwHaBH?pid=ImgDet&rs=1',
                )),
            Positioned(
              height: 90,
              width: 90,
              top: 5,
              right: -15,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartPage()));
                },
              ),
            ),
            Positioned(
                top: 25,
                left: 190,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: DropdownButton<String>(
                    value: _selectedCategory.isNotEmpty
                        ? _selectedCategory
                        : 'Categorias',
                    onChanged: (String? newValue) {
                      if (newValue == 'Categorias') {
                        newValue = '';
                      }
                      _selectCategory(newValue!);
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'Categorias',
                        child: Text('Categorias'),
                      ),
                      ...(_allProducts
                              ?.map(
                                  (product) => product['categoria'].toString())
                              .toSet()
                              .toList()
                              .map<DropdownMenuItem<String>>((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }) ??
                          []),
                    ],
                  ),
                ))
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No data available.');
            } else {
              _allProducts = snapshot.data;
              _filteredProducts = _allProducts?.where((product) {
                final nombre = product['nombre'].toString().toLowerCase();
                return nombre.contains(_searchTerm.toLowerCase()) &&
                    (_selectedCategory.isEmpty ||
                        product['categoria'].toString().toLowerCase() ==
                            _selectedCategory.toLowerCase());
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _searchProducts();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar productos',
                          contentPadding: EdgeInsets.only(left: 5),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredProducts?.length,
                      itemBuilder: (context, index) {
                        final document = _filteredProducts?[index];
                        final nombre = document['nombre'];
                        final precio = document['precio'];
                        final descripcion = document['descripcion'];
                        final stock = document['stock'];
                        final precioInt = int.tryParse(precio.toString()) ?? 0;
                        final stockInt = int.tryParse(stock.toString()) ?? 0;
                        final imageUrl = document['imageUrl'];
                        return InkWell(
                          onTap: () {
                            _mostrarDetallesProducto(nombre, precioInt,
                                imageUrl, descripcion, stockInt);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(color: Colors.black),
                            ),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  width: 100,
                                  height: 100,
                                  child: Image.network(document?['imageUrl']),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Precio: $precio',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class CartItem {
  final String nombre;
  final int precio;
  final String imageUrl;

  CartItem({
    required this.nombre,
    required this.precio,
    required this.imageUrl,
  });
}

List<CartItem> cartItems = [];

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carro de Compras'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Image.network(item.imageUrl),
                  title: Text(item.nombre),
                  subtitle: Text('Precio: \$${item.precio}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        cartItems.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (cartItems.isNotEmpty) {
                // Resta 1 al stock y actualiza la base de datos
                final FirebaseFirestore _firestore = FirebaseFirestore.instance;

                // Recorre la lista de elementos en el carrito y actualiza el stock
                for (final cartItem in cartItems) {
                  final nombre = cartItem.nombre;

                  _firestore
                      .collection('productos')
                      .where('nombre', isEqualTo: nombre)
                      .get()
                      .then((querySnapshot) {
                    if (querySnapshot.docs.isNotEmpty) {
                      final docId = querySnapshot.docs.first.id;
                      final currentStock = querySnapshot.docs.first['stock'];

                      if (currentStock > 0) {
                        final newStock = currentStock - 1;
                        // Actualiza el stock en la base de datos
                        _firestore
                            .collection('productos')
                            .doc(docId)
                            .update({'stock': newStock}).then((_) {
                          // Después de actualizar el stock, actualiza la interfaz de usuario
                          setState(() {});
                        });
                      }
                    }
                  });
                }
                cartItems.clear(); // Limpiar el carrito
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Compra exitosa'),
                      content: const Text('¡Gracias por tu compra!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Aceptar'),
                        )
                      ],
                    );
                  },
                );

                setState(() {}); // Actualizar la interfaz de usuario
              }
            },
            child: const Text('Comprar Productos'),
          ),
        ],
      ),
    );
  }
}
