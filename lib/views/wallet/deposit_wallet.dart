import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/currency_format.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/wallet_viewmodel.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  double selectedAmount = 0.0;
  final List<String> amounts = ["100000", "200000", "500000", "1000000", "2000000", "5000000"];
  int selectedIndex = -1;
  String selectedPaymentMethod = "Chuyển khoản ngân hàng"; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletViewModel>(context, listen: false).fetchWallet();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletViewModel = Provider.of<WalletViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Nạp tiền vào Rentshare"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWalletCard(walletViewModel.walletData?.balance ?? 0.0),
              const SizedBox(height: 20),
              const Text("Chọn số tiền nạp", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildAmountGrid(),
              const SizedBox(height: 15),
             TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                onChanged: (val) {
                  setState(() => selectedIndex = -1); 
                },
                decoration: InputDecoration(
                  hintText: "Nhập số tiền khác",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPaymentMethod("Chuyển khoản ngân hàng", 'https://res.cloudinary.com/dxrjtaap/image/upload/v1783342727/bank_ufofbl.jpg'),
              _buildPaymentMethod("Ví MoMo", 'https://res.cloudinary.com/dxrjtaap/image/upload/v1783342734/momo_ekwtqp.jpg'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: walletViewModel.isLoading 
                    ? null 
                    : () async {
                        double finalAmount = _amountController.text.isNotEmpty 
                            ? double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0
                            : selectedAmount;
                        if (finalAmount > 0) {
                            bool success = await walletViewModel.depositMoney(finalAmount);
                            if (success) {
                                setState(() { selectedIndex = -1; _amountController.clear(); });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nạp thành công!"),backgroundColor: Color(0xff1B8A4B)));
                            }
                        } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn hoặc nhập số tiền"), backgroundColor: Color(0xff1B8A4B)));
                        }
                      },
                  child: walletViewModel.isLoading 
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          ),
                          SizedBox(width: 10),
                          Text("Đang nạp tiền..."), 
                        ],
                      )
                    : const Text("Nạp tiền", style: TextStyle(fontSize: 18)),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Số dư Rentshare", style: TextStyle(color: Colors.white70)),
          Text('${FormatUtils.formatMoney(balance)}đ', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAmountGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.5, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: amounts.length,
      itemBuilder: (context, index) => OutlinedButton(
        onPressed: () {
          setState(() {
            selectedIndex = index;
            _amountController.clear(); 
            selectedAmount = double.parse(amounts[index].replaceAll(RegExp(r'[^0-9]'), ''));
          });
        },
       style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
        ),
        backgroundColor: selectedIndex == index ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        side: BorderSide(color: selectedIndex == index ? Colors.blue : Colors.grey.shade300),
      ),
        child: Text(FormatUtils.formatMoney(double.parse(amounts[index]))),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12), 
      ),
      child: RadioListTile(
        contentPadding: EdgeInsets.zero, 
        secondary: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Image.network(
            imageUrl, width: 30, height: 30,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment)),
        ),
        title: Text(title),
        value: title, 
        groupValue: selectedPaymentMethod, 
        onChanged: (val) {
          setState(() {
            selectedPaymentMethod = val.toString(); 
          });
        },
      ),
      
    );
  }

  double get amountToDeposit {
    if (_amountController.text.isNotEmpty) {
      return double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    }
    return selectedAmount; 
  }
}