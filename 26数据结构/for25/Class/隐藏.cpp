/*
同名成员
如果子类和父类中有同名成员，子类成员将屏蔽对父类同名成员的直接访问，这种情况叫隐藏
（但在子类成员函数中，可以使用父类::父类成员来显式地进行访问）。
*/
#include<iostream>
using namespace std;
class A
{
	
public:
		
	int a;
	virtual void display()
	{
		cout << a << endl;
		cout << "调用了A的display()" << endl;
	}

	A()
	{
		a = 0;

	}
	A(int x)
	{
		a = x;
	}

};
class B :public A
{
public:
	int a;
	void display()
	{
		cout << a << endl;
		cout << "调用了B的display()" << endl;
	}

	B() :A()
	{
		a = 0;
	}
	B(int n) :A(n)
	{
		a = n;
	}
};

int main()
{
	A a1(1);
	B a2(2);
	a2.display();
	a1.display();
}
/*
（1）如果派生类的函数与基类的函数同名，但是参数不同。此时，不论有无virtual关键字，
基类的函数将被隐藏（注意与重载区别）。
（2）如果派生类的函数与基类的函数同名，并且参数也相同，但是基类函数没有virtual关键字。
此时，基类的函数被隐藏。

*/