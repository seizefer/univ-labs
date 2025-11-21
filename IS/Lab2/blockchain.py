"""
=========================================================================
Lab2 Task2-3: 带哈希的区块链实现
=========================================================================
功能说明：
    实现具有SHA-256哈希功能的区块链
    每个区块通过哈希值与前一个区块连接，形成不可篡改的链式结构

课程：UESTC4036 Information Security
实验：Lab 1 - Build a Blockchain in Python

技术要点：
    - 使用datetime库添加时间戳
    - 使用hashlib进行SHA-256哈希
    - 使用json编码区块数据
=========================================================================
"""

import datetime
import hashlib
import json


class Blockchain:
    """
    工作量证明(PoW)区块链实现类

    这个类创建一个区块链，每个区块包含交易数据
    并通过哈希值与前一个区块连接。

    属性：
        chain (list): 用于存储区块链中所有区块的列表
    """

    def __init__(self):
        """
        初始化区块链，创建空列表并生成创世区块

        Task3要求：创建Blockchain类，__init__方法包含chain变量
        """
        self.chain = []
        self.create_genesis_block()

    def create_genesis_block(self):
        """
        创建创世区块并添加到链中

        Task3.1要求：编写区块生成函数创建创世区块
        创世区块是区块链中的第一个区块，特殊之处：
        - proof = 0
        - previous_hash = '0'
        """
        genesis_block = self.create_block("Hello World!", 0, '0')
        self.chain.append(genesis_block)

    def create_block(self, data, proof, previous_hash):
        """
        创建新区块

        Task3.1要求：区块包含以下字段：
        - index: 区块索引，使用chain长度
        - timestamp: 当前日期时间
        - data: 记录的信息
        - proof: 工作量证明值
        - previous_hash: 前一区块的哈希值

        参数：
            data (str): 要存储在区块中的数据
            proof (int): 该区块的工作量证明
            previous_hash (str): 前一区块的哈希值

        返回：
            dict: 包含所有必要信息的新区块
        """
        block = {
            'index': len(self.chain),  # 使用链长度作为索引
            'timestamp': str(datetime.datetime.now()),  # 当前时间戳
            'data': data,  # 交易或其他数据
            'proof': proof,  # 工作量证明
            'previous_hash': previous_hash  # 前一区块哈希
        }
        return block

    def get_previous_block(self):
        """
        获取链中的最后一个区块

        Task3.3要求：创建获取前一区块的方法

        返回：
            dict: 链中的最后一个区块
        """
        return self.chain[-1]

    def add_block(self, data, proof):
        """
        向区块链添加新区块

        Task3.2要求：编写函数将信息输入区块并记录到区块链

        参数：
            data (str): 要存储在新区块中的数据
            proof (int): 新区块的工作量证明

        返回：
            dict: 新创建并添加的区块
        """
        # 获取前一区块
        previous_block = self.get_previous_block()
        # 计算前一区块的哈希值
        previous_hash = self.hash(previous_block)
        # 创建新区块
        new_block = self.create_block(data, proof, previous_hash)
        # 添加到链中
        self.chain.append(new_block)
        return new_block

    @staticmethod
    def hash(block):
        """
        创建区块的SHA-256哈希值

        这是区块链安全性的核心：
        - 任何数据变化都会导致哈希值完全不同
        - 哈希值是单向的，无法从哈希值反推原数据

        参数：
            block (dict): 要哈希的区块

        返回：
            str: 区块哈希值的十六进制字符串
        """
        # 将区块转换为JSON字符串，sort_keys确保一致性
        block_string = json.dumps(block, sort_keys=True).encode()
        # 计算SHA-256哈希值
        return hashlib.sha256(block_string).hexdigest()

    def print_block(self, index):
        """
        打印指定索引的区块信息

        参数：
            index (int): 要打印的区块索引

        返回：
            None
        """
        if 0 <= index < len(self.chain):
            block = self.chain[index]
            print(f"Block {index}:")
            print(f"  Index: {block['index']}")
            print(f"  Timestamp: {block['timestamp']}")
            print(f"  Data: {block['data']}")
            print(f"  Proof: {block['proof']}")
            print(f"  Previous Hash: {block['previous_hash']}")
            print(f"  Current Hash: {self.hash(block)}")
        else:
            print(f"Block {index} does not exist.")


def main():
    """
    主函数：演示带哈希的区块链功能

    创建区块链实例，添加区块，并打印信息
    """
    # 创建区块链实例
    blockchain = Blockchain()

    print("=== Blockchain with Hash Demo ===")
    print()

    # 添加一些区块（使用预设的proof值）
    blockchain.add_block("Transaction A", 24912)
    blockchain.add_block("Transaction B", 235724)

    # 打印创世区块
    print("Genesis Block (Block 0):")
    blockchain.print_block(0)
    print()

    # 打印其他区块
    print("Block 1:")
    blockchain.print_block(1)
    print()

    print("Block 2:")
    blockchain.print_block(2)
    print()

    # 演示获取前一区块
    previous_block = blockchain.get_previous_block()
    print("Previous (last) block:")
    print(f"  {previous_block}")


if __name__ == "__main__":
    main()


# =========================================================================
# Task 4: 反思与意义
# =========================================================================
"""
通过本实验，我深入理解了区块链系统，特别是区块生成、链接和通过哈希函数
实现安全性的角色。我所做的不仅仅是实现一个基本的区块链，还封装了去中心化
和信任的关键要素，这些使区块链成为一种强大的分布式技术。

这项任务的意义在于展示了每个区块不仅存储数据，还携带了工作量证明、前一区块
哈希和时间戳的本质，所有这些都有助于链的不可变性和安全性。

这个练习向我展示了区块链的力量不仅仅在于处理交易，而在于在多方之间维护一个
共享的、可信的记录，而不需要中间人。这意味着区块链的核心特性——防篡改数据
存储和去中心化验证——是通过简单但强大的算法和机制实现的。

展望未来，我意识到这些概念构成了更复杂系统的基础，如加密货币、供应链和
智能合约。

下一步是什么？区块链不仅是一种数据结构，也是一种不断发展的技术。下一步
将是深入研究共识算法（如权益证明、委托权益证明）并探索这些如何影响可扩展性
和能源消耗。我还看到了将这些概念应用于非金融领域的潜力，如安全投票或数据
隐私系统，在这些领域，不可变性和信任的好处非常重要。
"""
