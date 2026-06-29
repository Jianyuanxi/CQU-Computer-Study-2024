#include <bits/stdc++.h>

using namespace std;

int main()
{

    // 测试1: 展示cin读取带空格的输入
    cout << "使用cin读取字符串(输入含空格的字符串如'hello world')：" << endl;
    string s1;
    cin >> s1; // 只会读取到空格前的部分
    cout << "cin读取结果：" << s1 << endl;
    cin.ignore(numeric_limits<streamsize>::max(), '\n'); // 清空整行

    // 测试2: 展示getline读取整行
    cout << "使用getline读取字符串(输入含空格的字符串)：" << endl;
    string s2;
    getline(cin, s2); // 会读取整行包括空格
    cout << "getline读取结果：" << s2 << endl;

    // 测试3: cin和getline配合
    cout << "输入一个数字：" << endl;
    int n;
    cin >> n;
    // cin.ignore(); // 忽略换行符
    cout << "继续输入一行字符串：" << endl;
    string s3;
    getline(cin, s3);
    cout << "数字是：" << n << endl;
    cout << "字符串是：" << s3 << endl;

    return 0;
}