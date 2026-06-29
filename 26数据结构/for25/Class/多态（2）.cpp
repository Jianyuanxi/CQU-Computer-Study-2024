#include <iostream>
using namespace std;
class Point {                                     //定义基类Point类
public:
    Point() { }                                    //Point类构造函数
    virtual ~Point() {
        cout << "executing Point destructor"<< endl;
    }  //Point类析构函数
};
class Circle : public Point 
{                     //定义派生类Circle类
public:
    Circle() 
    {
    

    }                                   //Circle类构造函数
    ~Circle() 
    {
        cout << "executing Circle destructor" << endl;
    } //Circle类析构函数
private:
    int radius;
};
/*int main()
{
    Point* p = new Circle;                        //用new开辟动态存储空间
    delete p;                                     //用delete释放动态存储空间
    return 0;
}*/
/*
p是指向基类的指针变量，指向new开辟的动态存储空间，希望用detele释放p所指向的空间。
但运行结果为（新版VS会报内存冲突错误）
executing Point destructor
表示只执行了基类Point的析构函数，而没有执行派生类Circle的析构函数。如果希望能执行派生类
Circle的析构函数，可以将基类的析构函数声明为虚析构函数，如
virtual ~Point(){
    cout<<″executing Point destructor″<<endl;
}
程序其他部分不改动，再运行程序，结果为
executing Circle destructor
executing Point destructor
*/

/*
如果将基类的析构函数声明为虚函数时，由该基类所派生的所有派生类的析构函数也都自动
成为虚函数，即使派生类的析构函数与基类的析构函数名字不相同。

最好把基类的析构函数声明为虚函数。这将使所有派生类的析构函数自动成为虚函数。这样，
如果程序中显式地用了delete运算符准备删除一个对象，而delete运算符的操作对象用
了指向派生类对象的基类指针，则系统会调用相应类的析构函数。

专业人员一般都习惯声明虚析构函数，即使基类并不需要析构函数，也显式地定义一个函数体为空的虚析构函数，以保证在撤销动态分配空间时能得到正确的处理。

构造函数不能声明为虚函数。这是因为在执行构造函数时类对象还未完成建立过程，当然谈不上函数与类对象的绑定。

*/