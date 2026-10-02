import 'package:flutter/material.dart';

class InputControlsDemo extends StatefulWidget {
  const InputControlsDemo({super.key});

  @override
  State<InputControlsDemo> createState() => _InputControlsDemoState();
}

class _InputControlsDemoState extends State<InputControlsDemo> {
  // BỘ NHỚ CỦA TIVI (Lưu trữ các giá trị người dùng nhập vào)
  double _sliderValue = 50.0;
  bool _switchValue = false;
  int _radioValue = 1;
  DateTime? _selectedDate;

  // HÀM MỞ LỊCH (Dùng Future y như bài Lab 2)
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Ngày mặc định khi mở lên
      firstDate: DateTime(2000),   // Năm nhỏ nhất
      lastDate: DateTime(2100),    // Năm lớn nhất
    );
    
    // Nếu người dùng có chọn ngày (không bấm Cancel)
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 4 - Exercise 2 – Input Widgets'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============ 1. SLIDER (THANH TRƯỢT) ============
            const Text('1. Trượt để chọn âm lượng:', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 100,
              label: _sliderValue.round().toString(),
              onChanged: (value) {
                // Thần chú setState: Cập nhật biến và ra lệnh vẽ lại màn hình!
                setState(() {
                  _sliderValue = value;
                });
              },
            ),

            // ============ 2. SWITCH (CÔNG TẮC BẬT/TẮT) ============
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('2. Kích hoạt chế độ VIP', style: TextStyle(fontWeight: FontWeight.bold)),
              value: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                });
              },
            ),

            // ============ 3. RADIO (CHỌN 1 TRONG NHIỀU) ============
            const SizedBox(height: 10),
            const Text('3. Chọn gói cước:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<int>(
              title: const Text('Gói Cơ bản'),
              value: 1, // Trị giá của nút này là 1
              groupValue: _radioValue, // Đang so sánh với bộ nhớ
              onChanged: (value) {
                setState(() => _radioValue = value!);
              },
            ),
            RadioListTile<int>(
              title: const Text('Gói Nâng cao'),
              value: 2, // Trị giá của nút này là 2
              groupValue: _radioValue,
              onChanged: (value) {
                setState(() => _radioValue = value!);
              },
            ),

            // ============ 4. DATE PICKER (CHỌN NGÀY) ============
            const SizedBox(height: 10),
            const Text('4. Chọn ngày hết hạn:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickDate, // Gọi hàm mở lịch
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Mở Lịch'),
                ),
                const SizedBox(width: 15),
                Text(
                  _selectedDate == null
                      ? 'Chưa chọn ngày'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),

            const Divider(height: 40, thickness: 2),

            // ============ MÀN HÌNH HIỂN THỊ KẾT QUẢ ============
            const Text('THÔNG TIN BẠN VỪA THIẾT LẬP:', style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('- Âm lượng (Slider): ${_sliderValue.round()}', style: const TextStyle(fontSize: 16)),
            Text('- Chế độ VIP: ${_switchValue ? "ĐANG BẬT" : "ĐANG TẮT"}', style: const TextStyle(fontSize: 16)),
            Text('- Gói cước: ${_radioValue == 1 ? "Cơ bản" : "Nâng cao"}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
