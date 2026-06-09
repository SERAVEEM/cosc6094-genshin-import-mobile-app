import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/weapon.dart';
import '../../providers/weapon_provider.dart';
import '../shared/error_dialog.dart';

class WeaponFormScreen extends StatefulWidget {
  final Weapon? weapon;

  const WeaponFormScreen({
    super.key,
    this.weapon,
  });

  @override
  State<WeaponFormScreen> createState() => _WeaponFormScreenState();
}

class _WeaponFormScreenState extends State<WeaponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  String _selectedType = 'Sword';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.weapon != null) {
      _nameController.text = widget.weapon!.name;
      _descController.text = widget.weapon!.description;
      _stockController.text = widget.weapon!.stock.toString();
      _priceController.text = widget.weapon!.price.toStringAsFixed(0);
      _imageController.text = widget.weapon!.image;
      _selectedType = widget.weapon!.type;
    } else {
      _imageController.text = 'default_weapon.png';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final provider = Provider.of<WeaponProvider>(context, listen: false);
    final isEdit = widget.weapon != null;

    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'stock': int.parse(_stockController.text),
      'price': double.parse(_priceController.text),
      'image': _imageController.text.trim(),
      'type': _selectedType,
    };

    try {
      if (isEdit) {
        await provider.updateWeapon(widget.weapon!.id, data);
      } else {
        await provider.createWeapon(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Produk diperbarui!' : 'Produk ditambahkan!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.weapon != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Weapon' : 'Add Weapon'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Data produk tidak valid! Pastikan harga dan stok berupa angka positif.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: AppTheme.cardBg,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Product Type',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                items: ['Claymore', 'Sword', 'Catalyst', 'Bow', 'Artifact-Flower']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Data produk tidak valid! Pastikan harga dan stok berupa angka positif.';
                  }
                  final parsed = int.tryParse(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Data produk tidak valid! Pastikan harga dan stok berupa angka positif.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Data produk tidak valid! Pastikan harga dan stok berupa angka positif.';
                  }
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Data produk tidak valid! Pastikan harga dan stok berupa angka positif.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _imageController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Image Filename/URL',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
              ),
              const SizedBox(height: AppTheme.space8),

              _isSaving
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'UPDATE PRODUCT' : 'CREATE PRODUCT',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
