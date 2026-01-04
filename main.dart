import 'package:flutter/material.dart';

// 1. 全域購物車邏輯
class CartProvider {
  static final List<Map<String, String>> items = [];
  static double get totalPrice => items.fold(0, (sum, item) => sum + double.parse(item['price']!));
}

void main() {
  runApp(const FlowerShopApp());
}

class FlowerShopApp extends StatelessWidget {
  const FlowerShopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home:HomePage(),
    );
  }
}
// --- 1. 首頁 ---
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void refresh() => setState(() {}); // 用於從子頁面返回時刷新購物車數量

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('花漾生活'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${CartProvider.items.length}'),
              child: Icon(Icons.shopping_cart),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage())).then((_) => refresh()),
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildCategory(context, '客製化花束', Icons.local_florist, Colors.pink[50]!, CustomFlowerPage()),
          _buildCategory(context, '多肉植物', Icons.grass, Colors.green[50]!, ProductListPage(title: '多肉植物')),
          _buildCategory(context, '精選盆栽', Icons.wb_sunny, Colors.orange[50]!, ProductListPage(title: '精選盆栽')),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, IconData icon, Color color, Widget nextStep) {
    return Card(
      color: color,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => nextStep)).then((_) => refresh()),
      ),
    );
  }
}

// --- 2. 客製化花束頁 ---
class CustomFlowerPage extends StatefulWidget {
  @override
  _CustomFlowerPageState createState() => _CustomFlowerPageState();
}

class _CustomFlowerPageState extends State<CustomFlowerPage> {
  // 1. 擴充花材清單，加入圖片與價格
  final List<Map<String, dynamic>> flowerMaterials = [
    {'name': '紅玫瑰', 'price': 50, 'img': 'https://images.unsplash.com/photo-1548610762-658a93bf4f32?w=200'},
    {'name': '向日葵', 'price': 40, 'img': 'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?w=200'},
    {'name': '粉鬱金香', 'price': 60, 'img': 'https://images.unsplash.com/photo-1520323232431-31121c0b2131?w=200'},
    {'name': '滿天星', 'price': 30, 'img': 'https://images.unsplash.com/photo-1508784411316-02b8cd4d3a3a?w=200'},
    {'name': '尤加利葉', 'price': 25, 'img': 'https://images.unsplash.com/photo-1533514114760-4389f5fd2406?w=200'},
    {'name': '繡球花', 'price': 80, 'img': 'https://images.unsplash.com/photo-1501004318641-729e8e2c046e?w=200'},
    {'name': '白百合', 'price': 70, 'img': 'https://images.unsplash.com/photo-1519378058457-4c29a0a2efac?w=200'},
    {'name': '洋桔梗', 'price': 45, 'img': 'https://images.unsplash.com/photo-1563241527-3004b7be0fab?w=200'},
  ];

  // 紀錄被選中的花材
  final Set<int> _selectedIndices = {};

  // 計算總價
  double get _currentTotal {
    return _selectedIndices.fold(0, (sum, index) => sum + flowerMaterials[index]['price']);
  }

