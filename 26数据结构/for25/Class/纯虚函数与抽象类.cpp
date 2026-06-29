/*
* 纯虚函数：！！！！！！！！！！！！！！！！！
纯虚函数是在声明虚函数时被“初始化”为0的函数。声明纯虚函数的一般形式是
        virtual 函数类型 函数名(参数表列)=0;

纯虚函数只有函数的名字而不具备函数的功能，不能被调用
它只是通知编译系统: 在这里声明一个虚函数，留待派生类中定义

在派生类中对此函数提供定义后，才可被调用
纯虚函数的作用是在基类中为其派生类保留一个虚函数接口，以便派生类根据需要对它进行定义
如果在基类中没有保留虚函数接口，则无法实现多态性
如果在一个类中声明了纯虚函数，而在其派生类中没有对该函数定义，则该虚函数在派生类中仍然为
纯虚函数

*/

/*
* 抽象类：！！！！！！！！！！！！！！！！！
如果声明了一个类，一般可以用它定义对象
在面向对象程序设计中，可以定义一种类，不用来生成对象，而只是用来作为基类去建立派生类
它们作为一种基本类型提供给用户，用户在这个基础上根据自己的需要定义出功能各异的派生类，
用这些派生类去建立对象
这种不用来定义对象而只作为一种基本类型用作继承的类，称为抽象类(abstract class)
通常也称为抽象基类(abstract base class)
凡是包含纯虚函数的类都是抽象类
纯虚函数不能被调用，因此包含纯虚函数的类是无法建立对象的
抽象类的作用是作为一个类族的共同基类
为一个类族提供一个公共的接口

*/
#include<iostream>
using namespace std;
#include<string>
class Object
{

public:
    virtual void display() = 0;          //纯虚函数，这使得Object类变成了抽象类
};
class Person:public Object
{
public:
    Person()
    {
        m_strName = "";
        m_chSex = 'M';
    }
    Person(string name, char sex)
    {
        m_strName = name;
        m_chSex = sex;
    }
    string getName()
    {
        return m_strName;
    }
    char getSex()
    {
        return m_chSex;
    }
    void setName(string name)
    {
        m_strName = name;
    }
    void setSex(char sex)
    {
        m_chSex = sex;
    }
    virtual void display()
    {
        cout << "name:" << m_strName << endl << "sex : " << m_chSex << endl;
    }
private:
    string m_strName;
    char m_chSex;
};
class Student : public Person
{
public:
    string getNum() { return m_strNum; }
    string getSchool() { return m_strSchool; }
    void setNum(string num) { m_strNum = num; }
    void setSchool(string school) { m_strSchool = school; }
    virtual void display();
    Student(string name, char sex, string num, string school)
        :Person(name, sex)
    {
        m_strNum = num;
        m_strSchool = school;
    }
    Student() :Person()
    {
        m_strNum = "";
        m_strSchool = "";
    }

private:
    string m_strNum;
    string m_strSchool;
};
void Student::display()
{
    cout << "No." << m_strNum << endl;
    cout << "school:" << m_strSchool << endl;

    Person::display();                        //使用作用域运算符强制指明使用基类的同名函数
    cout << "Name:" << getName() << endl;


}

//主函数
int main()
{
    Object* op;          //定义抽象类Object类的指针
    //定义Person类对象p
    Person p("Li", 'F');
    //定义Student类对象s
    Student s("Wang", 'M', "20220001", "CQU");
    //定义指向基类对象的指针变量pt
    op = &p;             //指向一个Person类的对象
    op->display();
    op = &s;             //指向一个Student类的对象
    op->display();
    return 0;
}
/*
一个类层次结构中当然也可不包含任何抽象类，每一层次的类都是实际可用的具体类
(concrete class)
但是，许多好的面向对象的系统，其层次结构的顶部是一个抽象类，甚至顶部有好几层都是
抽象类
如果在抽象类所派生出的新类中对基类的所有纯虚函数进行了定义，这个派生类就不再是抽
象类，
而是可以用来定义对象的具体类
如果在派生类中没有对所有纯虚函数进行定义，则此派生类仍然是抽象类，不能用来定义对象
虽然抽象类不能定义对象(或者说抽象类不能实例化)，但是可以定义指向抽象类数据的指针
变量
当派生类成为具体类之后，就可以用这种指针指向派生类对象，然后通过该指针调用虚函数，
实现多态性的操作


*/