"""
=========================================================================
Task 1: 基于GUID计算Caesar密码密钥k (Python版本)
=========================================================================
功能说明：
    本程序通过两个组员的GUID计算加密密钥k
    计算方法：将两个GUID相加，然后反复将各位数字相加，直到结果<=25
=========================================================================
"""

def calculate_key_from_guids(guid1, guid2):
    """
    根据两个GUID计算Caesar密码密钥k

    参数：
        guid1: 第一个组员的GUID
        guid2: 第二个组员的GUID

    返回：
        k: 计算得到的密钥值（0-25之间）
    """
    # 步骤1：计算两个GUID的和
    sum_guids = guid1 + guid2
    print(f"GUID1 + GUID2 = {sum_guids}")

    # 步骤2：将和的各位数字相加
    result = sum(int(digit) for digit in str(sum_guids))
    print(f"First digit sum = {result}")

    # 步骤3：如果结果>25，继续将各位数字相加
    while result > 25:
        result = sum(int(digit) for digit in str(result))
        print(f"Continuing digit sum = {result}")

    return result


def main():
    """主函数：演示密钥计算过程"""
    # 定义两个组员的GUID
    guid1 = 2720906  # 第一个组员的GUID
    guid2 = 2720746  # 第二个组员的GUID

    # 计算密钥k
    k = calculate_key_from_guids(guid1, guid2)

    print(f"\nThe key value k is: {k}")

    # 显示计算过程说明
    print("\n" + "=" * 60)
    print("Calculation process:")
    print(f"guid1 + guid2 = {guid1} + {guid2} = {guid1 + guid2}")
    print("5+4+4+1+6+5+2 = 27 (>25, continue)")
    print("2+7 = 9 (<=25, stop)")
    print("Therefore k = 9")
    print("=" * 60)


if __name__ == "__main__":
    main()
