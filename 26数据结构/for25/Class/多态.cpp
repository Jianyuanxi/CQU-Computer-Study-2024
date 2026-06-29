#include<iostream>
using namespace std;
#include<string>
class Person
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
    //定义Person类对象p
    Person p("Li", 'F');
    //定义Student类对象s
    Student s("Wang", 'M', "20220001", "CQU");
    //定义指向基类对象的指针变量pt
    Person* pt = &p;
    pt->display();
    pt = &s;
    pt->display();
    return 0;
}



/*

在类的继承层次结构中，在不同的层次中可以出现名字相同、参数个数和类型都相同而功能不同的函数

编译系统按照函数隐藏的原则决定调用的对象。
如用Student类的对象s.display( )调用的是派生类Student中的成员函数display( )
要调用基类Person中的display函数，应当为: s.Person::display( )
用这种方法来区分两个同名的函数，不够方便
多态性分为两类:
静态多态性：函数重载和运算符重载，在程序编译时系统就能决定函数的调用关系，又称编译时的
多态性。
动态多态性：动态多态性是通过虚函数(virtual function)实现，是在程序运行过程中才动态地确
定函数的调用。又称运行时的多态性。

虚函数：！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

在基类用virtual声明成员函数为虚函数
可以在派生类中重新定义此函数，为它赋予新的功能
可以通过基类的指针或引用方便地调用虚函数
在类外定义虚函数时，不必再加virtual
在派生类中重新定义此函数，
虚函数重新定义要求：函数名、类型、参数全部与基类的虚函数相同
根据派生类的需要重新定义函数体
当一个成员函数被声明为虚函数后，其派生类中的同名函数都自动成为虚函数。
在派生类重新声明该虚函数时，可以加virtual，也可以不加
习惯上一般在每一层声明该函数时都加virtual，使程序更加清晰
如果在派生类中没有对基类的虚函数重新定义，则派生类简单地继承其直接基类的虚函数。
定义一个指向基类对象的指针变量，并使它指向同一类族中需要调用该函数的对象
通过该指针变量调用此虚函数，此时调用的就是指针变量指向的对象的同名函数

*/

/*
使用虚函数时，有两点要注意:
只有类的成员函数才能被声明虚函数，即虚函数只用于类的继承层次结构中
一个成员函数被声明为虚函数后，在同一类族中的类就不能再定义一个该虚函数同名、同类型和同参数
同名非虚函数

使用虚函数，系统要有一定的额外空间开销
当一个类带有虚函数时，编译系统会为该类构造一个虚函数表(virtual function table，
简称vtable)，它是一个指针数组，存放每个虚函数的入口地址
系统在进行动态关联时的时间开销是很少的，因此，多态性是高效的。

先看成员函数所在的类是否会作为基类，再看成员函数在类的继承后有无可能被更改功能。如果希望更
改其功能的，一般应该将它声明为虚函数，否则不要把它声明为虚函数
应考虑对成员函数的调用是通过对象名还是通过基类指针或引用去访问，如果是通过基类指针或引用去
访问的，则应当声明为虚函数
有时，在定义虚函数时，并不定义其函数体，即函数体是空的。它的作用只是定义了一个虚函数名，具
体功能留给派生类去添加（注意，这里还不是纯虚函数）

*/