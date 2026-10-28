import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../products/product_cubit.dart';
import '../products/product_model.dart';
import 'splash_screen.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _quantity;

  final List<String> _categories = ['Electronics', 'Clothing', 'Food', 'Other'];

  late String _category;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _name = TextEditingController(text: product?.name ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _price = TextEditingController(text: product?.price.toString() ?? '');
    _quantity = TextEditingController(text: product?.quantity.toString() ?? '');

    _category = product?.category ?? 'Electronics';

    if (!_categories.contains(_category)) {
      _category = 'Other';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _quantity.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: stocklyOrange, width: 1.5),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final cubit = context.read<ProductCubit>();
      final price = double.parse(_price.text.trim());
      final quantity = int.parse(_quantity.text.trim());

      if (_isEditing) {
        await cubit.updateProduct(
          product: widget.product!,
          name: _name.text,
          description: _description.text,
          category: _category,
          price: price,
          quantity: quantity,
        );
      } else {
        await cubit.addProduct(
          name: _name.text,
          description: _description.text,
          category: _category,
          price: price,
          quantity: quantity,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Product updated successfully.'
                : 'Product added successfully.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 125,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEE7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: stocklyOrange,
                            size: 42,
                          ),
                          SizedBox(height: 8),
                          Text('Product Information'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _name,
                      decoration: _decoration(
                        'Product Name',
                        Icons.label_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name is required.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _description,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _decoration(
                        'Description',
                        Icons.description_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _decoration(
                        'Category',
                        Icons.category_outlined,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _decoration(
                        'Price (USD)',
                        Icons.attach_money,
                      ),
                      validator: (value) {
                        final number = double.tryParse(value?.trim() ?? '');

                        if (number == null || !number.isFinite || number < 0) {
                          return 'Enter a valid non-negative price.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      decoration: _decoration('Quantity', Icons.numbers),
                      validator: (value) {
                        final number = int.tryParse(value?.trim() ?? '');

                        if (number == null || number < 0) {
                          return 'Enter a valid non-negative quantity.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: stocklyOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _saving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isEditing ? 'Save Changes' : 'Add Product',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
