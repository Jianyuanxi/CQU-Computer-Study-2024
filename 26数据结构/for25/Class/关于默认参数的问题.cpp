#include<iostream>
using namespace std;
#include<string>
int main()
{
	void func(string a, int b = 2);
	//void func(string a);
	//func("asdf");     //这样就不可以，因为对于第一个和第二个函数，参数列表实际上是一样的，所以造成了
					  //二义性
	void func(string a, int b );

	int func(string a, int b);

	func("asdf");

	func("asdf",234);
	return 0;
}
void func(string a, int b = 2)
{
	cout << a << " " << b << endl;
	cout << "这是void func(string a, int b = 2)" << endl;
}
/*void func(string a)
{
	cout << a << endl;
	cout << "这是void func(string a)" << endl;
}*/
void func(string a, int b)
{
	cout << a << " " << b << endl;
	cout << "这是void func(string a, int b)" << endl;
}

/*
“先定义，后调用” ，则应在函数定义中指定默认值； “先调用，后定义” ，则函数调用之前需要有函数声明，此时必须在函数声明中给出默认值，在函数定义时就不要给出默认值了（因为如果在函数声明和函数定义时都给出默认值，有的C++编译系统会给出“重复指定默认值” 的报错信息）。
*/