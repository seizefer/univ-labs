"""
=========================================================================
Lab3: 区块链挖矿实现
=========================================================================
功能说明：
    实现完整的工作量证明(PoW)挖矿系统
    通过调整难度参数来控制挖矿难度
    验证区块链的完整性和有效性

课程：UESTC4036 Information Security
实验：Lab 3 - Blockchain Mining

核心概念：
    - 工作量证明(Proof of Work): 找到满足特定条件的nonce值
    - 难度(Difficulty): 哈希值前缀需要的0的个数
    - 链验证: 确保区块链的完整性和一致性
=========================================================================
"""

import datetime
import hashlib
import json


class Blockchain:
    """
    带实际挖矿功能的工作量证明(PoW)区块链实现类

    这个类创建一个区块链，通过挖矿过程添加新区块。
    挖矿需要找到一个有效的工作量证明。

    属性：
        chain (list): 用于存储区块链中所有区块的列表
        difficulty (int): 区块哈希中前导零的数量要求
    """

    def __init__(self, difficulty=4):
        """
        初始化区块链，创建创世区块并设置难度

        参数：
            difficulty (int): 有效PoW所需的前导零数量
                            难度越高，挖矿时间越长
        """
        self.chain = []
        self.difficulty = difficulty
        self.create_genesis_block()

    def create_genesis_block(self):
        """
        创建创世区块并添加到链中

        创世区块是区块链的第一个区块，不需要挖矿
        """
        genesis_block = self.create_block("Genesis Block", 0)
        self.chain.append(genesis_block)

    def create_block(self, data, proof):
        """
        创建新区块

        参数：
            data (str): 要存储在区块中的数据
            proof (int): 挖矿过程中找到的证明值

        返回：
            dict: 包含所有必要信息的新区块
        """
        block = {
            'index': len(self.chain),  # 区块索引
            'timestamp': str(datetime.datetime.now()),  # 时间戳
            'data': data,  # 交易数据
            'proof': proof,  # 工作量证明（nonce）
            # 计算前一区块的哈希值，创世区块为'0'
            'previous_hash': self.hash(self.chain[-1]) if self.chain else '0'
        }
        return block

    def proof_of_work(self, data):
        """
        挖掘新区块：找到有效的工作量证明

        核心挖矿算法：
        1. 从proof=0开始
        2. 创建临时区块
        3. 检查区块哈希是否满足难度要求
        4. 如果不满足，proof+1继续尝试
        5. 找到有效proof后，添加区块到链中

        参数：
            data (str): 要存储在新区块中的数据

        返回：
            dict: 新挖掘并添加的区块
        """
        proof = 0
        while True:
            # 创建候选区块
            new_block = self.create_block(data, proof)
            # 检查是否满足难度要求
            if self.is_valid_proof(new_block):
                # 找到有效证明，添加到链中
                self.chain.append(new_block)
                return new_block
            # 继续尝试下一个proof值
            proof += 1

    def is_valid_proof(self, block):
        """
        检查区块的哈希是否满足难度要求

        难度要求：哈希值必须以指定数量的0开头
        例如：difficulty=4 要求哈希值以"0000"开头

        参数：
            block (dict): 要检查的区块

        返回：
            bool: 如果区块哈希满足难度要求返回True
        """
        block_hash = self.hash(block)
        # 检查哈希值是否以足够多的0开头
        return block_hash.startswith('0' * self.difficulty)

    @staticmethod
    def hash(block):
        """
        创建区块的SHA-256哈希值

        参数：
            block (dict): 要哈希的区块

        返回：
            str: 区块哈希值的十六进制字符串
        """
        # 将区块转换为JSON字符串并编码
        block_string = json.dumps(block, sort_keys=True).encode()
        # 计算并返回SHA-256哈希值
        return hashlib.sha256(block_string).hexdigest()

    def get_previous_block(self):
        """
        获取链中的最后一个区块

        返回：
            dict: 链中的最后一个区块
        """
        return self.chain[-1]

    def print_block(self, index):
        """
        打印指定索引的区块信息

        参数：
            index (int): 要打印的区块索引
        """
        if 0 <= index < len(self.chain):
            block = self.chain[index]
            print(f"Block {index}:")
            print(f"  Timestamp: {block['timestamp']}")
            print(f"  Data: {block['data']}")
            print(f"  Proof: {block['proof']}")
            print(f"  Previous Hash: {block['previous_hash']}")
            print(f"  Current Hash: {self.hash(block)}")
        else:
            print(f"Block {index} does not exist.")

    def is_chain_valid(self):
        """
        验证整个区块链的有效性

        验证内容：
        1. 每个区块的previous_hash是否等于前一区块的实际哈希
        2. 每个区块是否满足工作量证明要求

        返回：
            bool: 如果区块链有效返回True，否则返回False
        """
        # 从第二个区块开始遍历（索引1）
        for i in range(1, len(self.chain)):
            current_block = self.chain[i]
            previous_block = self.chain[i - 1]

            # 验证1：检查当前区块的previous_hash是否正确
            if current_block['previous_hash'] != self.hash(previous_block):
                print(f"Invalid: Block {i} has incorrect previous_hash")
                return False

            # 验证2：检查当前区块是否满足工作量证明
            if not self.is_valid_proof(current_block):
                print(f"Invalid: Block {i} does not meet difficulty requirement")
                return False

        return True


