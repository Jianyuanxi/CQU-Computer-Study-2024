#include <string>
#include <vector>
#include <unordered_map>

using namespace std;

class Solution
{
public:
    int distinctSubseqII(string S)
    {
        const int MOD = 1e9 + 7;
        int n = S.size();
        vector<long long> dp(n + 1, 0);
        dp[0] = 1; // 空子序列

        unordered_map<char, int> last; // 记录每个字符最后一次出现的位置

        for (int i = 1; i <= n; ++i)
        {
            dp[i] = (2 * dp[i - 1]) % MOD;
            char c = S[i - 1];
            if (last.find(c) != last.end())
            {
                dp[i] = (dp[i] - dp[last[c] - 1] + MOD) % MOD;
            }
            last[c] = i;
        }

        // 减去空子序列
        return (dp[n] - 1 + MOD) % MOD;
    }
};
