#include <bits/stdc++.h>
using namespace std;
int main()
{
    // 变量定义
    int integer = 42;
    long int longInt = 1234567890;
    long long int longLongInt = 123456789012345;
    double floating = 3.14159;
    char character = 'A';
    const char *stringLiteral = "Hello, World!";
    unsigned int unsignedInt = 300;

    double scientific = 0.000123;
    double autoFormat = 123456.789;

    // 占位符示例
    cout << "%d: 占位符示例：";
    printf("整数：%d\n", integer);

    cout << "%ld: 占位符示例: ";
    printf("长整数：%ld\n", longInt);

    cout << "%lld: 占位符示例";
    printf("长长整数：%lld\n", longLongInt);

    cout << "%f: 占位符示例";
    printf("浮点数：%f\n", floating);

    cout << "%c: 占位符示例";
    printf("字符：%c\n", character);

    cout << "%s: 占位符示例";
    printf("字符串：%s\n", stringLiteral);

    cout << "%x: 占位符示例";
    printf("十六进制：%x\n", integer);

    cout << "%o: 占位符示例";
    printf("八进制：%o\n", integer);

    cout << "%u: 占位符示例";
    printf("无符号整数：%u\n", unsignedInt);

    cout << "%e: 占位符示例";
    printf("科学计数法：%e\n", scientific);

    cout << "%g: 占位符示例";
    printf("自动格式：%g\n", autoFormat);

    // 修饰符示例
    cout << "\n修饰符示例";

    // 整数的宽度与对齐
    cout << "%5d: 修饰符示例";
    printf("宽度为5的整数：%5d\n", integer);

    cout << "%-5d: 修饰符示例";
    printf("左对齐宽度为5的整数：%-5d\n", integer);

    cout << "%05d: 修饰符示例";
    printf("宽度为5的整数，前面补0：%05d\n", integer);

    cout << "%+d: 修饰符示例";
    printf("带符号整数：%+d\n", integer);

    // 浮点数的宽度与精度
    cout << "%.2f: 修饰符示例";
    printf("保留两位小数的浮点数：%.2f\n", floating);

    cout << "%10.2f: 修饰符示例";
    printf("宽度为10，保留两位小数的浮点数，右对齐：%10.2f\n", floating);

    cout << "%-10.2f: 修饰符示例";
    printf("宽度为10，保留两位小数的浮点数，左对齐：%-10.2f\n", floating);

    cout << "%010.2f: 修饰符示例";
    printf("宽度为10，保留两位小数的浮点数，前面补0：%010.2f\n", floating);

    // 超过指定宽度的示例
    cout;
    cout << "测试超过指定宽度：";
    printf("宽度为5，实际长度为10的整数：%5d\n", 1234567890);
    printf("宽度为5，实际长度为10的浮点数：%5.2f\n", 12345.6789);

    return 0;
}