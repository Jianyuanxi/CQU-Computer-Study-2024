
class Solution
{
public:
    vector<vector<int>> threeSum(vector<int> &nums)
    {
        vector<vector<int>> res;
        int n = nums.size();
        if (n < 3)
            return res;

        // 先排序
        sort(nums.begin(), nums.end());

        for (int i = 0; i < n - 2; ++i)
        {
            // 跳过重复元素
            if (i > 0 && nums[i] == nums[i - 1])
                continue;

            int left = i + 1, right = n - 1;
            while (left < right)
            {
                long long sum = (long long)nums[i] + nums[left] + nums[right];
                if (sum == 0)
                {
                    res.emplace_back(vector<int>{nums[i], nums[left], nums[right]});
                    // 跳过重复元素
                    while (left < right && nums[left] == nums[left + 1])
                        left++;
                    while (left < right && nums[right] == nums[right - 1])
                        right--;
                    left++;
                    right--;
                }
                else if (sum < 0)
                    left++;
                else
                    right--;
            }
        }

        return res;
    }
};
