import 'package:flutter/material.dart';

class InputControlsDemo extends StatefulWidget {
  const InputControlsDemo({super.key});

  @override
  State<InputControlsDemo> createState() => _InputControlsDemoState();
}

class _InputControlsDemoState extends State<InputControlsDemo> {
  double _sliderValue = 50.0;
  bool _switchValue = false;
  int _radioValue = 1;
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    // [EX 5 - Lỗi số 4]: Gọi hàm showDatePicker ở đây rất an toàn
    // vì nó nằm trong _InputControlsDemoState, biến "context" luôn tồn tại và hợp lệ.
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      // [EX 5 - Lỗi số 3]: Bắt buộc phải có setState.
      // Nếu không có, biến _selectedDate có đổi nhưng màn hình vẫn hiện "Chưa chọn ngày".
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 4 - Bài 2: Bảng Điều Khiển'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // [EX 5 - Lỗi số 2]: Nếu xoá SingleChildScrollView đi,
        // lật ngang màn hình sẽ bị trào sọc vàng đen dưới đáy.
        // Bọc vào để biến Column tĩnh thành một màn hình vuốt được.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Trượt để chọn âm lượng:', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _sliderValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: _sliderValue.round().toString(),
                onChanged: (value) {
                  // [EX 5]: Cập nhật UI ngay lập tức khi vuốt
                  setState(() => _sliderValue = value);
                },
              ),

              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('2. Kích hoạt chế độ VIP', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _switchValue,
                onChanged: (value) {
                  // [EX 5]: Cập nhật UI khi bấm công tắc
                  setState(() => _switchValue = value);
                },
              ),

              const SizedBox(height: 10),
              const Text('3. Chọn gói cước:', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<int>(
                title: const Text('Gói Cơ bản'),
                value: 1,
                groupValue: _radioValue,
                onChanged: (value) {
                  setState(() => _radioValue = value!);
                },
              ),
              RadioListTile<int>(
                title: const Text('Gói Nâng cao'),
                value: 2,
                groupValue: _radioValue,
                onChanged: (value) {
                  setState(() => _radioValue = value!);
                },
              ),

              const SizedBox(height: 10),
              const Text('4. Chọn ngày hết hạn:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickDate,
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

              const Text('THÔNG TIN BẠN VỪA THIẾT LẬP:', style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('- Âm lượng: ${_sliderValue.round()}', style: const TextStyle(fontSize: 16)),
              Text('- Chế độ VIP: ${_switchValue ? "ĐANG BẬT" : "ĐANG TẮT"}', style: const TextStyle(fontSize: 16)),
              Text('- Gói cước: ${_radioValue == 1 ? "Cơ bản" : "Nâng cao"}', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
