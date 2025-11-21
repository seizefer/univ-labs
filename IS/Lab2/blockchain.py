import datetime
import hashlib
import json

class Blockchain:
    """
    A Proof of Work (PoW) blockchain implementation.

    This class creates a chain of blocks, where each block contains transaction data
    and is linked to the previous block through a hash.

    Attributes:
        chain (list): A list to store the blockchain blocks.
    """

    def __init__(self):
        """
        Initialize the Blockchain with an empty list and create the genesis block.
        """
        self.chain = []
        self.create_genesis_block()

    def create_genesis_block(self):
        """
        Create the Genesis block and add it to the chain.

        The Genesis block is the first block in the blockchain.
        """
        genesis_block = self.create_block("Hello World!", 0, '0')
        self.chain.append(genesis_block)

    def create_block(self, data, proof, previous_hash):
        """
        Create a new block in the blockchain.

        Args:
            data (str): The data to be stored in the block.
            proof (int): The proof of work for this block.
            previous_hash (str): The hash of the previous block.

        Returns:
            dict: A new block with all required information.
        """
        block = {
            'index': len(self.chain),
            'timestamp': str(datetime.datetime.now()),
            'data': data,
            'proof': proof,
            'previous_hash': previous_hash
        }
        return block

    def get_previous_block(self):
        """
        Get the last block in the blockchain.

        Returns:
            dict: The last block in the chain.
        """
        return self.chain[-1]

    def add_block(self, data, proof):
        """
        Add a new block to the blockchain.

        Args:
            data (str): The data to be stored in the new block.
            proof (int): The proof of work for the new block.

        Returns:
            dict: The newly created and added block.
        """
        previous_block = self.get_previous_block()
        previous_hash = self.hash(previous_block)
        new_block = self.create_block(data, proof, previous_hash)
        self.chain.append(new_block)
        return new_block

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
    Main function to demonstrate the Blockchain class functionality.

    Creates an instance of the Blockchain class, adds blocks, and prints information about them.
    """
    # Create a new blockchain instance
    blockchain = Blockchain()

    # Add some blocks
    blockchain.add_block("Transaction A", 24912)
    blockchain.add_block("Transaction B", 235724)

    # Print the genesis block
    blockchain.print_block(0)

    # Print other blocks
    blockchain.print_block(1)
    blockchain.print_block(2)

    # Demonstrate getting the previous block
    previous_block = blockchain.get_previous_block()
    print("\nPrevious block:")
    print(previous_block)


if __name__ == "__main__":
    main()


    '''
    Through this lab, I’ve deepened my understanding of blockchain systems, particularly the role of block generation, linking, and security through hash functions. What I did was not just implement a basic blockchain, but also encapsulate the key elements of decentralization and trust that make blockchain a robust and distributed technology. The significance of this task lies in demonstrating how each block not only stores data but also carries the essence of proof of work, previous block hashing, and a timestamp, all of which contribute to the immutability and security of the chain.

This exercise showed me that the power of blockchain isn’t just about handling transactions, but in maintaining a shared, trustworthy record across multiple parties without the need for intermediaries. What it means is that blockchain's core features—tamper-proof data storage and decentralized validation—are achieved through simple yet powerful algorithms and mechanisms. Going forward, I realize that these concepts form the foundation for more complex systems like cryptocurrencies, supply chains, and smart contracts.

What’s next? Blockchain is not only a data structure but also an evolving technology. The next step would be to dive into consensus algorithms (like Proof of Stake, Delegated Proof of Stake) and explore how these influence scalability and energy consumption. I also see potential in applying these concepts to non-financial sectors, like secure voting or data privacy systems, where the benefits of immutability and trust are highly significant.

'''