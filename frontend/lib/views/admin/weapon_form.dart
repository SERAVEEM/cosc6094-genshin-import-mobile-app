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
  final _bannerController = TextEditingController();
  final _showcase1Controller = TextEditingController();
  final _showcase2Controller = TextEditingController();
  final _showcase3Controller = TextEditingController();
  final _ratingsController = TextEditingController();
  final _dmgController = TextEditingController();
  final _critRateController = TextEditingController();
  final _critDmgController = TextEditingController();
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
      _bannerController.text = widget.weapon!.banner;
      _showcase1Controller.text = widget.weapon!.showcase1;
      _showcase2Controller.text = widget.weapon!.showcase2;
      _showcase3Controller.text = widget.weapon!.showcase3;
      _ratingsController.text = widget.weapon!.ratings;
      _dmgController.text = widget.weapon!.dmg;
      _critRateController.text = widget.weapon!.critRate;
      _critDmgController.text = widget.weapon!.critDmg;
    } else {
      _imageController.text = 'default_weapon.png';
      _bannerController.text = 'assets/Product/mistsplitter Banner.png';
      _showcase1Controller.text = 'assets/Product/Missplitter showcase.png';
      _showcase2Controller.text = 'assets/Product/mistsplitter Banner.png';
      _showcase3Controller.text = 'assets/Product/Missplitter showcase2.png';
      _ratingsController.text = '5.0';
      _dmgController.text = '0';
      _critRateController.text = '0%';
      _critDmgController.text = '0%';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _bannerController.dispose();
    _showcase1Controller.dispose();
    _showcase2Controller.dispose();
    _showcase3Controller.dispose();
    _ratingsController.dispose();
    _dmgController.dispose();
    _critRateController.dispose();
    _critDmgController.dispose();
    super.dispose();
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
      'banner': _bannerController.text.trim(),
      'showcase1': _showcase1Controller.text.trim(),
      'showcase2': _showcase2Controller.text.trim(),
      'showcase3': _showcase3Controller.text.trim(),
      'ratings': _ratingsController.text.trim(),
      'dmg': _dmgController.text.trim(),
      'crit_rate': _critRateController.text.trim(),
      'crit_dmg': _critDmgController.text.trim(),
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
                initialValue: _selectedType,
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
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _bannerController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Banner Filename/URL',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Banner URL/Filename cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _showcase1Controller,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Showcase Image 1 Filename/URL',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Showcase Image 1 cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _showcase2Controller,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Showcase Image 2 Filename/URL',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Showcase Image 2 cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _showcase3Controller,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Showcase Image 3 Filename/URL',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Showcase Image 3 cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _ratingsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Ratings (e.g. 5.0)',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ratings cannot be empty';
                  }
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed < 0.0 || parsed > 5.0) {
                    return 'Ratings must be between 0.0 and 5.0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _dmgController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'DMG (e.g. 250)',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'DMG cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _critRateController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Critical Rate (e.g. 44.1%)',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Critical Rate cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.space4),

              TextFormField(
                controller: _critDmgController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Critical Damage (e.g. 88.2%)',
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Critical Damage cannot be empty';
                  }
                  return null;
                },
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
