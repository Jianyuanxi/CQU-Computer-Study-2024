#include <iostream>
#include <vector>
#include <math.h>
#include <map>
#include <algorithm>
using namespace std;
int isPrime(int x)
{
    for (int i = 2; i <= sqrt(x); i++)
        if (x % i == 0)
            return 1;
    return 2;
}
int main()
{
    int left, right, t, sum, flag = 0, appear[10001] = {0};
    map<int, int> link;
    cin >> left >> right;
    for (int i = left; i <= right; i++)
    {
        t = i;
        vector<int> road;
        while (t != 1)
        {
            sum = 0;
            do
                sum += pow(t % 10, 2);
            while (t /= 10); // 各位数求平方和
            t = sum;
            if (find(road.begin(), road.end(), sum) != road.end())
                break;
            road.push_back(sum);
            appear[t] = 1; // 标记出现过的数
        }
        if (t == 1)
            link[i] = road.size(); // 存储辛福数
    }
    for (auto &it : link)
        if (!appear[it.first] && ++flag) // 排除非独立的幸福数
            cout << it.first << " " << isPrime(it.first) * it.second << endl;
    if (!flag)
        cout << "SAD" << endl;
    return 0;
}