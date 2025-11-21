"""
=========================================================================
Task 2: Caesar密码加密与暴力破解 (Python版本)
=========================================================================
功能说明：
    1. 使用Caesar密码对明文进行加密
    2. 使用暴力破解方法尝试所有可能的k值（0-25）解密
    3. 通过目视检查找到正确的解密结果
=========================================================================
"""

def caesar_encrypt(plaintext, k):
    """
    Caesar密码加密函数

    参数：
        plaintext: 待加密的明文字符串
        k: 加密密钥（位移量）

    返回：
        ciphertext: 加密后的密文字符串
    """
    # 将明文转换为小写
    plaintext = plaintext.lower()
    ciphertext = ""

    # 遍历明文中的每个字符
    for char in plaintext:
        if char.isalpha():
            # 获取字符的ASCII值
            ascii_val = ord(char)
            # 应用Caesar加密公式: C = (p + k) mod 26
            # 'a'的ASCII值为97
            encrypted_val = (ascii_val - 97 + k) % 26 + 97
            # 将加密后的ASCII值转换回字符
            ciphertext += chr(encrypted_val)
        else:
            # 非字母字符保持不变（如空格、标点）
            ciphertext += char

    return ciphertext


def caesar_brute_force(ciphertext):
    """
    Caesar密码暴力破解函数

    参数：
        ciphertext: 待破解的密文字符串

    返回：
        decrypted_texts: 包含26种可能解密结果的列表
    """
    decrypted_texts = []

    # 尝试所有可能的k值（0到25）
    for k in range(26):
        decrypted_text = ""

        # 对每个字符进行解密
        for char in ciphertext:
            if char.isalpha():
                # 获取字符的ASCII值
                ascii_val = ord(char)
                # 应用Caesar解密公式: p = (C - k) mod 26
                decrypted_val = (ascii_val - 97 - k) % 26 + 97
                # 将解密后的ASCII值转换回字符
                decrypted_text += chr(decrypted_val)
            else:
                # 非字母字符保持不变
                decrypted_text += char

        decrypted_texts.append(decrypted_text)

    return decrypted_texts


def main():
    """主函数：演示Caesar加密和暴力破解"""
    # 定义原始明文
    original_text = "this is a secret message"
    # 使用的加密密钥（由Task1计算得到）
    k_original = 9

    # 加密过程
    encrypted_text = caesar_encrypt(original_text, k_original)
    print(f"Original text: {original_text}")
    print(f"Encryption key k = {k_original}")
    print(f"Encrypted text: {encrypted_text}")
    print()

    # 暴力破解
    print("=== Brute Force Decryption Results ===")
    decrypted_texts = caesar_brute_force(encrypted_text)

    # 显示所有可能的解密结果
    for i, text in enumerate(decrypted_texts):
        # 标记正确的解密结果
        marker = " <-- CORRECT" if i == k_original else ""
        print(f"k = {i}: {text}{marker}")

    print()
    print("=" * 60)
    print("Expected result:")
    print(f"When k=9, decrypted text should be: '{original_text}'")
    print("This verifies the encryption and decryption process.")
    print("=" * 60)


if __name__ == "__main__":
    main()
