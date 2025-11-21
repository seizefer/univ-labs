"""
=========================================================================
Task 3: 使用频率分析法破解Caesar密码 (Python版本)
=========================================================================
功能说明：
    利用英文字母频率统计特性破解Caesar密码
    在英文中，字母'e'出现频率最高，通过找到密文中最高频字母
    与'e'的距离，可以估算出密钥k
=========================================================================
"""

from collections import Counter


def caesar_encrypt(plaintext, k):
    """
    Caesar密码加密函数

    参数：
        plaintext: 待加密的明文字符串
        k: 加密密钥（位移量）

    返回：
        ciphertext: 加密后的密文字符串
    """
    plaintext = plaintext.lower()
    ciphertext = ""

    for char in plaintext:
        if char.isalpha():
            encrypted_val = (ord(char) - ord('a') + k) % 26 + ord('a')
            ciphertext += chr(encrypted_val)
        else:
            ciphertext += char

    return ciphertext


def caesar_frequency_analysis(ciphertext):
    """
    使用频率分析破解Caesar密码

    参数：
        ciphertext: 待破解的密文字符串

    返回：
        estimated_k: 估算的密钥值
        decrypted_text: 使用估算密钥解密的结果
    """
    # 统计密文中每个字母出现的次数
    letter_counts = Counter(char.lower() for char in ciphertext if char.isalpha())

    # 找到密文中出现频率最高的字母
    if not letter_counts:
        return 0, ciphertext

    most_common_char = letter_counts.most_common(1)[0][0]

    # 假设最高频字母对应英文中最常见的字母'e'
    # 计算密钥k = 最高频字母 - 'e'
    estimated_k = (ord(most_common_char) - ord('e')) % 26

    # 使用估算的k值进行解密
    decrypted_text = ""
    for char in ciphertext:
        if char.isalpha():
            decrypted_val = (ord(char.lower()) - ord('a') - estimated_k) % 26 + ord('a')
            decrypted_text += chr(decrypted_val)
        else:
            decrypted_text += char

    return estimated_k, decrypted_text


def test_frequency_analysis():
    """
    测试频率分析方法
    使用一段富含字母'e'的测试文本来验证方法的有效性
    """
    # 测试文本（刻意选择包含大量字母'e'的文本）
    plaintext = ("the energetic teacher presented her excellent lesson, "
                 "deeply engaging every eager student, ensuring they "
                 "received exemplary education")
    true_k = 9  # 真实的加密密钥

    # 加密明文
    ciphertext = caesar_encrypt(plaintext, true_k)

    # 显示加密结果
    print("=== Frequency Analysis Test ===")
    print(f"Original text: {plaintext}")
    print(f"True k: {true_k}")
    print(f"Ciphertext: {ciphertext}")
    print()

    # 使用频率分析进行破解
    estimated_k, decrypted_text = caesar_frequency_analysis(ciphertext)

    # 显示破解结果
    print("=== Decryption Results ===")
    print(f"Estimated k: {estimated_k}")
    print(f"Decrypted text: {decrypted_text}")

    # 显示字母频率统计
    print()
    print("=== Letter Frequency in Ciphertext ===")
    letter_counts = Counter(char.lower() for char in ciphertext if char.isalpha())
    for char, count in letter_counts.most_common(5):
        print(f"'{char}': {count} times")

    # 验证结果
    if estimated_k == true_k:
        print()
        print("SUCCESS: Frequency analysis correctly identified the key!")
    else:
        print()
        print("NOTE: Estimated key differs from true key.")
        print("This can happen with short texts or unusual letter distributions.")

    # 方法说明
    print()
    print("=" * 60)
    print("Method Explanation:")
    print("1. In English, 'e' appears most frequently (~12.7%)")
    print("2. Caesar cipher preserves frequency distribution")
    print("3. Find the most frequent letter in ciphertext")
    print("4. Assume it corresponds to 'e' in plaintext")
    print("5. The distance between them is the key k")
    print("=" * 60)


def main():
    """主函数"""
    test_frequency_analysis()


if __name__ == "__main__":
    main()
