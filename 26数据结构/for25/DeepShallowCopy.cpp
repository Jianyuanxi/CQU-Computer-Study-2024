// DeepShallowCopy.cpp
#include <iostream>
#include <string>
using namespace std;

// 浅拷贝示例类
class StudentShallow
{
public:
    // 构造函数
    StudentShallow(string n, int a, int *g) : name(n), age(a), grades(g) {}

    // 默认复制构造函数（浅拷贝）

    void display() const
    {
        cout << "Name: " << name << ", Age: " << age;
        if (grades)
            cout << ", Grades: " << *grades << endl;
        else
            cout << ", Grades: None" << endl;
    }
    // 为了方便，这里都设置为public，实际上应该设置为private
    string name;
    int age;
    int *grades;
};

// 深拷贝示例类
class StudentDeep
{
public:
    // 构造函数
    StudentDeep(string n, int a, int *g) : name(n), age(a)
    {
        if (g)
        {
            grades = new int(*g);
        }
        else
        {
            grades = nullptr;
        }
    }

    // 复制构造函数（深拷贝）
    StudentDeep(const StudentDeep &other) : name(other.name), age(other.age)
    {
        if (other.grades)
        {
            grades = new int(*other.grades);
        }
        else
        {
            grades = nullptr;
        }
    }

    // 赋值运算符重载（深拷贝）
    StudentDeep &operator=(const StudentDeep &other)
    {
        if (this != &other)
        {
            name = other.name;
            age = other.age;
            if (grades)
            {
                delete grades;
            }
            if (other.grades)
            {
                grades = new int(*other.grades);
            }
            else
            {
                grades = nullptr;
            }
        }
        return *this;
    }

    // 析构函数
    ~StudentDeep()
    {
        delete grades;
    }

    void display() const
    {
        cout << "Name: " << name << ", Age: " << age;
        if (grades)
            cout << ", Grades: " << *grades << endl;
        else
            cout << ", Grades: None" << endl;
    }
    // 为了方便，这里都设置为public，实际上应该设置为private
    string name;
    int age;
    int *grades;
};

int main()
{
    int grade1 = 85;
    int grade2 = 90;

    // 浅拷贝示例
    cout << "浅拷贝示例：" << endl;
    StudentShallow s1("Alice", 20, &grade1);
    StudentShallow s2 = s1; // 浅拷贝

    cout << "修改 s2 的成绩到 95" << endl;
    *(s2.grades) = 95;

    cout << "s1: ";
    s1.display();
    cout << "s2: ";
    s2.display();

    // 深拷贝示例
    cout << "\n深拷贝示例：" << endl;
    StudentDeep d1("Bob", 22, &grade2);
    StudentDeep d2 = d1; // 深拷贝

    cout << "修改 d2 的成绩到 100" << endl;
    *(d2.grades) = 100;

    cout << "d1: ";
    d1.display();
    cout << "d2: ";
    d2.display();

    return 0;
}