  void _confirmSelection() {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('請至少選擇一種花材')));
      return;
    }

    List<String> selectedNames = _selectedIndices.map((i) => flowerMaterials[i]['name'] as String).toList();

    // 加入全域購物車
    CartProvider.items.add({
      'name': '客製花束(${selectedNames.join(", ")})',
      'price': _currentTotal.toString(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('挑選花材自訂花束')),
      body: Column(
        children: [
          // 頂部狀態列
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.pink[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('已選 ${_selectedIndices.length} 種花材', style: TextStyle(fontSize: 16)),
                Text('預計金額: \$${_currentTotal.toInt()}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink)),
              ],
            ),
          ),
          // 花材網格列表
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: flowerMaterials.length,
              itemBuilder: (context, index) {
                final item = flowerMaterials[index];
                final isSelected = _selectedIndices.contains(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) _selectedIndices.remove(index);
                      else _selectedIndices.add(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.pink : Colors.grey[300]!, width: 2),
                      color: isSelected ? Colors.pink[50] : Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(item['img'], fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${item['price']} / 枝', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        if (isSelected) Icon(Icons.check_circle, color: Colors.pink, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 確認按鈕
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _confirmSelection,
              child: Text('完成自訂並加入購物車'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 55),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. 多肉 & 盆栽列表 ---
class ProductListPage extends StatelessWidget {
  final String title;
  ProductListPage({required this.title});

  // 根據傳入的標題（多肉或盆栽）切換不同的商品資料
  List<Map<String, String>> get products {
    if (title == '多肉植物') {
      return [
        {'name': '月兔耳', 'price': '150', 'img': 'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?w=300'},
        {'name': '乙女心', 'price': '120', 'img': 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=300'},
        {'name': '熊童子', 'price': '250', 'img': 'https://images.unsplash.com/photo-1509587584298-0f3b3a3a1797?w=300'},
        {'name': '石頭玉', 'price': '300', 'img': 'https://images.unsplash.com/photo-1520302723644-46526f5a7c2a?w=300'},
        {'name': '姬朧月', 'price': '100', 'img': 'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=300'},
        {'name': '多肉拼盤', 'price': '580', 'img': 'https://images.unsplash.com/photo-1521503862198-2ae9a997bbc9?w=300'},
      ];
    } else {
      // 盆栽資料
      return [
        {'name': '天堂鳥', 'price': '1200', 'img': 'https://images.unsplash.com/photo-1512428813834-c702c7702b78?w=300'},
        {'name': '虎尾蘭', 'price': '450', 'img': 'https://images.unsplash.com/photo-1596547609652-9cf5d8d76921?w=300'},
        {'name': '龜背竹', 'price': '850', 'img': 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=300'},
        {'name': '琴葉榕', 'price': '1500', 'img': 'https://images.unsplash.com/photo-1597055181300-e3633a91731a?w=300'},
        {'name': '黃金葛', 'price': '350', 'img': 'https://images.unsplash.com/photo-1599202860130-f600f4948364?w=300'},
        {'name': '尤加利大盆栽', 'price': '2200', 'img': 'https://images.unsplash.com/photo-1512428559087-560fa5ceab42?w=300'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72, // 調整比例讓圖片與文字更平衡
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final item = products[i];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 圖片區域
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      item['img']!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 文字內容區域
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name']!,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text('\$${item['price']}',
                          style: TextStyle(color: Colors.green[700], fontSize: 14, fontWeight: FontWeight.w600)
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            CartProvider.items.add(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('已加入購物車: ${item['name']}'),
                                  duration: Duration(milliseconds: 800),
                                  behavior: SnackBarBehavior.floating,
                                )
                            );
                          },
                          child: Text('加入購物車'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- 4. 購物車結帳頁 ---
// --- 購物車結帳頁面 (強化刪除功能版) ---
// --- 這是修正後的 CartPage (包含紅色刪除鍵) ---
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的購物車')),
      body: Column(
        children: [
          Expanded(
            child: CartProvider.items.isEmpty
                ? const Center(child: Text('購物車是空的'))
                : ListView.builder(
              itemCount: CartProvider.items.length,
              itemBuilder: (context, i) {
                final item = CartProvider.items[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_cart, color: Colors.pink),
                    title: Text(item['name']!),
                    subtitle: Text('\$${item['price']}', style: const TextStyle(color: Colors.red)),
                    // --- 明確的刪除鍵 ---
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red, size: 30),
                      onPressed: () {
                        setState(() {
                          CartProvider.items.removeAt(i);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // 底部結帳區... (同前一份代碼)
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('總計:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${CartProvider.totalPrice.toInt()}', style: const TextStyle(fontSize: 24, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _finishOrder(),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.pink),
            child: const Text('確認結帳', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _finishOrder() {
    // 1. 檢查購物車是否為空
    if (CartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購物車是空的，請先挑選花卉！')),
      );
      return;
    }

    // 2. 彈出成功對話框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (sContext) => AlertDialog(
        title: const Text('🎉 訂購成功'),
        content: const Text('我們已收到您的訂單，將盡快為您準備！'),
        actions: [
          TextButton(
            onPressed: () {
              // 3. 點擊按鈕後執行：清空資料、關閉彈窗、返回首頁
              setState(() {
                CartProvider.items.clear();
              });
              Navigator.of(sContext).pop(); // 關閉對話框
              Navigator.of(context).pop();   // 返回首頁
            },
            child: const Text('回到首頁'),
          ),
        ],
      ),
    );
  }
}