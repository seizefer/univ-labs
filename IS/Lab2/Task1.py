"""
=========================================================================
Lab2 Task1: 简单区块链实现
=========================================================================
功能说明：
    实现一个基础的区块链数据结构
    每个区块包含索引和数据，用于理解区块链的基本概念

课程：UESTC4036 Information Security
实验：Lab 1 - Build a Blockchain in Python
=========================================================================
"""

import datetime


class Blockchain:
    """
    简单区块链实现类

    这个类创建一个区块列表，每个区块由字典表示。
    提供生成区块、记录区块信息和打印区块数据的方法。

    属性：
        chain (list): 用于存储区块链中所有区块的列表
    """

    def __init__(self):
        """
        初始化区块链，创建空列表并生成10个区块

        Task1.3要求：将函数放入类中，编写主程序创建类实例
        """
        self.chain = []
        self.generate_blocks()

    def generate_blocks(self):
        """
        生成10个区块并添加到链中

        Task1.1要求：
        - 使用for循环生成10个区块
        - 每个区块是字典类型，包含index和data
        - data从100开始，每个区块递增100
        """
        for i in range(10):
            # 创建区块字典
            block = {
                'index': i,  # 区块索引，从0开始
                # 数据转换为列表类型，包含从100*(i+1)开始的值
                'data': list(range(100 * (i + 1), 100 * (i + 2), 100))
            }
            # 将区块添加到链中
            self.chain.append(block)

    def log_block(self, index):
        """
        记录并显示指定索引的区块信息

        Task1.2要求：定义函数实现区块记录功能

        参数：
            index (int): 要记录的区块索引

        返回：
            None
        """
        # 检查索引是否有效
        if 0 <= index < len(self.chain):
            block = self.chain[index]
            print(f"Block {index}:")
            print(f"  Index: {block['index']}")
            print(f"  Data: {block['data']}")
            print(f"  Timestamp: {datetime.datetime.now()}")
            # 简单区块链没有proof和previous_hash
            print(f"  Proof: N/A")
            print(f"  Previous Hash: N/A")
        else:
            print(f"Block {index} does not exist.")

    def print_block_data(self, index):
        """
        打印指定索引的区块数据

        Task1.2要求：编写另一个函数根据输入索引打印区块

        参数：
            index (int): 要打印的区块索引

        返回：
            None
        """
        # 检查索引是否有效
        if 0 <= index < len(self.chain):
            print(f"Block {index} data: {self.chain[index]['data']}")
        else:
            print(f"Block {index} does not exist.")


def main():
    """
    主函数：演示Blockchain类的功能

    Task1.3要求：编写主程序创建类实例并打印所需区块

    Task1.4要求：使用docstring注释说明函数参数和返回值
    """
    # 创建区块链实例
    blockchain = Blockchain()

    print("=== Simple Blockchain Demo ===")
    print()

    # 记录区块5的完整信息
    print("Logging block 5:")
    blockchain.log_block(5)
    print()

    # 打印区块3的数据
    print("Printing block 3 data:")
    blockchain.print_block_data(3)
    print()

    # 尝试访问不存在的区块
    print("Trying to access non-existent block 15:")
    blockchain.print_block_data(15)
    print()

    # 显示所有区块
    print("=== All Blocks in Chain ===")
    for i in range(len(blockchain.chain)):
        print(f"Block {i}: {blockchain.chain[i]}")


if __name__ == "__main__":
    main()
