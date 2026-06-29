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
    ~Person()
    {
        cout << "调用了~Person()" << endl;
    }
    Person(const Person& s) :m_strName(s.m_strName), m_chSex(s.m_chSex)
    {
        cout << "调用了Person类的复制构造函数" << endl;
    }

    Person& operator=(const Person& p)
    {
        if (this != &p)       //防止自己赋值给自己;
        {
            cout << "Person& operator=(const Person& p)" << endl;
            m_strName = p.m_strName;
            m_chSex = p.m_chSex;
        }
        return *this;
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
    Student() :Person()
    {
        m_strNum = "";
        m_strSchool = "";

    }
    Student(string name, char sex, string num, string school);
    /*
    注意：派生类构造函数在类外面定义时，类体中只写该函数的声明:
    Student(string name, char sex, string num, string school);
    派生类构造函数作声明时，不包括基类构造函数名及其参数表列
    调用基类构造函数时，可以不从派生类构造函数的总参数表中传递过来，而直接使用常量或全局       
    变量，如:Student(string name, char sex, string num, string school)
                 :Person(“Zhang”, ‘M’)
     可以用参数初始化表对派生类中的数据成员进行初始化，如:
Student(string name, char sex, string num, string school)
    :Person(name, sex), m_strNum(num), m_strSchool(school){}
    //                ！注意，基类构造函数和参数初始化表之间这里是逗号

    */


    ~Student()
    {
        cout << "调用了~Student()" << endl;
    }

    Student(const Student& s) :Person(s), m_strNum(s.m_strNum), m_strSchool(s.m_strSchool)
    {
        cout << "调用了Student类的复制构造函数" << endl;
    }
    //子类赋值运算符重载
  
    Student& operator=(const Student& s)//子类的operator=必须要显式调用父类的operator=完成
                                        //父类的赋值。
    {
        if (this != &s)
        {
            cout << "Student& operator=(const Student& s)" << endl;
            /*注意不能这样写，因为父类的赋值运算符重载被隐藏了，这样写会调用子类的赋值运算
            符重载导致无穷递归、栈溢出
            operator=(s);
            */
            Person::operator=(s);//指定作用域调用父类的赋值运算符重载，直接传s即可（会切片） //就是说多出来的东西不管了
                                 //这上面是调用父类赋值运算符，对父类元素赋值。
 
            m_strNum = s.m_strNum;               //而这两行是逐个对于子类自己的东西进行赋值。                
            m_strSchool = s.m_strSchool;
        }

        return *this;
    }
  
    private:
        string  m_strNum;
        string m_strSchool;
    };

    Student::Student(string name, char sex, string num, string school) :Person(name, sex)
    {
        m_strNum = num;
        m_strSchool = school;
    }
    void Student::displayStu()
    {
        cout << "No." << m_strNum << endl;
        cout << "school:" << m_strSchool << endl;
        cout << "Name:" << getName() << endl;


    }

    int main()
    {
        //Student s1;
        //s1.displayStu();
        Student s2("Li", 'F', "2020", "CQU");
        s2.displayStu();

        Student s3(s2);

        //在子类析构完成后调用父类的析构函数，所以不需要在子类的析构函数中显式地调用父类的
        //析构函数。      
        /*
        派生类的析构函数会在被调用完成后自动调用基类的析构函数清理基类成员。因为这样才能保证
        派生类对象先清理派生类成员再清理基类成员的顺序。
        */
    }
    /*
    在main函数中，建立对象s2时指定了8个实参。它们按顺序传递给派生类构造函数Student的形参。
    然后，派生类构造函数将前面3个传递给基类Person构造函数的形参。

    */

    /*
    在建立一个对象时，执行构造函数的顺序是:
        ①派生类构造函数先调用基类构造函数；
        ②再执行派生类构造函数本身(即派生类构造函数的函数体)。

    在派生类对象释放时，先执行派生类析构函数~Student( )，再执行其基类析构函数~Person( )。

    */

    /*
    派生类的构造函数的一般形式为：
    派生类构造函数名（总参数表列）: 基类构造函数名（参数表列）
    {
        派生类中新增数据成员初始化语句
    }

    */


    /*
    如果另有一个Graduate类由Student类派生出来，那么，
    归纳一下基类和两个派生类的构造函数的写法:
    基类Person的构造函数首部:
    Person(string name,  char sex)
    派生类Student的构造函数首部:
   Student(string name,  char sex, string num, string school)
             :Person(name, id, sex)
    派生类Graduate的构造函数首部:
  Graduate(string name,  char sex, string num, string school, string field)
                  :Student(name, sex, num, school)

    */

    /*
    (1) 当不需要对派生类新增的成员进行任何初始化操作时，派生类构造函数的函数体可以为空，即
    构造函数是空函数，派生类Student构造函数可以改写为；

Student(string name,  char sex, string num, string school)
:Person(name, sex){ }

    */

    /*
    （2） 如果在基类中没有定义构造函数，或定义了没有参数的构造函数，那么在定义派生类构造函
    数时可不写基类构造函数。
    （3）如果在基类的声明中都没有定义带参数的构造函数，而且也不需对派生类自己的数据成员初
    始化，则可以不必显式地定义派生类构造函数。

    */

    /*
    （4）如果在基类的声明中定义了带参数的构造函数，那么就必须显式地定义派生类构造函数，并在
    派生类构造函数中写出基类或子对象类型的构造函数及其参数表。
   （5）如果在基类中既定义无参的构造函数，又定义了有参的构造函数(构造函数重载)，则在定义派
   生类构造函数时，既可以包含基类构造函数及其参数，也可以不包含基类构造函数。

    */