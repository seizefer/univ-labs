"""
=========================================================================
Task 4: Playfair密码矩阵生成 (Python版本)
=========================================================================
功能说明：
    Playfair密码使用5x5矩阵进行加密
    本程序根据给定的关键词生成Playfair密码矩阵
    矩阵中I和J被视为同一字母（因为矩阵只有25个位置）
=========================================================================
"""

import numpy as np


def generate_playfair_matrix(keyword):
    """
    生成Playfair密码矩阵

    参数：
        keyword: 用于生成矩阵的关键词字符串

    返回：
        matrix: 5x5的Playfair密码矩阵（numpy数组）
    """
    # 将关键词转换为大写并移除非字母字符
    keyword = ''.join(char.upper() for char in keyword if char.isalpha())

    # 将J替换为I（Playfair密码的标准做法）
    keyword = keyword.replace('J', 'I')

    # 定义字母表（不包含J，共25个字母）
    alphabet = 'ABCDEFGHIKLMNOPQRSTUVWXYZ'

    # 用于记录已使用的字符
    used_chars = []
    matrix_chars = []

    # 步骤1：首先填入关键词中的字符（去重）
    for char in keyword:
        if char not in used_chars:
            matrix_chars.append(char)
            used_chars.append(char)

    # 步骤2：填入剩余的字母（按字母表顺序）
    for char in alphabet:
        if char not in used_chars:
            matrix_chars.append(char)

    # 将字符列表转换为5x5矩阵
    matrix = np.array(matrix_chars).reshape(5, 5)

    return matrix


def print_matrix(matrix, title=""):
    """
    格式化打印矩阵

    参数：
        matrix: 5x5矩阵
        title: 标题字符串
    """
    if title:
        print(title)

    print("-" * 21)
    for row in matrix:
        print("| " + " | ".join(row) + " |")
        print("-" * 21)
    print()


def main():
    """主函数：演示Playfair矩阵生成"""
    print("=== Playfair Matrix Generation ===")
    print()

    # 测试1：使用关键词"Security"生成矩阵
    matrix1 = generate_playfair_matrix("Security")
    print_matrix(matrix1, 'Playfair matrix for keyword "Security":')

    # 测试2：使用姓名"Wang"生成矩阵
    matrix2 = generate_playfair_matrix("Wang")
    print_matrix(matrix2, 'Playfair matrix for keyword "Wang":')

    # 测试3：使用姓名"Zhang"生成矩阵
    matrix3 = generate_playfair_matrix("Zhang")
    print_matrix(matrix3, 'Playfair matrix for keyword "Zhang":')

    # 显示Playfair加密规则说明
    print("=" * 60)
    print("Playfair Cipher Encryption Rules (Reference):")
    print("-" * 60)
    print("1. Split plaintext into digrams (pairs of letters)")
    print("2. If both letters are same, insert filler 'X'")
    print("3. For each pair, apply these rules:")
    print("   - Same row: replace with letter to the right (wrap)")
    print("   - Same column: replace with letter below (wrap)")
    print("   - Rectangle: swap columns of each letter")
    print()
    print("Example (keyword 'monarchy'):")
    print("  Matrix:")
    print("  M O N A R")
    print("  C H Y B D")
    print("  E F G I K")
    print("  L P Q S T")
    print("  U V W X Z")
    print()
    print("  'hs' -> 'BP' (rectangle rule)")
    print("  'ar' -> 'RM' (same row rule)")
    print("=" * 60)


if __name__ == "__main__":
    main()
