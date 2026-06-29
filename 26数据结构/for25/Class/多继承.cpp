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
class Student : public Person
{
public:
    string getNum() { return m_strNum; }
    string getSchool() { return m_strSchool; }
    void setNum(string num) { m_strNum = num; }
    void setSchool(string school) { m_strSchool = school; }
    void displayStu();

    Student(string name, char sex, string num, string school) :Person(name, sex)
    {
        m_strNum = num;
        m_strSchool = school;
   }

    Student() :Person()
    {
        m_strNum = "123";
        m_strSchool = "CQU";
    }
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
class Teacher/*
             在原来类的基础上再声明一个教师(Teacher)类。它和一个学生(Student)类都是
             研究生(Graduate)类的父类。

             */
{
public:
    Teacher(string title);
    Teacher()
    {
        m_strTitle = "无";
    }
    string getTitle() { return m_strTitle; }
    void setTitle(string titlte) { m_strTitle = titlte; }
    void displayTech();
private:
    string m_strTitle;
};
Teacher::Teacher(string title)
{
    m_strTitle = title;
}
void Teacher::displayTech()
{
    cout << "title:" << m_strTitle << endl;
}
class Graduate : public Student,public Teacher
{
public:
    Graduate(string name, char sex, string num, string school, string field, string title);
    Graduate() :Student(), Teacher()
    {
        m_strField = "无";
    }
    string getField() { return m_strField; }
    void setField(string field) { m_strField = field; }
    void displayGra()
    {
       
            displayStu();
            cout << "Field:" << m_strField << endl;
            displayTech();        //Teacher类输出函数
        

    }
private:
    string m_strField;
};
Graduate::Graduate(string name, char sex, string num, string school, string field, string title):Student(name, sex, num, school),Teacher(title)
{
    m_strField = field;
}


int main()
{
    Graduate g("Li", 'F', "2020", "CQU", "Big date", "Pro.");
    g.displayGra();
}




/*
如果已声明了类A、类B和类C，可以声明多重继承的派生类D:

    class D:public A, private B, protected C
    {
        类D新增加的成员
    }

D是多重继承的派生类，它以公用继承方式继承A类，以私有继承方式继承B类，以保护继承方式继承C类。
D按不同的继承方式的规则继承A,B,C的属性，确定各基类的成员在派生类中的访问权限。

*/

/*
多重继承派生类的构造函数一般形式如下:
    派生类构造函数名(总参数表列): 基类1构造函数(参数表列), 基类2构造函数(参数表列), 基类3构
    造函数 (参数表列)
 {
    派生类中新增数成员据成员初始化语句
  }
注意：
各基类的排列顺序任意。
派生类构造函数的执行顺序同样为: 先调用基类的构造函数，再执行派生类构造函数的函数体。调用基
类构造函数的顺序是按照声明派生类时基类出现的顺序。


*/