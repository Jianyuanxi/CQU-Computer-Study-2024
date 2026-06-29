#include<iostream>
using namespace std;
#include<string>
/*
如果函数的形参是类的对象，则在进行函数调用时，将自动调用复制构造函数，
这也是复制构造函数中的形参如果不是对象引用会造成无限循环调用的原因

*/
class student
{
public:
	student()         //主动写的默认构造函数
	{
		m_name = "阿伟";
		m_age = 18;
	}
	student(string name, int age)//含参构造函数
	{
		m_name = name;
		m_age = age;
	}
	void change()
	{
		m_name = "asdfasdf";
		m_age = 345;
	}
	void display()
	{
		cout << "name:" << m_name << endl;
		cout << "age:" << m_age << endl;
	}
	//student(const student& stu);    //复制构造函数
private:
	string m_name;
	int m_age;


};

/*student::student(const student& stu)
{
	m_name = stu.m_name;
	m_age = stu.m_age;
	cout << "这里是复制构造函数" << endl;
}*/

int main()
{
	student a("阿斌", 23);
	student b = a;
	//cout << "这是赋值之前的b" << endl;
	//b.display();
	student c;
	c = a;
	cout << "使用了自带的赋值运算符"<<endl;
		cout << "c的值为"<<endl;
		c.display();
	//这里用的不是复制构造函数，而是C++自动重载好的赋值运算符
	cout << "初始化后的b" << endl;
	b.display();
	b.change();
	cout << "b的值改变之后"<<endl;
		b.display();
	cout << "此时a的值" << endl;
	a.display();
	c.change();
	cout << "c的值改变之后" << endl;
	c.display();
	cout << "此时a的值" << endl;
	a.display();
	return 0;



}
/*
* 复制构造函数（也称为拷贝构造函数）
复制构造函数的形参是类的对象的引用
   Clock(const Clock & a){……} 
复制构造函数与原来的构造函数实现了函数的重载。 
自动生成特点
如果在类定义时没有定义复制构造函数，系统会生成默认的复制构造函数。
默认的复制构造函数完成所有数据成员的复制
何时会自动执行复制构造函数：
1.通过“=”初始化对象时,
2.对象作为函数的参数，函数调用时,
3.函数返回对象时.

*/
/*当一个对象已经存在，
来初始化另一个新对象时，
（Point c=a;） 会调用拷贝构造函数。

当两个对象都已经存在，
实现赋值时，（a=b; ）
是通过赋值运算符重载，不调用拷贝构造函数。

2.两者相同点是

都是实现数据元素的一一对应复制，都是浅复制
即，有指针时，只是复制出一个指针指向同一个内存单元，在释放时会出现释放两次的问题，造成内存泄露。
*/