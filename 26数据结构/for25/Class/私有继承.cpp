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
    void display()
    {
        cout << "name:" << m_strName << endl << "sex : " << m_chSex << endl;
    }
private:
    string m_strName;
    char m_chSex;
};
class Student : private Person
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
    // 类的公有成员display()（它现在是派生类的私有成员）
    display();
    //也可以调用getName（）函数
    cout << "Name:" << getName() << endl;


}

int main()
{
    Student a;
   // a.display();            //已经是派生类的私有成员无法在类外通过对象调用了
    a.displayStu();
   // cout << "Name:" << a.getName() << endl;

}
/*

（1）不能通过派生类对象引用从私有基类继承过来的任何成员(如s.getName())。
（2）派生类的成员函数不能访问私有基类的私有成员，但可以访问私有基类的公用成员
(如displayStu()函数可以调用基类的公用成员函数display()，但不能引用基类的私有成员m_strName)。

*/

/*
在声明一个派生类时将基类的继承方式指定为private的，称为私有继承，用私有继承方式建立的派生类
称为私有派生类(private derived class) ，其基类称为私有基类(private base class)。
基类的公有成员和保护成员在派生类中成了私有成员，其私有成员仍为基类私有（派生类无法访问）。

*/