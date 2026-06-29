#include<iostream>
using namespace std;
#include<string>
class Person
{
public:
    Person()
    { 
        m_strName = "";
        m_chSex ='M'; 
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
    void display()
    {
        cout << "name:" << m_strName << endl << "sex : " << m_chSex<<endl;
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
    void displayStu();
private:
    string m_strNum;
    string m_strSchool;
};
void Student::displayStu()
{
    cout << "No." << m_strNum << endl;
    cout << "school:" << m_strSchool << endl;
    //cout << "name:" << m_strName << endl;
    //这样会报错，因为使用了基类的私有成员。
    //如果希望在displayStu()函数输出Person类的私有数据成员，可以通过在displayStu()中调用基
    // 类的公有成员display()（它也是派生类的公有成员）
    display();
    //也可以调用getName（）函数
    cout << "Name:" << getName() << endl;


}

int main()
{
    Student a;
    a.display();
    a.displayStu();
    cout << "Name:" << a.getName() << endl;

}

/*公用继承：
在定义一个派生类时将基类的继承方式指定为public的，称为公用继承，用公用继承方式建立的派生类
称为公用派生类(public derived class)，其基类称为公用基类(public base class)。
基类的公有成员和保护成员在派生类中保持原有访问属性，其私有成员仍为基类私有。即，基类的公有
成员是派生类的公有成员，基类的受保护成员是派生类的受保护成员，基类的私有成员，派生类无法访
问。

基类private成员无论以什么方式继承到派生类中都是不可见的。这里的不可见是指基类的私有成员还是
被继承到了派生类对象中，但是语法上限制派生类对象不管在类里面还是类外面都不能去访问它。

*/



/*
类的继承(inheritance)是一个新类（子类）从已有的类（父类）那里获得其已有特性；
从另一个角度说，父类产生一个子类，成为类的派生，所以父类又称为基类，子类又称为派生类；
一个父类可以有多个子类，子类又可以派生新的子类。
类的继承可以分为单继承和多重继承.
单继承（single inheritance）是指对于每一个子类都只有一个父类。
多重继承（multiple inheritance）是指对于每一个子类可以有一个或多个父类。

关于基类和派生类的关系，可以表述为: 派生类是基类的具体化，而基类则是派生类的抽象



基类名前面有public的称为“公用继承(public inheritance)”。声明派生类的一般形式为

class 派生类名: ［继承方式］ 基类名
{
    派生类新增加的成员
} ;

继承方式包括: public(公用的),private(私有的)和protected(受保护的)，此项是可选的，即可以不写
继承方式，如果不写，则默认为private(私有的)继承。


*/
/*
构造函数和析构函数不继承
*/