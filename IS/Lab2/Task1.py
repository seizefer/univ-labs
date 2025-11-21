import datetime

class Blockchain:
    """
    A simple blockchain implementation for Task 1.

    This class creates a list of blocks, where each block is represented by a dictionary.
    It provides methods to generate blocks, log blocks, and print block data.

    Attributes:
        chain (list): A list to store the blockchain blocks.
    """

    def __init__(self):
        """
        Initialize the Blockchain with an empty list and generate 10 blocks.
        """
        self.chain = []
        self.generate_blocks()

    def generate_blocks(self):
        """
        Generate 10 blocks and append them to the chain.

        Each block is a dictionary with 'index' and 'data' keys.
        The index starts at 0 and increments by 1 for each block.
        The data is a list of values starting at 100 and incrementing by 100 for each block.
        """
        for i in range(10):
            block = {
                'index': i,
                'data': list(range(100 * (i + 1), 100 * (i + 2), 100))
            }
            self.chain.append(block)

    def log_block(self, index):
        """
        Log the block information for a given index.

        Args:
            index (int): The index of the block to log.

        Returns:
            None
        """
        if 0 <= index < len(self.chain):
            block = self.chain[index]
            print(f"Block {index}:")
            print(f"  Index: {block['index']}")
            print(f"  Data: {block['data']}")
            print(f"  Timestamp: {datetime.datetime.now()}")
            print(f"  Proof: N/A")
            print(f"  Previous Hash: N/A")
        else:
            print(f"Block {index} does not exist.")

    def print_block_data(self, index):
        """
        Print the block data for a given index.

        Args:
            index (int): The index of the block to print.

        Returns:
            None
        """
        if 0 <= index < len(self.chain):
            print(f"Block {index} data: {self.chain[index]['data']}")
        else:
            print(f"Block {index} does not exist.")


def main():
    """
    Main function to demonstrate the Blockchain class functionality.

    Creates an instance of the Blockchain class and prints information about specific blocks.
    """
    # Create a new blockchain instance
    blockchain = Blockchain()

    # Log block 5
    blockchain.log_block(5)

    # Print data of block 3
    blockchain.print_block_data(3)

    # Try to access a non-existent block
    blockchain.print_block_data(15)


if __name__ == "__main__":
    main()