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
class Student : protected Person
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
    //a.display();            //基类的共有成员，是派生类的受保护成员，无法在派生类外通过派生  
                            //类的对象访问
    a.displayStu();
    //cout << "Name:" << a.getName() << endl;

}
/*
* 受保护成员：
由protected声明的成员称为受保护的成员，或简称保护成员。
受保护的成员不能被类的外部函数访问，但是可以被派生类访问。

*受保护继承：
在定义一个派生类时将基类的继承方式指定为protected的，称为保护继承，用保护继承方式建立的派生
类称为保护派生类(protected derived class)，其基类称为受保护的基类(protected base class)，简
称保护基类。
基类的公有成员和保护成员在派生类中成了保护成员，其私有成员仍为基类私有（派生类无法访问）。

*/