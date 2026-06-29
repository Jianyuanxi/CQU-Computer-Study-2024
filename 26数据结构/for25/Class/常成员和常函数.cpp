#include <iostream>
using namespace std;
class Complex  //Complex类定义             //即复数类
{
public:
	Complex() { real = 0; imag = 0; }   //默认构造函数
	Complex(double r, double i)   //构造函数重载
	{
		real = r; imag = i;
	}
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
void Complex::display() 
{         //定义输出函数
    cout << "(" << real << "," << imag << "i)" << endl;
}
class Circle        //圆类
{
public:
    Circle(int r, int a) :m_r(2), m_a(a)       //()内可以是前面的参数，也可以是其他的值。
    {
        //花括号不可以少，不然不算是函数了
        //常数据成员只能通过初始化列表来获得初值
        //普通成员也能在初始化列表中赋值
    }
    void display()
    {
        cout << "m_r:" << m_r << " " << "m_a:" << m_a << endl;
    }

private:
    int m_r;
    const int m_a;
    
};

int main() {
    Complex c1(3, 4), c2(5, -10), c3;  //定义3个复数对象
    c3 = c1.add(c2);               //调用复数相加函数
    cout << "c1 = "; c1.display();    //输出c1的值
    cout << "c2 = "; c2.display();    //输出c2的值
    cout << "c1 + c2 = "; c3.display(); //输出c3的值

    Circle qwer(234, 1234);
    qwer.display();
    Complex const c4(1, 1);    //c4是一个常对象
    //这样，在所有的场合中，对象t1中的所有成员的值都不能被修改。

    return 0;
}
/*在定义对象时指定对象为常量对象。常量对象必须要有初值
定义常量对象的一般形式为
     
    类名 const 对象名(实参表列);               //被const的是这个对象
  const 类名 对象名(实参表列);
*/
/*
如果一个对象被声明为常量对象，则不能调用该对象的非const型的成员函数(构造函数和析构函数除外)，例如：
Complex const complex(1.2, 3.4); //complex是常量对象
complex.display( );  //调用常量对象complex的非const成员函数，违反语法
*/
/*如果只是想引用而不改变常对象的数据成员的值，只需要把成员函数定义为const就行，
如：
void display( )const; //将函数声明为const
*/
/*
常成员函数
类成员函数使用const关键字修饰，称为常成员函数
语法格式：返回值类型说明符  函数名(参数表) const；
常成员函数具有以下特点:
const是函数类型的一个组成部分，在函数实现时也要带const关键字
常成员函数不能更新对象的数据成员，也不能调用该类中的非常成员函数         
常对象只能调用常成员函数，但是常成员函数可以被普通对象调用
const关键字可被用于参与对重载函数的区分
例如：在类中这样声明是对print函数的有效重载
            void print();
            void print() const;                                                                             
*/



/*
常数据成员
使用const说明的数据成员称为常数据成员
常数据成员一经初始化就不能再被改变
构造函数对常数据成员进行初始化，只能通过初始化列表
初始化列表
是在构造函数的函数头后面，用“：”连接的一组参数表
形式为：类名::类名(参数表):初始化列表
                {
                //函数体
                }
初始化列表的形式为：成员名1(初始值), 成员名2(初始值), …
*/
/*
//普通成员也能在初始化列表中赋值
*/