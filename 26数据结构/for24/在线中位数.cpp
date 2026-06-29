#include <queue>

using namespace std;

class MedianFinder
{
private:
    priority_queue<int> maxHeap;                            // 最大堆，存储较小的一半元素
    priority_queue<int, vector<int>, greater<int>> minHeap; // 最小堆，存储较大的一半元素

public:
    MedianFinder()
    {
    }

    void addNum(int num)
    {
        maxHeap.push(num);
        // 将最大堆的堆顶元素移动到最小堆
        minHeap.push(maxHeap.top());
        maxHeap.pop();

        // 保持堆的大小平衡
        if (maxHeap.size() < minHeap.size())
        {
            maxHeap.push(minHeap.top());
            minHeap.pop();
        }
    }

    double findMedian()
    {
        if (maxHeap.size() > minHeap.size())
        {
            return maxHeap.top();
        }
        else
        {
            return ((double)maxHeap.top() + (double)minHeap.top()) / 2.0;
        }
    }
};
