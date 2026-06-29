#include<iostream>
using namespace std;
/*
类A和类B是类N的派生类，类N中有成员a和display，而类A，类B和类C中都没有同名成员a和display。
C是A和B的派生类
*/
class N
{

public:

	int number;

	void display()
	{
		cout << number << endl;
	}

	N()
	{
		number = 0;
	}

	N(int n)
	{
		number = n;
	}
};
class A :virtual public N
{

public:
	int a;
	void showa()
	{
		cout << a << endl;
	}

	A() :N()
	{
		a = 0;

	}

	A(int x, int y) :N(x)
	{
		a = y;
	}
};

class B :virtual public N
{

public:
	int b;
	void showb()
	{
		cout << b << endl;
	}

	B() :N()
	{
		b = 0;

	}

	B(int x, int y) :N(x)
	{
		b = y;
	}
};

class C :public A, public B
{
public:
	int c;
	void showc()
	{
		cout << c << endl; 

	}

	C() :A(), B()
	{
		c = 0;
	}
	C(int m_number, int m_a, int m_b, int m_c) :A(m_number,m_a), B(m_number,m_b),N(m_number)
	{
		c = m_c;
	}
};

/*
为了避免C从A，B中分别继承一次它们继承过来的N的成员导致内存浪费，
可以将类A的基类声明为虚基类，方法如下：
class N                           //声明基类A
 {…};
class A :virtual public N   //声明类A是类N的公用派生类，N是A的虚基类
 {…};
class B :virtual public N     //声明类B是类N的公用派生类，N是B的虚基类
 {…};
声明虚基类的一般形式为：
class 派生类名: virtual 继承方式 基类名
注意：
虚基类并不是在声明基类时声明的，而是在声明派生类时，指定继承方式时声明的。


如果类A被声明为虚基类，那么当基类通过多条派生路径被一个派生类继承时，该派生类只继承该
基类一次，即类D中的成员如下：
需要注意:
为了保证虚基类在派生类中只继承一次，应当在该基类的所有直接派生类中声明为虚基类。
否则仍然会出现对基类的多次继承。
！！！！！注意是直接派生类



如果在虚基类中定义了带参数的构造函数，而且没有定义默认构造函数，则在其所有派生类
(包括直接派生或间接派生的派生类)中，通过构造函数的初始化表对虚基类进行初始化。


*/