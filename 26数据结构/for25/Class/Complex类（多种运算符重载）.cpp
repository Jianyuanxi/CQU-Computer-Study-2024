#include<iostream>
using namespace std;
class Complex
{
public:
	Complex()
	{
		real = 0;
		imag = 0;
	}
	Complex(double r, double i)
	{
		real = r;
		imag = i;
	}
	void display()
	{
		cout << "(" << real << "," << imag << "i" << ")" << endl;
	}

	//算术运算符重载
	friend Complex operator+(const Complex& c1, const Complex& c2);
	friend Complex operator-(const Complex& c1, const Complex& c2);
	friend Complex operator*(const Complex& c1, const Complex& c2);
	friend Complex operator/(const Complex& c1, const Complex& c2);

	//输入输出流运算符重载
	friend istream& operator>>(istream& sin, Complex& r); //输入流不要写const Complex&r，因为
	                                                      //输入流是要写入值
	                                                      //是改变数据成员的值的
	friend ostream& operator<<(ostream& sout,const Complex& r);
	                                                      //输出流要写cosnt,因为不改变值

	//关系运算符重载
	bool operator==(const Complex& c1)const;//重载为成员函数，调用的对象占用一个运算数
	bool operator!=(const Complex& c1)const;


	//单目运算符重载
	Complex operator++();               //前置++
	Complex operator++(int);            //后置++
	Complex operator--();               //前置--
	Complex operator--(int);            //后置--
	/*重载单目运算符的方法与重载双目运算符的方法是类似的。但由于单目运算符只有一个操作数，
	因此运算符重载函数只有一个参数，如果运算符重载函数作为成员函数，则还可省略此参数。
    */
	/*同时，C++约定，在自增(自减)运算符重载函数中，增加一个int型形参，就是后置自增(自减)运
	算符函数。*/
private:
	double real;
	double imag;
};
Complex operator+(const Complex& c1, const Complex& c2)
{
	Complex c;
	c.real = c1.real + c2.real;
	c.imag = c1.imag + c2.imag;
	return c;
}
Complex operator-(const Complex& c1, const Complex& c2)
{
	Complex c;
	c.real = c1.real - c2.real;
	c.imag = c1.imag - c2.imag;
	return c;
}
Complex operator*(const Complex& c1, const Complex& c2)
{
	Complex c;
	c.real = c1.real * c2.real-(c1.imag*c2.imag);
	c.imag = c1.real* c2.imag+c2.real*c1.imag;
	return c;
}//复数乘法
Complex operator/(const Complex& c1, const Complex& c2)
{
	Complex c;
	c.real = c1.real / c2.real;
	c.imag = c1.imag / c2.imag;
	return c;

	//复数是没有除法的，姑且这么自定义一个运算，无实际意义。
}


istream& operator>> (istream& sin, Complex& r)
{
	sin >> r.real >> r.imag;
	return sin;
}
ostream& operator<<(ostream& sout, const Complex& r)
{
	sout << r.real << " + " << r.imag <<"i";
	return sout;

}

bool Complex::operator==(const Complex&c1)const
{
	return (real == c1.real && imag == c1.imag);
}
bool Complex::operator!=(const Complex& c1)const
{
	return (real != c1.real && imag != c1.imag);
	
}

Complex Complex::operator++()
{
	real++;
	imag++;
	return *(this);
}
Complex Complex::operator++(int)
{
	Complex temp(*this); //调用系统自带的默认复制构造函数进行初始化

	real++;
	imag++;
	return temp;       //返回递加之前的对象。
}
int main()
{
	Complex a;
	cin >> a;
	cout << a;

	return 0;
}
/*
重载运算符可以使用成员函数和非成员函数，但是，为什么=,(),[],->只能用成员函数进行重载？
因为编译器会提供一个默认的赋值运算符，你如果把自己定义赋值运算符的写成友元的话，函数的参数列表不一样，不会发生重载；所以编译器禁止了这种行为。
C++规定赋值运算符“=”只能重载为类的非静态成员函数，而不可以重载为类的友元函数。不能重载为类的静态成员应该比较容易理解，因为静态成员函数是属于整个类的，不是属于某个对象的，它只能去操作类静态数据成员。而赋值运算符“=”是基于 对象操作的。

*/