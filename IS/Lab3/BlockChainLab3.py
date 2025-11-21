import datetime
import hashlib
import json

class Blockchain:
    """
    A Proof of Work (PoW) blockchain implementation with actual mining.

    This class creates a chain of blocks, where each block contains transaction data
    and is linked to the previous block through a hash. New blocks are added through
    a mining process that requires finding a valid proof of work.

    Attributes:
        chain (list): A list to store the blockchain blocks.
        difficulty (int): The number of leading zeros required in the block hash for valid PoW.
    """

    def __init__(self, difficulty=4):
        """
        Initialize the Blockchain with an empty list, create the genesis block, and set difficulty.

        Args:
            difficulty (int): The number of leading zeros required in the block hash for valid PoW.
        """
        self.chain = []
        self.difficulty = difficulty
        self.create_genesis_block()

    def create_genesis_block(self):
        """
        Create the Genesis block and add it to the chain.

        The Genesis block is the first block in the blockchain.
        """
        genesis_block = self.create_block("Genesis Block", 0)
        self.chain.append(genesis_block)

    def create_block(self, data, proof):
        """
        Create a new block in the blockchain.

        Args:
            data (str): The data to be stored in the block.
            proof (int): The proof value found during the mining process.

        Returns:
            dict: A new block with all required information.
        """
        block = {
            'index': len(self.chain),
            'timestamp': str(datetime.datetime.now()),
            'data': data,
            'proof': proof,
            'previous_hash': self.hash(self.chain[-1]) if self.chain else '0'
        }
        return block

    def proof_of_work(self, data):
        """
        Mine a new block by finding a valid proof of work.

        Args:
            data (str): The data to be stored in the new block.

        Returns:
            dict: The newly mined and added block.
        """
        proof = 0
        while True:
            new_block = self.create_block(data, proof)
            if self.is_valid_proof(new_block):
                self.chain.append(new_block)
                return new_block
            proof += 1

    def is_valid_proof(self, block):
        """
        Check if a block's hash meets the difficulty requirement.

        Args:
            block (dict): The block to check.

        Returns:
            bool: True if the block's hash meets the difficulty requirement, False otherwise.
        """
        block_hash = self.hash(block)
        return block_hash.startswith('0' * self.difficulty)

    @staticmethod
    def hash(block):
        """
        Create a SHA-256 hash of a block.

        Args:
            block (dict): Block to be hashed.

        Returns:
            str: The hexadecimal string of the block's hash.
        """
        block_string = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()

    def get_previous_block(self):
        """
        Get the last block in the blockchain.

        Returns:
            dict: The last block in the chain.
        """
        return self.chain[-1]

    def print_block(self, index):
        """
        Print the block information for a given index.

        Args:
            index (int): The index of the block to print.

        Returns:
            None
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
        Verify the validity of the entire blockchain
        
        Returns:
            bool: True if the blockchain is valid, False otherwise
        """
        for i in range(1, len(self.chain)):
            current_block = self.chain[i]
            previous_block = self.chain[i-1]
            
            # Verify that the previous hash of the current block is correct
            if current_block['previous_hash'] != self.hash(previous_block):
                return False
                
            # Verify proof of workload for the current block
            if not self.is_valid_proof(current_block):
                return False
                
        return True

def mine_new_blocks(blockchain):
    # Mine two blocks
    block1 = blockchain.proof_of_work("Transaction: A -> B 0.5 bitcoin")
    block2 = blockchain.proof_of_work("Transaction: B -> C 0.3 bitcoin")
    
    # Print all blocks
    for i in range(len(blockchain.chain)):
        blockchain.print_block(i)

def main():
    """
    Main function to demonstrate the Blockchain class functionality with mining.

    Creates an instance of the Blockchain class, mines new blocks, and prints information about them.
    """
    # Create a new blockchain instance with difficulty 4
    blockchain = Blockchain(difficulty=4)
    
    # Demonstrate mining new blocks
    mine_new_blocks(blockchain)
    
    # Verify the blockchain
    is_valid = blockchain.is_chain_valid()
    print(f"\nBlockchain validation result: {'Effective' if is_valid else 'Ineffective'}")
    
    # Demonstrate getting the previous block
    previous_block = blockchain.get_previous_block()
    print("\nPrevious (last) block:")
    print(previous_block)


if __name__ == "__main__":
    main()