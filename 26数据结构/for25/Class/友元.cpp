/*在一个类中，可以通过关键字friend将外部成员（一般函数，其他类的成员，或其他类）声明为
本类的友元，也就是可以访问本类的私有成员和保护成员的外部成员*/
/*友元类可以位于私有或者共有或者保护部分，其所在的位置无关紧要*/
#include<iostream>
using namespace std;
class Complex  //Complex类定义             //即复数类
{
public:
	Complex() { real = 0; imag = 0; }   //默认构造函数
	Complex(double r, double i)   //构造函数重载
	{
		real = r; imag = i;
	}
	friend class MyFriend;//友元类

	friend void display_s(const Complex& c);

	//声明复数相加函数
	Complex add(const Complex& c2)const;
	void display();             //声明输出函数

private:
	double real;                 //实部
	double imag;                 //虚部
};
Complex Complex::add(const Complex& c2)const          //这是一个常成员函数，
													  //可以被所有对象调用，但是，
													  //不能改变对象的值
													  //const是函数的一部分，定义的时候 
													  //也要写


{
	Complex c;
	c.real = real + c2.real;
	c.imag = imag + c2.imag;
	return c;
}
class MyFriend
{
public:
	void display_f(const Complex& c)
	{
		cout << c.real << "+" << c.imag << "i" << endl;
	}

};
int main()
{
	Complex c1(12, 3);
	MyFriend asdf;
	asdf.display_f(c1);
	display_s(c1);
	return 0;
}
void display_s(const Complex& c)
{
	cout << c.real << "+" << c.imag << "i" << endl;
}


/*
友元关系无法继承，如果需要友元关系需要在父类和子类中都声明。
*/