def mine_new_blocks(blockchain):
    """
    挖掘新区块的演示函数

    参数：
        blockchain: 区块链实例
    """
    print("Mining blocks... (this may take a moment)")
    print()

    # 挖掘两个区块
    block1 = blockchain.proof_of_work("Transaction: A -> B 0.5 bitcoin")
    print(f"Block 1 mined with proof: {block1['proof']}")

    block2 = blockchain.proof_of_work("Transaction: B -> C 0.3 bitcoin")
    print(f"Block 2 mined with proof: {block2['proof']}")
    print()

    # 打印所有区块
    print("=== All Blocks in Chain ===")
    for i in range(len(blockchain.chain)):
        blockchain.print_block(i)
        print()


def main():
    """
    主函数：演示带挖矿功能的区块链

    创建区块链实例，挖掘新区块，并验证区块链有效性
    """
    print("=" * 60)
    print("Blockchain Mining Demo")
    print("=" * 60)
    print()

    # 创建难度为4的区块链实例
    # 难度4意味着哈希值需要以"0000"开头
    blockchain = Blockchain(difficulty=4)
    print(f"Blockchain created with difficulty: {blockchain.difficulty}")
    print()

    # 演示挖掘新区块
    mine_new_blocks(blockchain)

    # 验证区块链
    is_valid = blockchain.is_chain_valid()
    print("=" * 60)
    print(f"Blockchain validation result: {'Valid' if is_valid else 'Invalid'}")
    print("=" * 60)
    print()

    # 演示获取前一区块
    previous_block = blockchain.get_previous_block()
    print("Previous (last) block:")
    print(f"  Index: {previous_block['index']}")
    print(f"  Data: {previous_block['data']}")
    print(f"  Proof: {previous_block['proof']}")


if __name__ == "__main__":
    main()


# =========================================================================
# 学习心得与反思
# =========================================================================
"""
通过本实验，我对工作量证明(PoW)共识机制有了深刻的理解：

1. 挖矿的本质：挖矿就是不断尝试不同的nonce值，直到找到一个使区块哈希
   满足难度要求的值。这个过程需要大量计算，但验证却很简单。

2. 难度的意义：difficulty参数控制了挖矿的难度。每增加1，平均需要的
   尝试次数就增加16倍（因为每个十六进制位有16种可能）。

3. 安全性保证：
   - 修改任何区块数据都会改变其哈希值
   - 这会导致后续所有区块的previous_hash失效
   - 攻击者需要重新挖掘所有后续区块，这在计算上几乎不可能

4. 去中心化共识：多个节点同时挖矿，最先找到有效proof的节点广播区块，
   其他节点验证后接受。这就是区块链实现去中心化共识的方式。

下一步学习方向：
- 权益证明(PoS)等更环保的共识算法
- 智能合约和去中心化应用(DApp)
- 区块链在供应链、投票等领域的应用
"""
