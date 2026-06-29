#include <iostream>
using namespace std;
class Complex  //Complex类定义             //即复数类
{
public:
	Complex() { real = 0; imag = 0; }   //默认构造函数
	Complex(double r, double i):real(r), imag(i)   //构造函数重载
	{}
	Complex operator+(Complex&)const;        //重载+运算符，返回值类型为Complex,操作数为
	                                    //两个Complex 类型，调用对现象为其中一个，所以
	                                    //参数只有一个
	//有意思的是，实际上，在函数（运算符重载就是函数重载）声明时不必给出形参名，
	// 而只需要知道形参的类型
	//在函数定义时才需要给出形参名             


	void display()
	{
		cout << real << "+" << imag << "i" << endl;
	}
private:
	double real;                 //实部
	double imag;                 //虚部
};

Complex Complex::operator+(Complex& r)const
{
	Complex c;
	c.real = real + r.real;
	c.imag = imag + r.imag;
	return c;
}
int main()
{
	Complex c1(3, 4), c2(5, -10), c3;
	c3 = c1 + c2;   //运算符+用于复数运算
	//这里的=是系统自动重载的。
	cout << "c1 = "; 
	c1.display();
	cout << "c2 = ";
	c2.display();
	cout << "c1 + c2 = ";
	c3.display();
	return 0;
}

/*
在将运算符+重载为类的成员函数后，C++编译将程序中的表达式c1+c2解释为
		   c1.operator+(c2)
		  
*/




/*运算符重载有以下两种形式：
重载为类的成员函数
形式为：函数类型  operator 运算符（形参表）
			 {
    			函数体；
			 }
重载为类的友元函数
形式为：friend 函数类型  operator 运算符（形参表）
			 {
    			函数体；
			 }


*/
/*
值得注意的是，对于重载为成员函数的，对象本身就是一个操作数，所以形参表内的参数的数目
比实际的操作数少一
*/
/*重载的运算符必须是C++原本就有的运算符，而且是可以重载的运算符*/
/*
* c++中，对于任何一个类，如果没有用户自定义的赋值运算符函数，系统会自动的为其生成一个默认的
赋值运算符函数，以完成数据成员之间的逐位复制。通常情况下，默认的赋值运算符函数可以完成赋值
任务，但在类中含有指针的特殊情况下，就不能直接互相赋值，因为有可能造成指针悬挂。
*/
/*
 注意：
（1）赋值运算符不能重载为友元函数，只能重载为一个非静态成员函数。这是由于考虑了c++的封装性和数据的安全性。
防止外部指令更改private数据成员。
一般而言，用友元函数重载比用成员函数重载更便于使用。
（2）赋值运算符不能被继承。
*/        