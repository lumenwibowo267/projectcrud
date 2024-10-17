import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'api.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class TambahForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TambahFormState();
  }
}

class TambahFormState extends State<TambahForm> {
  final formkey = GlobalKey<FormState>();

  TextEditingController nisController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController tpController = TextEditingController();
  TextEditingController tgController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  String? selectedAgama;
  String? selectedKelamin;

  final List<String> agamaList = [
    'Islam', 'Katolik', 'Protestan', 'Hindu', 'Budha', 'Khonghucu'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        tgController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future createSw() async {
    return await http.post(
      Uri.parse(Baseurl.tambah),
      body: {
        "nis": nisController.text,
        "nama": namaController.text,
        "tplahir": tpController.text,
        "tglahir": tgController.text,
        "kelamin": selectedKelamin,
        "agama": selectedAgama,
        "alamat": alamatController.text,
      },
    );
  }

  void _onConfirm(context) async {
    http.Response response = await createSw();
    final data = json.decode(response.body);
    if (data['success']) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Siswa"),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField("NIS", nisController, "Masukkan NIS"),
              SizedBox(height: 16),
              _buildTextField("Nama", namaController, "Masukkan Nama"),
              SizedBox(height: 16),
              _buildTextField("Tempat Lahir", tpController, "Masukkan Tempat Lahir"),
              SizedBox(height: 16),
              _buildDateField(context, "Tanggal Lahir", tgController),
              SizedBox(height: 16),
              _buildRadioKelamin(),
              SizedBox(height: 16),
              _buildDropdownField("Agama", selectedAgama, agamaList),
              SizedBox(height: 16),
              _buildTextField("Alamat", alamatController, "Masukkan Alamat"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (formkey.currentState!.validate()) {
              _onConfirm(context);
            }
          },
          child: Text("Simpan"),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return hint;
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        await _selectDate(context);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Masukkan Tanggal Lahir";
        }
        return null;
      },
    );
  }

  Widget _buildRadioKelamin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jenis Kelamin",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Laki-laki'),
                value: 'Laki-laki',
                groupValue: selectedKelamin,
                onChanged: (String? value) {
                  setState(() {
                    selectedKelamin = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Perempuan'),
                value: 'Perempuan',
                groupValue: selectedKelamin,
                onChanged: (String? value) {
                  setState(() {
                    selectedKelamin = value;
                  });
                },
              ),
            ),
          ],
        ),
        if (selectedKelamin == null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Pilih Jenis Kelamin',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedAgama = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Pilih $label";
        }
        return null;
      },
    );
  }
}
