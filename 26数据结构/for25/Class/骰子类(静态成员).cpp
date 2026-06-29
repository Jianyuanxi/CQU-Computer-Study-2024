/*在公平的赌局中，一个六面骰子投掷的结果是随机且均匀分布的。请设计一个Dice类，使其可以被下
述代码所使用，并产生期望的执行结果（具体数值除外）。
*/
//裁判测试程序样例：
//Project - Dice
#include <iostream>
#include <cstdlib>
using namespace std;

//在此处定义Dice类
class Dice
{
public:
    static int iSides;       //一共有几个面
    static int rollDice();
    static int sideCount(int i); //获取某一面出现的次数
    static int rollCount();      //获取掷骰子的次数
private:

    static int sidecounts[6]; //每个数出现的次数
    static int rollcounts;     //掷骰子的次数
    
};
int Dice::sidecounts[6] = { 0,0,0,0,0,0 }; //静态成员初始化,
int Dice::rollcounts = 0;
int Dice::iSides = 6;
//静态数据成员可以初始化，但只能在类体外进行初始化。初始化时，不用写static
//注意：
/*
1）静态数据成员不属于某个对象，它是在内存上单独开辟空间
2）静态数据成员被该类的每一个对象共享
3）静态数据成员不能在初始化列表进行初始化，只能在类外初始化
4）可以使用类名来引用，也可以通过对象名来引用
5）如果未对静态数据成员赋初值，则编译系统会自动赋予初值0。

*/
int Dice::rollDice()
{
    int randnumber = rand() % (6) + 1;
    rollcounts++;                      //增加掷骰子的次数
    sidecounts[randnumber - 1]++;      //对应面出现的次数增加1
    return randnumber;
    /*如要产生[m, n] 范围内的随机数 num，可用：int num = rand() % (n - m + 1) + m;
    （即 rand() % [区间内数的个数] + [区间起点值]）*/
}
int Dice::sideCount(int i)
{
    return sidecounts[i - 1];//返回i出现的次数
}
int Dice::rollCount()
{
    return rollcounts;
}

int main() {
    srand(0);
    auto d = Dice();

    cout << "-------Roll dice for 1000 times------\n";
    for (auto i = 0; i < 1000; i++) {
        auto r = d.rollDice();
        if (i < 10)
            cout << r << ", ";
    }
    cout << "...\n";

    cout << "------Statistics of rolling the  dice------\n";
    for (int i = 1; i <= Dice::iSides; i++) {
        auto c = d.sideCount(i);
        auto rc = d.rollCount();
        cout << "Side " << i << ": " << c << " / " << rc
            << " = " << 100.0 * c / rc << "%.\n";
    }

    return 0;
}
/*静态数据成员与静态成员函数的区别
静态数据成员的作用是为了对象之间的沟通；
静态成员函数是为了能处理静态数据成员。

静态成员函数与非静态成员函数区别
非静态成员函数有this指针；
静态成员函数没有this指针，因此静态成员函数不能直接访问本类中的非静态成员。
*/

/*静态数据成员的声明及初始化
采用static关键字来声明
静态数据成员是属于类的，可以通过类名对它进行访问
语法格式：类名::标识符
静态数据成员的初始化需要在类的外部进行
类的声明是抽象的，只能声明静态数据成员的存在
*/
/*
静态成员函数：
可以在类声明函数的前面加static，声明静态成员函数。如：
    static int volume( );

静态成员函数是类的一部分，而不是对象的一部分。如果要在类外调用公用的静态成员函数，要用类名和域运算符“∷”。如 ：
    Box∷volume( );

也允许通过对象名调用静态成员函数，如：
    a.volume( );
*/


/*
父类的静态成员在整个类体系中都只有一个，无论下面有多少层继承关系。
*/