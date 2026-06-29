#include<iostream>
using namespace std;
#include<string>
class student
{public:
	student()
	{
		m_name = 0;           //默认构造函数使其为空指针
		m_age = 12;
	}
	student(char* name, int age)
	{
		m_name = new char[strlen(name)+1];     //动态内存，需要主动定义析构函数释放
		if (m_name != 0)
		{
			strcpy_s(m_name, strlen(name) + 1, name);
		}
		m_age = age;                                   //这种情况下也需要主动写复制构造函数
	}

	void display()
	{
		cout << "name:" << m_name << endl;
		cout << "age:" << m_age << endl;
	}

	~student();//声明析构函数   ~类名（）；
	           //析构函数没有参数，所以必须是上面这种形式。
	student(const student& stu)
	{
		cout << "这里用了复制构造函数" << endl;

		m_age = stu.m_age;           //非指针型成员的复制

		m_name = new char[strlen(stu.m_name) + 1];//先申请堆空间（动态内存）

		if (m_name != 0)
		{
			strcpy_s(m_name, strlen(stu.m_name) + 1, stu.m_name);
		}
	}

	                    



private:
	char* m_name;
	int m_age;
	                     //当有指针型数据成员，并且是动态赋值时，要主动写一个析构函数
};

student::~student()
{
	cout << "这里用了析构函数";
	delete[]m_name;        //在析构函数中释放堆空间（动态内存）

	m_name = 0;
}

int main()
{
	char ch[4] = { 'a','s','d','\0' };

	cout << strlen(ch) << endl;
	student a(ch, 17);

	a.display();

	return 0;


	

}

//一个类只可以有一个析构函数，如果没写，系统会给出一个默认析构函数