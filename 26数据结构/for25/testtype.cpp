#include <bits/stdc++.h>
#define endl '\n'     // 使用 endl 会使输出变慢，所以用#define 将其替换，注意没有分号
#define int long long // 定义 int 为 long long 类型，方便使用
using namespace std;
typedef long long ll;       // 定义 long long 为 ll，方便使用
typedef pair<int, int> PII; // 定义 pair<int, int> 为 PII，方便使用

struct node // 定义一个结构体 node
{
    int x, y;                          // 结构体内有两个变量 x 和 y
    node(int x, int y) : x(x), y(y) {} // 结构体的构造函数，初始化 x 和 y
};

signed main() // 使用 signed main() 代替 int main()，因为 int main() 会报错（#define int long long了）
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    return 0;
}
