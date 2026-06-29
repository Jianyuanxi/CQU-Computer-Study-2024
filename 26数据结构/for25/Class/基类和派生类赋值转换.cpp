//Person类
class Person
{
public://这里将成员都定义为public便于测试
	string _name = "peter"; // 姓名
	int _age = 18; // 年龄
};

//Student类，学生有名字和年龄，所以用继承复用Person的代码
class Student : public Person
{
public://这里将成员都定义为public便于测试
	int _stuid = 1; // 学号
};

int main()
{
	Student s;//子类
	Person p;//父类

	p = s;//子类对象可以赋值给父类对象
	s = p;//父类对象不能赋值给子类对象
	/*
	子类赋值给父类可以正常编译，父类赋值给子类编译报错。
	*/
	return 0;
}
 
/*
！！！！！！！！！！
切片：
由于子类的成员数量一定大于等于父类的成员数量，所以当一个子类赋值给父类时，子类就可以将属
于与父类的成员赋值给父类，多余的成员由于父类中不含有，所以不用管。也就是将父类的成员切片
出来赋值给父类。
*/
