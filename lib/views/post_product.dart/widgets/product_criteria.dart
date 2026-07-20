import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/home_viewmodel.dart';

class CriteriaPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).fetchCriteria();
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tiêu chí kiểm duyệt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            Text("Sản phẩm của bạn sẽ được duyệt dựa trên các tiêu chí sau:"),
            SizedBox(height: 15),
            
            // Lắng nghe ViewModel
            Consumer<HomeViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) return CircularProgressIndicator();
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: vm.criteriaList.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final item = vm.criteriaList[index];
                    return ListTile(
                      leading: Icon(Icons.info_outline, color: Colors.blue),
                      title: Text(item.criteriaName, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.description),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}