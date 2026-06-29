#include <vector>
#include <algorithm>

using namespace std;

class Solution
{
public:
    int lengthOfLIS(vector<int> &nums)
    {
        vector<int> tails; // tails[i] 表示长度为 i+1 的子序列的最小结尾元素
        for (auto num : nums)
        {
            // 使用二分查找找到第一个大于等于 num 的位置
            auto it = lower_bound(tails.begin(), tails.end(), num);
            if (it == tails.end())
            {
                tails.push_back(num); // 如果 num 大于所有 tails 中的元素，追加
            }
            else
            {
                *it = num; // 否则，更新 tails 中对应位置的值
            }
        }
        return tails.size();
    }
};
