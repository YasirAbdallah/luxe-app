import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/model/product_model.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  AddProductPageState createState() => AddProductPageState();
}

class AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductController _productController = Get.put(ProductController());

  String? _name;
  String? _description;
  final Map<String, double> _sizePrices = {};
  List<XFile> selectedMedia = [];
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int _currentImageIndex = 0;
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    List<XFile>? pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      List<CroppedFile> croppedImages =
          await _productController.cropImages(pickedImages);
      List<XFile> convertedImages =
          croppedImages.map((croppedFile) => XFile(croppedFile.path)).toList();
      setState(() {
        selectedMedia.addAll(convertedImages);
      });
    }
  }

  void _deleteImage(int index) {
    setState(() {
      selectedMedia.removeAt(index);
    });
  }

  void _addSizePrice() {
    if (_sizeController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        _sizePrices[_sizeController.text] = double.parse(_priceController.text);
        _sizeController.clear();
        _priceController.clear();
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && selectedMedia.isNotEmpty) {
      if (_sizePrices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى إضافة حجم وسعر واحد على الأقل.'),
          ),
        );
        return;
      }

      _formKey.currentState!.save();

      Product product = Product(
        id: '',
        name: _name!,
        description: _description!,
        sizePrices: _sizePrices,
        imageUrls: [],
      );

      setState(() {
        _isLoading = true;
      });

      try {
        await _productController.addProduct(product, selectedMedia);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إضافة المنتج. حاول مرة أخرى.')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار صورة واحدة على الأقل.'),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الانتظار حتى يتم إضافة المنتج.'),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('إضافة منتج'),
          backgroundColor: Colors.green[100],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    selectedMedia.isEmpty
                        ? Container()
                        : SizedBox(
                            height: 300,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  itemCount: selectedMedia.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.file(
                                            File(selectedMedia[index].path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.black45),
                                            child: IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  color: Colors.white),
                                              onPressed: () =>
                                                  _deleteImage(index),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      selectedMedia.length,
                                      (index) => Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 2.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == index
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        onPressed: _pickImages,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[200],
                            shape: const ContinuousRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                            foregroundColor: Colors.black),
                        child: const Text('اختيار صور'),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'الاسم',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              textDirection: TextDirection.rtl,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال الاسم';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _name = value;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(
                                labelText: 'الوصف',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال الوصف';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _description = value;
                              },
                              maxLines: 15, // عدد الأسطر الأقصى
                              minLines: 1, // الحد الأدنى من الأسطر
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              textDirection: TextDirection.rtl,
                              controller: _sizeController,
                              decoration: const InputDecoration(
                                hintTextDirection: TextDirection.rtl,
                                labelText: 'الحجم',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              textDirection: TextDirection.rtl,
                              controller: _priceController,
                              decoration: const InputDecoration(
                                hintTextDirection: TextDirection.rtl,
                                alignLabelWithHint: true,
                                labelText: 'السعر',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: _addSizePrice,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[200],
                                  shape: const ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                  foregroundColor: Colors.black),
                              child: const Text('إضافة حجم وسعر'),
                            ),
                            const SizedBox(height: 16.0),
                            if (_sizePrices.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الأحجام والأسعار:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8.0),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _sizePrices.length,
                                    itemBuilder: (context, index) {
                                      String size =
                                          _sizePrices.keys.elementAt(index);
                                      double price = _sizePrices[size]!;
                                      return ListTile(
                                        title: Text('$size: $price'),
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[200],
                                  shape: const ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                  foregroundColor: Colors.black),
                              child: const Text('إضافة المنتج'),
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
  }
}
