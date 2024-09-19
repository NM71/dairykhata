import 'package:dairykhata/models/milk_type_adapter.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  MilkType _selectedType = MilkType.cow;
  double _quantity = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffece5f3),
      appBar: AppBar(title: const Text('Add Record'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _selectDate,
                  child: Text(
                      'Select Date:  ${DateFormat('dd-MM-yyyy').format(_selectedDate)}'),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              DropdownButtonFormField<MilkType>(
                value: _selectedType,
                onChanged: (MilkType? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                items: MilkType.values.map((MilkType type) {
                  return DropdownMenuItem<MilkType>(
                    value: type,
                    child: Text(type == MilkType.cow ? 'Cow' : 'Buffalo'),
                  );
                }).toList(),
                decoration: InputDecoration(
                    label: const Text('Type'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Quantity (in liters)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    )),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _quantity = double.parse(value!);
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final recordsBox = Hive.box<MilkRecord>('records');
      final newRecord = MilkRecord(_selectedDate, _selectedType, _quantity);
      recordsBox.add(newRecord);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record added successfully')),
      );
    }
  }
}